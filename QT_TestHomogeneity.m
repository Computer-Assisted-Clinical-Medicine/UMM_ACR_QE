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
    %Run final Homogeneity evaluation, store and plot results

Pref.AimResolution   = 256;
Pref.AimBitDepth     = 12;

Pref.DoPlotVisible       = 1;

Pref.ImageIntensity      = 0.8;


%Distortions
Pref.Perform_NonUniformity                          = 1;
Pref.Dist_NonUniNVec     = [0 0.000 -1]';
%Pref.Dist_NonUniNVec     = [0 0.0 -1]';

Pref.Perform_ChemicalShift                          = 0;
Pref.Dist_ChemShiftX    = 4;
Pref.Dist_ChemShiftY    = 4;

Pref.Perform_Rotation                               = 0;
Pref.Dist_RotAngleDeg    = 5.0;
    
Pref.Perform_Translation                            = 0;
Pref.Dist_ShiftXpx   	= 10.0;
Pref.Dist_ShiftYpx       = -5.0;
    
Pref.Perform_Ghosting                               = 0;    
Pref.Dist_GhostingLevel  = 0.12;

Pref.Perform_Blur                                   = 0;
Pref.Dist_BlurSigma      = 1.0;
    
Pref.Perform_Noise                                  = 0;
Pref.Dist_NoiseSTD       = 50;
Pref.Dist_NoiseMean      = 25;

Pref.Perform_ProjectiveDeformation                  = 0;
Pref.Dist_ProjectiveT    = [ 1   0   0; ...
                            0   1   0.0001; ... 
                            0   0   1];
                        
Pref.Perform_BarrelDeformation                      = 0;
Pref.Dist_BarrelLambda 	= 0.005;

Pref.Perform_PolynomialDeformation                  = 0;
Pref.Dist_PolynomialT  	= [ 0        0; ...
                            1        0; ...
                            0        1; ...
                            0      0; ...
                            0        0; ...
                            0.00002    0];

%read images
if ~exist('I_res_raw','var')
    fprintf('Loading PhantomDummy_Resolution.tif...')
    I_res_raw       = double(imread('Quality Tests\PhantomDummy_Resolution.tif'));
    fprintf(' done.\n')
end

if ~exist('I_imuni_raw','var')
    fprintf('Loading PhantomDummy_Uniformity.tif...')
    I_imuni_raw     = double(imread('Quality Tests\PhantomDummy_Uniformity.tif'));
    fprintf(' done.\n')
end

ImSizeRaw = size(I_res_raw,1);

%% QT Preferences

    % General
    %Parameter.GEN.SaveFolder            = DatasetList{DatasetIndex}{2}(1 : end - 4);
    %Parameter.GEN.SavePath              = ['Phantom Results/', DatasetList{DatasetIndex}{2}(1 : end - 4) ];
    Parameter.GEN.Threshold             = 1000;         %DEFAULT, will be changed
    Parameter.GEN.Angle                 = 0;            %DEFAULT, will be changed
    
    switch Pref.DoPlotVisible
        case 1
            Parameter.GEN.PlotVisible   = 'on';
        case 0
            Parameter.GEN.PlotVisible   = 'off';
    end
    
    %Start Values for Center
    Parameter.GEN.CenterX               = nan;
    Parameter.GEN.CenterY               = nan;
    Parameter.GEN.Radius                = nan;

    % =================================
    % ======== Signal-To-Noise ========
    % =================================
    %Relative size of SNR-ROI for Mean Calculation (based on Radius)
    Parameter.SNR.RelInnerROIRadius     = 0.8;
    %if set to one, all four STD-ROIs are set to have equal size
    Parameter.SNR.EqualSTDAreas         = 1;
    %if set to one, STD-ROIs are set to be positioned in the corners of the
    %image, otherwise the are right next to the phantoms border
    Parameter.SNR.BorderROIinCorner     = 0;
    %relative space between edge of Phantom and Ghost-ROIs based on Radius
    Parameter.SNR.BorderROIMargin       = 0.025;
    %Relative Minimum Margin Size at each Edge based on Phantom Radius
    Parameter.SNR.MinEdgeMargin         = 0.06;
    Parameter.SNR.MaxEdgeMargin         = 0.1;
    %Relative Size of ROI based on real MinEdgeMargin of Dataset 
    %(Size perpendicular to circle)
    Parameter.SNR.ROISizePerp           = 0.9;
    %Relative Size of ROI based on Diameter (!!!) of Phantom 
    %(Size tangential to circle)
    Parameter.SNR.ROISizeTang           = 0.75;

    % Image Uniformity
    Parameter.IU.RadialSection          = 0.8;
    % =================================
    % ======= Spatial Linearity =======
    % =================================
    % Range of valid areas based
    Parameter.SL.AreaRange              = [0.5, 1.5];
    Parameter.SL.RelExpObjectSize       = 0.14;
    Parameter.SL.BiSinFit               = 0;
    
    Parameter.SL.PixelSpacing   = 0.4688;
    Parameter.RES.PixelSpacing  = Parameter.SL.PixelSpacing;
        
    %Resolution
    Parameter.RES.AdjustPeak                    = 2;
    %   = 0:    none
    %   = 1:    by max
    %   = 2:    by fit
    Parameter.RES.RemoveGrayValueGradient       = 1;
    Parameter.RES.RelRegionSizeRadius           = 0.1314;
    Parameter.RES.RelGradientAreaRadius         = 0.0395;
    Parameter.RES.RelProfileRegionRadius        = 0.0075;
    Parameter.RES.PeakFitArea                   = [0.0074, 0.0056, 0.0037];
    Parameter.RES.GrayvalueVisibilityThreshold  = 200;
    
    
