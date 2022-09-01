function [Result_IU, Parameter] = MeasureImageUniformity( Image, Parameter )
   
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

    % Measurement of the Image Uniformity
    %
    % Result_IU contains:
    %
    %   1)      CenterX
    %   2)      CenterY
    %   3)      Radius
    %   4)      Span
    %   5)      Midrange
    %   6)      IntegralUniformity

    [SizeY,SizeX]   = size( Image );
    
    %Determine the position of the phantom inside of the image as well as
    %its radius...
    [CenterX, CenterY, Radius, ~, ~]    = GetPhantomCenter( Image, Parameter, 0, 0, 20 );
    
    %... and store the results in the Result_IU struct
    Result_IU.CenterX   = CenterX;
    Result_IU.CenterY   = CenterY;
    Result_IU.Radius    = Radius;

    %depending on the phantom-radius, calculate the Radius of the ROI,
    %that's being used to measure the image uniformity
    ROIRadius           = Radius * Parameter.IU.RadialSection;
    
    %Draw the ROI to the current plot
    DrawCircle(CenterX, CenterY, ROIRadius, 'red')
    
    %Get a vector containing all image-pixel-values lying in the ROI
    
    %use smoothed image for minimum and maximum determination to be less
    %sensitive to noise
  	GaussFilt           = fspecial('gaussian', round(0.1*[SizeY,SizeX]), 1.0);
 	ImageSmooth         = imfilter(Image,GaussFilt);
    CircularROI         = GetCircularROI( ImageSmooth, CenterX, CenterY, ROIRadius );

    %Get min and max values of all ROI-pixels
    Smax    = max(max(CircularROI));
    Smin    = min(min(CircularROI));
    
    Result_IU.Smax        = Smax;
    Result_IU.Smin        = Smin;
    
    %Calculate Span and Midrange of all ROI-pixels
    Result_IU.Span        = (Smax - Smin) / 2;
    Result_IU.Midrange    = (Smax + Smin) / 2;

    %Determine the integraluniformity where 1 is an optimal value 
    %(perfectly homogeneous ROI-area) and 0 is the worst case
    Result_IU.IntegralUniformity  = 1 - Result_IU.Span/Result_IU.Midrange;
    
    title(['Intergal Uniformity = ',num2str(Result_IU.IntegralUniformity)])

end