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
    %Run final Ghosting evaluation, store and plot results

Pref.AimResolution   = 256;
Pref.AimBitDepth     = 12;

Pref.DoPlotVisible       = 1;

Pref.ImageIntensity      = 0.8;

%Distortions
Pref.Perform_NonUniformity                          = 0;
Pref.Dist_NonUniNVec     = [1 4 -1]';

Pref.Perform_ChemicalShift                          = 0;
Pref.Dist_ChemShiftX    = 0;
Pref.Dist_ChemShiftY    = 0;

%In this test routine, the rotation and translation is disabled. This is
%done to be able to predefine the desired ghosting ratio as determined by
%the equation (cf. paper). The central ROI is a mixture of both the normal
%image intensity and an area overlayed with a ghost, yielding an increased
%averaged of the full ROI.

Pref.Perform_Rotation                               = 0;
Pref.Dist_RotAngleDeg    = 5.0;
    
Pref.Perform_Translation                            = 0;
Pref.Dist_ShiftXpx   	= 0.0;
Pref.Dist_ShiftYpx       = 0.0;
    
Pref.Perform_Ghosting                               = 1;    
Pref.Dist_GhostingLevel  = 0.1;

Pref.Perform_Blur                                   = 0;
Pref.Dist_BlurSigma      = 1.0;
    
Pref.Perform_Noise                                  = 0;
Pref.Dist_NoiseSTD       = 15;
Pref.Dist_NoiseMean      = 30;

Pref.Perform_ProjectiveDeformation                  = 0;
Pref.Dist_ProjectiveT    = [ 1   0   0; ...
                            0   1   0.0001; ... 
                            0.01   0   1];
                        
Pref.Perform_BarrelDeformation                      = 0;
Pref.Dist_BarrelLambda 	= 0.005;

Pref.Perform_PolynomialDeformation   = 0;
Pref.Dist_PolynomialT  	= [ 0        0; ...
                            1        0; ...
                            0        1; ...
                            0      0; ...
                            0        0; ...
                            0.00001    0];

%read images

if ~exist('I_res_raw','var')
    I_res_raw       = double(imread('Quality Tests\PhantomDummy_Resolution.tif'));
    I_imuni_raw     = double(imread('Quality Tests\PhantomDummy_Uniformity.tif'));
    % I_spatlin_raw   = double(imread('Quality Tests\PhantomDummy_SpatialLinearity.tif'));
end

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
        

%% Final calculations

% Shift 0 to 70, overall 8 steps
% Angle 0 to 10 degree, overall 8 steps

GhostingLevel   = linspace(0.0,0.20,10);

EstGhost        = nan(size(GhostingLevel));
RealGhost    	= nan(size(GhostingLevel));


for p = 1 : numel(GhostingLevel)

    %we want to reach a ghosting ratio of Dist_GhostingLevel(p)
    %the ratio is caluclated by
    %
    % R = | (M_top + M_bottom) - (M_left + M_right)| / (2 * M_center) 
    % M_top = M_bottom = Noise_mean
    % M_left = M_right = Pref.Dist_GhostingLevel * M_center
    
    % M_center = OriginalSignal + RelAreaGhost * Pref.Dist_GhostingLevel * OriginalSignal
    
    
    %However, the central ROI is a sum of areas of original image intensity
    %and overlays by the ghost, the amounts are defined as follows:
    %
    RelAreaGhost       = 3623/15437;
    RelAreaOriginal    = 11814/15437;
    
    M_center    = Pref.ImageIntensity * (2^Pref.AimBitDepth - 1);

    %with adjusted central mean: 
    %M_center := (M_center * (1 + RelAreaGhost * Pref.Dist_GhostingLevel))
    GL1         = (-GhostingLevel(p) * (M_center * (1 + RelAreaGhost * Pref.Dist_GhostingLevel)) + Pref.Dist_NoiseMean * Pref.Perform_Noise )/(M_center * (1 + RelAreaGhost * Pref.Dist_GhostingLevel));
    GL2         = (+GhostingLevel(p) * (M_center * (1 + RelAreaGhost * Pref.Dist_GhostingLevel)) + Pref.Dist_NoiseMean * Pref.Perform_Noise )/(M_center * (1 + RelAreaGhost * Pref.Dist_GhostingLevel));

    GL          = max([GL1, GL2]);
    if GL < 0
        warning('GL < 0')
    end
    
    Pref.Dist_GhostingLevel 	= GL;
    
    
    I_res       = QT_DistortImage( I_res_raw, Pref );
    I_imuni     = QT_DistortImage( I_imuni_raw, Pref );
    
    RawImSize   = size(I_res_raw);
    ImSize      = size(I_res);
    
    %First of all, estimate the Threshold
    Parameter = DetermineThreshold( I_imuni, Parameter ); %.GEN.Threshold

    %All position parameters such as center, radius and angle are determined
    %using the start values from the "raw" data given by the
    %DetermineThreshold-function; afterwards these startvalues will be replaced
    %by the accurate results which will be further used as startvalues

    [CenterX, CenterY, Radius, AngleEst, ~] = GetPhantomCenter( I_res, Parameter, 1, 0, 1 );

    %Save the position paramters to be used as start values for upcoming
    %calculations, if needed
    Parameter.GEN.CenterX   = CenterX;
    Parameter.GEN.CenterY   = CenterY;
    Parameter.GEN.Radius    = Radius;
    Parameter.GEN.Angle     = AngleEst;
    
    % SNR
    [Result_SNR, Parameter] = MeasureSNR( I_imuni, Parameter );
    

    fprintf(' ********************************* \n')
    fprintf(' **** L O C A L I Z A T I O N **** \n')
    fprintf(' ********************************* \n')
    fprintf('   CenterX: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftXpx, CenterX)
    fprintf('   CenterY: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftYpx, CenterY)
    fprintf('    Radius: Real = %.2f | Estim. = %.2f\n', 0.5 * 2834 * Pref.AimResolution/RawImSize(1), Radius)
    fprintf('     Angle: Real = %.2f | Estim. = %.2f\n', Pref.Dist_RotAngleDeg, AngleEst / pi * 180.0)
    fprintf(' ********************************* \n')
    fprintf(' ******* G H O S T I N G  ******** \n')
    fprintf(' ********************************* \n')
    fprintf('     Level: Real = %.2f | Estim. = %.2f\n', GhostingLevel(p), Result_SNR.GhostingRatio)
    
    
%     %Save the position paramters to be used as start values for upcoming
%     %calculations, if needed
%     Parameter.GEN.CenterX   = CenterX;
%     Parameter.GEN.CenterY   = CenterY;
%     Parameter.GEN.Radius    = Radius;
%     Parameter.GEN.Angle     = Angle;

    EstGhost(p)  	= Result_SNR.GhostingRatio;
    RealGhost(p) 	= GhostingLevel(p);


end

save('QA Results\QA_Ghosting.mat','EstGhost','RealGhost')

LH = QT_PlotEstimatesAgainstReal( EstGhost, RealGhost );
title('\textbf{Ghosting Artifacts}','Interpreter','latex','Fontsize',12)
set(LH,'String',{'Identity','Estimated vs. Synthetic'});
set(LH,'Interpreter','latex','Location','NorthWest')
set(LH,'OuterPosition',  [0.1303    0.7038    0.5085    0.1779])
set(LH,'Position',       [0.1389    0.7115    0.4957    0.1702])
xlabel('Synthetic Ghosting $[w.E.]$','Interpreter','latex')
ylabel('Estimated Ghosting $[w.E.]$','Interpreter','latex')
grid on
ylim([-0.02 0.22])




