function I = QT_DistortImage( I, Pref ) 

    %   Copyright (C) 2013 Heidelberg University 
    %   
    %   Developed at CKM (Computerunterstützte Klinische Medizin),
    %   Medical Faculty Mannheim, Heidelberg University, Mannheim, 
    %   Germany
    %   
    %   
    %   LICENCE
    %   
    %   CKM PhM Software Library, Release 1.0 (c) 2013, Heidelberg 
    %   University (the "Software")
    %   
    %   The Software remains the property of Heidelberg University ("the
    %   University").
    %   
    %   The Software is distributed "AS IS" under this Licence solely for
    %   non-commercial use in the hope that it will be useful, but in order
    %   that the University as a charitable foundation protects its assets for
    %   the benefit of its educational and research purposes, the University
    %   makes clear that no condition is made or to be implied, nor is any
    %   warranty given or to be implied, as to the accuracy of the Software,
    %   or that it will be suitable for any particular purpose or for use
    %   under any specific conditions. Furthermore, the University disclaims
    %   all responsibility for the use which is made of the Software. It
    %   further disclaims any liability for the outcomes arising from using
    %   the Software.
    %   
    %   The Licensee agrees to indemnify the University and hold the
    %   University harmless from and against any and all claims, damages and
    %   liabilities asserted by third parties (including claims for
    %   negligence) which arise directly or indirectly from the use of the
    %   Software or the sale of any products based on the Software.
    %   
    %   No part of the Software may be reproduced, modified, transmitted or
    %   transferred in any form or by any means, electronic or mechanical,
    %   without the express permission of the University. The permission of
    %   the University is not required if the said reproduction, modification,
    %   transmission or transference is done without financial return, the
    %   conditions of this Licence are imposed upon the receiver of the
    %   product, and all original and amended source code is included in any
    %   transmitted product. You may be held legally responsible for any
    %   copyright infringement that is caused or encouraged by your failure to
    %   abide by these terms and conditions.
    %   
    %   You are not permitted under this Licence to use this Software
    %   commercially. Use for which any financial return is received shall be
    %   defined as commercial use, and includes (1) integration of all or part
    %   of the source code or the Software into a product for sale or license
    %   by or on behalf of Licensee to third parties or (2) use of the
    %   Software or any derivative of it for research with the final aim of
    %   developing software products for sale or license to a third party or
    %   (3) use of the Software or any derivative of it for research with the
    %   final aim of developing non-software products for sale or license to a
    %   third party, or (4) use of the Software to provide any service to an
    %   external organisation for which payment is received. If you are
    %   interested in using the Software commercially, please contact 
    %   Prof. Dr. Lothar Schad (lothar.schad@medma.uni-heidelberg.de).
    %
    %Method Description:
    %-------------------
    %this method appies the defined distortions in Pref to the input image
    %I to be tested by the QT_Test.... methods




ImSize      = size(I);
if ImSize(1) ~= ImSize(2)
    warning('Input image is not square')
end

%Adjust size and bit depth
I   = imresize(I, Pref.AimResolution/ImSize(1));
I   = I * (2^Pref.AimBitDepth - 1)/255;

%Rescale to match maximum intensity (this is important, when ghosts are 
%added to the image in order not to exceed the maximum grayvalue)
I       = round(I .* Pref.ImageIntensity);
ImSize  = size(I);


%I_CenterID  = zeros(size(I));
%I_CenterID  = 
%I_RadiusID  = zeros(size(I));


if Pref.Perform_ChemicalShift
    fprintf(' -- Performing Chemical Shift --\n')
    
    %the squares are shift by Dist_ChemShiftX and Dist_ChemShiftY against
    %each other, which are positive integer values, only works with default
    %resolution of 512px times 512px
    
    %predefined positions of the squares
    UpperX1     = 82;
    UpperX2     = 91;
    UpperY1     = 154;
    UpperY2     = 165;
    
    LowerX1     = 91;
    LowerX2     = 100;
    LowerY1     = 165;
    LowerY2     = 176;
    
    UpperMat    = I( UpperY1:UpperY2, UpperX1:UpperX2 );
    LowerMat    = I( LowerY1:LowerY2, LowerX1:LowerX2 );
    
    %set original area in the image to zero
    I(  min([UpperY1,UpperY2,LowerY1,LowerY2]) : max([UpperY1,UpperY2,LowerY1,LowerY2]),...
        min([UpperX1,UpperX2,LowerX1,LowerX2]) : max([UpperX1,UpperX2,LowerX1,LowerX2]) ) = 0;
    
    %rewrite square matrices to image using shift properties; in case of
    %the shift property being uneven, the upper square is shift more
    I(  (UpperY1:UpperY2) - ceil(Pref.Dist_ChemShiftY/2), ...
        (UpperX1:UpperX2) - ceil(Pref.Dist_ChemShiftY/2) ) = UpperMat;
    
    CurrMat     = I(  (LowerY1:LowerY2) + floor(Pref.Dist_ChemShiftY/2), ...
        (LowerX1:LowerX2) + floor(Pref.Dist_ChemShiftY/2) );
    
    %get maximum value matrix
    LowerMat( CurrMat > LowerMat ) = CurrMat( CurrMat > LowerMat );
    
    %finally write back the matrix
    I(  (LowerY1:LowerY2) + floor(Pref.Dist_ChemShiftY/2), ...
        (LowerX1:LowerX2) + floor(Pref.Dist_ChemShiftY/2) ) = LowerMat;
    
    %in case a negative shift is performed, only write those pixels, that
    %are larger than the ones written for the upper square

end


if Pref.Perform_NonUniformity
    fprintf(' -- Performing NonUniformity --\n')

    %a grayvalue gradient is added with a layer of grayvalue offsets with a
    %slope 
    %Pref.Dist_NonUniPVec = [0 0 0]';
    Pref.Dist_NonUniPVec = [ImSize(2)/2, ImSize(1)/2, 0]';

    lambda = Pref.Dist_NonUniNVec' * Pref.Dist_NonUniPVec;

    % q = [ x y z]'
    % n * q = lambda;
    %
    % n1 * x + n2 * y + n3 * z = lambda
    %
    % ==> z = (lambda - (n1 * x + n2 * y))/n3

    z = @(x,y) (lambda - (Pref.Dist_NonUniNVec(1)*x + Pref.Dist_NonUniNVec(2)*y))/Pref.Dist_NonUniNVec(3);

    x = 1 : ImSize(2);
    y = 1 : ImSize(1);

    [X,Y] = meshgrid(x,y);
    Z = z(X,Y);
    
    %add grayvalue gradient to original image
%     figure
%     imagesc(Z)
    
    I = I + (I .* Z);

    
end

if Pref.Perform_Rotation
    fprintf(' ----- Performing Roation -----\n')
    fprintf('    Rotation Angle [deg]: %.2f\n', Pref.Dist_RotAngleDeg)
    
    % Rotate image
    I = imrotate(I, Pref.Dist_RotAngleDeg, 'bilinear', 'crop');
    
end
    
if Pref.Perform_Translation
    fprintf(' --- Performing Translation ---\n')
    fprintf('            Shift x [px]: %.2f\n', Pref.Dist_ShiftXpx)
    fprintf('            Shift x [px]: %.2f\n', Pref.Dist_ShiftYpx)
    
    % Transform image
    t = maketform('affine',[1 0 ; 0 1; Pref.Dist_ShiftXpx Pref.Dist_ShiftYpx]);
    I = imtransform(I,t,'XData',[1 size(I,2)],'YData',[1 size(I,1)]);

end

if Pref.Perform_Ghosting
    fprintf(' --- Performing Ghosting ---\n')
    fprintf('   Ghosting Level [a.u.]: %.2f\n', Pref.Dist_GhostingLevel)
    
    % add ghosts to image
    I_ghost         = nan(size(I));
    if mod(12,2) == 0
        %even size
     	LeftHalfSize    = size(I,2)/2;
      	RightHalfSize   = size(I,2)/2+1;
    else
        %odd size
      	LeftHalfSize    = floor(I,2)/2;
       	RightHalfSize   = floor(I,2)/2;
    end
    
    %create artifical ghost
    I_ghost(:,1:LeftHalfSize)       = I(:,RightHalfSize:end);
    I_ghost(:,RightHalfSize:end)	= I(:,1:LeftHalfSize);
    
    %add to original image in a rescald manner
    I 	= I + Pref.Dist_GhostingLevel * I_ghost;
    
end


if Pref.Perform_Blur   
    fprintf(' ----- Performing Bluring -----\n')
    fprintf('       Blur sigma [a.u.]: %.2f\n', Pref.Dist_BlurSigma)
    
    % Blur image
    F           = fspecial( 'gaussian', round(0.1 * size(I)), Pref.Dist_BlurSigma );
    I           = imfilter(I,F);
    
end
 
if Pref.Perform_Noise   
    fprintf(' ------ Performing Noise ------\n')
    fprintf('       Noise mean [a.u.]: %.2f\n', Pref.Dist_NoiseMean)
    fprintf('        Noise STD [a.u.]: %.2f\n', Pref.Dist_NoiseSTD)
    
    %add Gaussian noise
    N       = normrnd(Pref.Dist_NoiseMean,Pref.Dist_NoiseSTD,size(I,1),size(I,2));
    %first subtract the mean of the noise from the image, and rescale to
    %one
    I(I>0.5*(2^Pref.AimBitDepth - 1))   = I(I>0.5*(2^Pref.AimBitDepth - 1)) - Pref.Dist_NoiseMean;
    I   = I + N;
    
end

% Image Deformations

if Pref.Perform_ProjectiveDeformation
    fprintf(' ---> Performing Projective Deformation\n')
    fprintf(' Deform T:\n')
    disp(Pref.Dist_ProjectiveT)
    
	%transform image
    t_proj  = maketform('projective',Pref.Dist_ProjectiveT);
    I   = imtransform(I,t_proj,'FillValues',0.0,'XData',[1 size(I,2)],'YData',[1 size(I,1)]);

end

if Pref.Perform_BarrelDeformation
    fprintf(' ---> Performing Barrel Deformation\n')
    fprintf(' Barrel Lambda [a.u.]: %.2f\n', Pref.Dist_BarrelLambda)
    
    %transform image
    % radial barrel distortion
    imid            = round(size(I,2)/2);
    [nrows,ncols]   = size(I);
    [xi,yi]         = meshgrid(1:ncols,1:nrows);
    xt              = xi(:) - imid;
    yt              = yi(:) - imid;
    [theta,r]       = cart2pol(xt,yt);
    % Try varying the amplitude of the cubic term.
    a               = 0.000001; 
    r0              = 0.5 * 2834 * Pref.AimResolution/ImSize(1);
    s               = r0 * (exp( r * Pref.Dist_BarrelLambda )-1) /(exp( r0 * Pref.Dist_BarrelLambda )-1);
    [ut,vt]         = pol2cart(theta,s);
    u               = reshape(ut,size(xi)) + imid;
    v               = reshape(vt,size(yi)) + imid;
    tmap_B          = cat(3,u,v);
    resamp          = makeresampler('linear','fill');
    I               = tformarray(I,[],resamp,[2 1],[1 2],[],tmap_B,0.0);

end

if Pref.Perform_PolynomialDeformation
    fprintf(' ---> Performing Polynomial Deformation\n')
    fprintf(' Deform T:\n')

    xybase = reshape(randn(12,1),6,2);
    t_poly = cp2tform(xybase,xybase,'polynomial',2);

    % Try varying any of the twelve elements of T.
    t_poly.tdata = Pref.Dist_PolynomialT;
    
    I = imtransform(I,t_poly,'FillValues',0,'Size',size(I),'XData',[1, size(I,2)],'YData',[1, size(I,1)]);

end

%scale to avoid negative values, change to integers
I                               = round(I);


% figure
% imshow(I, [0 2^Pref.AimBitDepth - 1])

