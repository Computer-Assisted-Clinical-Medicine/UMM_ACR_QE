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
    %Run final Resolution evaluation, store and plot results. Note that
    %this method is currently using images of 4167px size, as the resizing
    %introduces blurring that negatively influences the comparability of
    %the estimated values with the predefined ones
    
Pref.AimResolution   = 4167;
Pref.AimBitDepth     = 12;

Pref.DoPlotVisible       = 1;

Pref.ImageIntensity      = 0.8;

%Distortions
Pref.Perform_NonUniformity                          = 0;
Pref.Dist_NonUniNVec     = [1 4 -1]';

Pref.Perform_ChemicalShift                          = 0;
Pref.Dist_ChemShiftX    = 0;
Pref.Dist_ChemShiftY    = 0;

Pref.Perform_Rotation                               = 0;
Pref.Dist_RotAngleDeg    = 5.0;
    
Pref.Perform_Translation                            = 0;
Pref.Dist_ShiftXpx   	= 0.0;
Pref.Dist_ShiftYpx     	= 0.0;
    
Pref.Perform_Ghosting                               = 0;    
Pref.Dist_GhostingLevel  = 0.05;

Pref.Perform_Blur                                   = 1;
Pref.Dist_BlurSigma      = 10.0;
    
Pref.Perform_Noise                                  = 0;
Pref.Dist_NoiseSTD       = 10;
Pref.Dist_NoiseMean      = 50;

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
if ~exist('I_imuni_raw','var')
    I_imuni_raw	= double(imread('Quality Tests\PhantomDummy_Uniformity.tif'));
end

if ~exist('I_res_raw','var')
    I_res_raw 	= double(imread('Quality Tests\PhantomDummy_Resolution.tif'));
end


% QT Preferences

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
    Parameter.SNR.RelInnerROIRadius     = 0.75;
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
    Parameter.IU.RadialSection          = 0.75;
    % =================================
    % ======= Spatial Linearity =======
    % =================================
    % Range of valid areas based
    Parameter.SL.AreaRange              = [0.5, 1.5];
    Parameter.SL.RelExpObjectSize       = 0.14;
    Parameter.SL.BiSinFit               = 0;
    
    Parameter.SL.PixelSpacing   = 1;
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
        
    Blur            	= linspace(5.0,9.5,10);
    %Blur                = 6 : 0.4 : 9;
    RealResolution    	= nan(size(Blur));
    EstResolutionH    	= nan(size(Blur));
    EstResolutionV  	= nan(size(Blur));
    
    %% Calculus of real resolution
for p = 1 : numel(Blur)

    %set correct blurring level
    Pref.Dist_BlurSigma = Blur(p);
  
	I_res       = QT_DistortImage( I_res_raw, Pref );
	I_imuni     = QT_DistortImage( I_imuni_raw, Pref );

    %load previously smoothed images
    %load(['QTBlurredImages\ResBlur_Size4167_Sigma',sprintf('%.2f',Blur(p)),'.mat'])

    % calculation of real resolution
    SynthRes    = 2*QT_GetSynthResolutionFromKernel2( Blur(p), 0.3 );
    
    %% Calculus of estimated resolution

    % Localization
    figure
    [CenterX, CenterY, Radius, AngleEst, ~] = GetPhantomCenter( I_res, Parameter, 1, 0, p );
    
    % SNR
    InnerMean  	= (2^Pref.AimBitDepth - 1) * Pref.ImageIntensity;
    
    %store SNR for resolution evaluation
    
    % Resolution
    Parameter.RES.GrayvalueVisibilityThreshold  = 0.3 * InnerMean;
    [Result_RES, Parameter] = MeasureResolution( I_res, Parameter );

   	fprintf(' ********************************* \n')
    fprintf(' **** L O C A L I Z A T I O N **** \n')
    fprintf(' ********************************* \n')
    %fprintf('   CenterX: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftXpx, CenterX)
    %fprintf('   CenterY: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftYpx, CenterY)
    %fprintf('    Radius: Real = %.2f | Estim. = %.2f\n', 0.5 * 2834 * Pref.AimResolution/RawImSize(1), Radius)
    %fprintf('     Angle: Real = %.2f | Estim. = %.2f\n', Pref.Dist_RotAngleDeg, AngleEst / pi * 180.0)
    fprintf(' ********************************* \n')
    fprintf(' ****   R E S O L U T I O N   **** \n')
    fprintf(' ********************************* \n')
    fprintf('   Horizontal: Real  = %.2f\n', Result_RES.MinResolveableDetailSizeH)
    fprintf('     Vertical: Real  = %.2f\n', Result_RES.MinResolveableDetailSizeV)
    fprintf('       Kernel: Ideal = %.2f\n', SynthRes);
    
    %store results
    RealResolution(p) 	= SynthRes;
    EstResolutionH(p) 	= Result_RES.MinResolveableDetailSizeH;
    EstResolutionV(p)	= Result_RES.MinResolveableDetailSizeV;
    
    close 1
    close 41
    
end

%adjust for resolution and pixelspacing according to ACR
RealVec  	= RealResolution * 256/Pref.AimResolution * 0.5;
EstVecH     = EstResolutionH * 256/Pref.AimResolution * 0.5 * 2;
EstVecV     = EstResolutionV * 256/Pref.AimResolution * 0.5 * 2;

save('QA Results\QA_ResFull.mat','EstVecH','EstVecV','RealVec')

figure
box on
grid off
hold on


%plot identity line
XRange   = max(RealVec) - min(RealVec);
YRange   = max([EstVecH,EstVecV]) - min([EstVecH,EstVecV]);

H1 = line(  [ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ], ...
    [ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ], ...
    'Linewidth',1,'Color',[0.5 0.5 0.5],'Linestyle','-');
H2 = plot( RealVec, EstVecH,'*','Marker','o','Markersize',7,'Linewidth',1,'Color','red' );
H3 = plot( RealVec, EstVecV,'*','Marker','x','Markersize',8,'Linewidth',1,'Color','blue' );

set(gcf,'OuterPosition' ,[436   338   484   352])
set(gcf,'Position'      ,[444   346   468   260])
set(gca,'OuterPosition' ,[-0.1603   -0.0115    1.2359    0.9923])
set(gca,'Position'      ,[0.1282    0.1538    0.8440    0.7462])

LegHandle   = legend([H1, H2, H3],'Identity','Est. vs. synth. hor. resolution','Est. vs. synth. ver. resolution');
set(LegHandle,'Interpreter','latex','Location','NorthWest')
set(LegHandle,'OuterPosition',  [0.1314    0.6415    0.5278    0.2410])
set(LegHandle,'Position',       [0.1400    0.6492    0.5150    0.2333])

xlim([ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ])
%ylim([ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ])

xlabel('Synthetic resolution $[mm]$','Interpreter','latex','Fontsize',10)
ylabel('Estimated resolution $[mm]$','Interpreter','latex','Fontsize',10)
title('\textbf{Spatial Resolution}','Interpreter','latex','Fontsize',12)

set(gca,'Fontsize',10)