InhomogeneityLevels	= linspace(0.0,0.006,10);

EstInhomogeneity   	= nan(size(InhomogeneityLevels));
RealInhomogeneity  	= nan(size(InhomogeneityLevels));

for p =  1 : numel(InhomogeneityLevels)
    
    Pref.Dist_NonUniNVec    = [0; InhomogeneityLevels(p); -1];
    
    %% Final calculations
    I_res   = QT_DistortImage( I_res_raw, Pref );
    I_imuni = QT_DistortImage( I_imuni_raw, Pref );

    %% Localization
    [CenterX, CenterY, Radius, Angle, ~] = GetPhantomCenter( I_res, Parameter, 1, 0, 1 );

    %the inhomogeneity is introduced by adding a slanted layer to the center
    %area, i.e. the largest and smallest pixel values are located at the corner
    %of the central ROI

    % determine defined level of inhomogeneity
    %------------------------------------------
    if Pref.Perform_NonUniformity
        fprintf(' -- Performing NonUniformity --\n')

        %a grayvalue gradient is added with a layer of grayvalue offsets with a
        %slope 
        %Pref.Dist_NonUniPVec = [0 0 0]';
        ImSize               = size(I_res);
        Pref.Dist_NonUniPVec = [ImSize(2)/2, ImSize(1)/2, 0]';

        lambda = Pref.Dist_NonUniNVec' * Pref.Dist_NonUniPVec;

        z = @(x,y) (lambda - (Pref.Dist_NonUniNVec(1)*x + Pref.Dist_NonUniNVec(2)*y))/Pref.Dist_NonUniNVec(3);

        x = 1 : ImSize(2);
        y = 1 : ImSize(1);

        [X,Y] = meshgrid(x,y);
        Z = (1+z(X,Y))*Pref.ImageIntensity * (2^Pref.AimBitDepth - 1);

        %% get largest and smallest pixel values located in the ROI
        ROIRadius           = Radius * Parameter.IU.RadialSection;

        CircularROI         = GetCircularROI( Z, CenterX, CenterY, ROIRadius );

        %Get min and max values of all ROI-pixels
        Smax    = max(max(CircularROI));
        Smin    = min(min(CircularROI));

        %Calculate Span and Midrange of all ROI-pixels
        Span        = (Smax - Smin) / 2;
        Midrange    = (Smax + Smin) / 2;

        %Determine the integraluniformity where 1 is an optimal value 
        %(perfectly homogeneous ROI-area) and 0 is the worst case
        IntegralUniformity  = 1 - Span/Midrange;
    else
        warning('Synthetic inhomogeneity distortion is not active!')
    end

    % determine resulting level of inhomogeneity
    %--------------------------------------------
    [Result_IU, Parameter] = MeasureImageUniformity( I_imuni, Parameter );

    fprintf(' ********************************* \n')
    fprintf(' **** L O C A L I Z A T I O N **** \n')
    fprintf(' ********************************* \n')
    fprintf('   CenterX: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Perform_Translation*Pref.Dist_ShiftXpx, CenterX)
    fprintf('   CenterY: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Perform_Translation*Pref.Dist_ShiftYpx, CenterY)
    fprintf('    Radius: Real = %.2f | Estim. = %.2f\n', 0.5 * 2834 * Pref.AimResolution/ImSizeRaw(1), Radius)
    fprintf('     Angle: Real = %.2f | Estim. = %.2f\n', Pref.Dist_RotAngleDeg * Pref.Perform_Rotation, Angle / pi * 180.0)
    fprintf(' ******************************************* \n')
    fprintf(' **** I M A G E   H O M O G E N E I T Y **** \n')
    fprintf(' ******************************************* \n')
    fprintf('               Span: Real = %.2f | Estim. = %.2f\n', Span, Result_IU.Span)
    fprintf('           Midrange: Real = %.2f | Estim. = %.2f\n', Midrange, Result_IU.Midrange)
    fprintf(' IntegralUniformity: Real = %.2f | Estim. = %.2f\n', IntegralUniformity, Result_IU.IntegralUniformity)

    %store results
 	EstInhomogeneity(p) 	= Result_IU.IntegralUniformity;
  	RealInhomogeneity(p) 	= IntegralUniformity;
    
    % figure
    % imagesc(Z),colorbar

end

save('QA Results\QA_Homogeneity.mat','EstInhomogeneity','RealInhomogeneity')


LH = QT_PlotEstimatesAgainstReal( EstInhomogeneity, RealInhomogeneity );
title('\textbf{Image Homogeneity}','Interpreter','latex','Fontsize',12)
set(LH,'String',{'Identity','Estimated vs. Synthetic'});
set(LH,'Interpreter','latex','Location','NorthWest')
set(LH,'OuterPosition',  [0.1303    0.7038    0.5085    0.1779])
set(LH,'Position',       [0.1389    0.7115    0.4957    0.1702])
xlabel('Synthetic Homogeneity $[w.E.]$','Interpreter','latex')
ylabel('Estimated Homogeneity $[w.E.]$','Interpreter','latex')
grid on
ylim([0.55 1.05])


