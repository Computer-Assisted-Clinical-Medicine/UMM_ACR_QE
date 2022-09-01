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
    %Run final Localization evaluation, store and plot results

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

Pref.Perform_Rotation                               = 1;
Pref.Dist_RotAngleDeg    = 0.0;
    
Pref.Perform_Translation                            = 1;
Pref.Dist_ShiftXpx   	= 0.0;
Pref.Dist_ShiftYpx       = 0.0;
    
Pref.Perform_Ghosting                               = 0;    
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

Shift = linspace(0,40,10);
Angle = linspace(0,10,10);

EstCenterX      = nan(size(Shift));
EstCenterY      = nan(size(Shift));
EstRadius       = nan(size(Shift));
EstAngle        = nan(size(Shift));

RealCenterX      = nan(size(Shift));
RealCenterY      = nan(size(Shift));
RealRadius       = nan(size(Shift));
RealAngle        = nan(size(Shift));

for p = 1 : numel(Shift)

    Pref.Dist_RotAngleDeg 	= Angle(p);
    Pref.Dist_ShiftXpx   	= Shift(p);
    Pref.Dist_ShiftYpx    	= Shift(p);
    
    I = QT_DistortImage( I_res_raw, Pref );
    RawImSize   = size(I_res_raw);
    ImSize      = size(I);
    
    %% Localization
    [CenterX, CenterY, Radius, AngleEst, ~] = GetPhantomCenter( I, Parameter, 1, 0, p );
    

    fprintf(' ********************************* \n')
    fprintf(' **** L O C A L I Z A T I O N **** \n')
    fprintf(' ********************************* \n')
    fprintf('   CenterX: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftXpx, CenterX)
    fprintf('   CenterY: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftYpx, CenterY)
    fprintf('    Radius: Real = %.2f | Estim. = %.2f\n', 0.5 * 2834 * Pref.AimResolution/RawImSize(1), Radius)
    fprintf('     Angle: Real = %.2f | Estim. = %.2f\n', Pref.Dist_RotAngleDeg, AngleEst / pi * 180.0)

%     %Save the position paramters to be used as start values for upcoming
%     %calculations, if needed
%     Parameter.GEN.CenterX   = CenterX;
%     Parameter.GEN.CenterY   = CenterY;
%     Parameter.GEN.Radius    = Radius;
%     Parameter.GEN.Angle     = Angle;

    EstCenterX(p)       = CenterX;
    EstCenterY(p)       = CenterY;
    EstRadius(p)        = Radius;
    EstAngle(p)         = AngleEst / pi * 180.0;
    
    RealCenterX(p)      = Pref.AimResolution/2 + Pref.Dist_ShiftXpx;
    RealCenterY(p)      = Pref.AimResolution/2 + Pref.Dist_ShiftYpx;
    RealRadius(p)       = 0.5 * 2834 * Pref.AimResolution/RawImSize(1);
    RealAngle(p)        = Pref.Dist_RotAngleDeg;

end

%calculate estimate shifts and angles
EstShiftX           = EstCenterX - EstCenterX(1);
EstShiftY           = EstCenterY - EstCenterY(1);
EstShiftMean        = 0.5*(EstShiftX + EstShiftY);
RealShift           = Shift;

%save results
save('QA Results\QA_Localization.mat','EstShiftMean','RealShift','RealAngle','EstAngle')

%% Plot results

RealVec1   	= Shift;
EstVec1  	= EstShiftMean;

RealVec2   	= RealAngle;
EstVec2  	= EstAngle;

figure
box on
grid off
hold on

%plot identity line
XRange   = 10;
YRange   = 10;

H1 = line(  [ 0, 11 ], [ RealVec1(1) - RealVec1(2), RealVec1(10) + RealVec1(2) ], ...
    'Linewidth',1,'Color',[0.5 0.5 0.5],'Linestyle','-');
%plot estimated values against real values
%H2 = plot( RealVec1, EstVec1,'*','Marker','x','Markersize',7,'Linewidth',2,'Color','red' );

% [AX,H2,H3] = plotyy(    1:numel(RealVec1), EstVec1,...
%                         1:numel(RealVec2), EstVec2 );

[AX,H2,H3] = plotyy(    1:numel(RealVec1), EstVec1,...
                        1:numel(RealVec2), EstVec2 );

set(H2,'LineStyle','*','Marker','o','Markersize',8,'Linewidth',2,'Color','red' );    
set(H3,'LineStyle','*','Marker','x','Markersize',7,'Linewidth',1,'Color','blue' );  

YRange1     = max(RealVec1) - min(RealVec1);
YRange2     = max(RealVec2) - min(RealVec2);

set(AX(1),'Xlim',[ 0.5, 10.5 ])
set(AX(2),'Xlim',[ 0.5, 10.5 ])

set(AX(2),'XAxisLocation','top');

%set correct labels using two label cells
LabelsX1     = arrayfun(@(x) sprintf('%.1f',x),RealVec1,'UniformOutput',0);
LabelsX2     = arrayfun(@(x) sprintf('%.1f',x),RealVec2,'UniformOutput',0);

set(AX(1), 'XTickLabel',LabelsX1)
set(AX(2), 'XTickLabel',LabelsX2)

Color = 0;
if Color
    set(AX(1), 'XColor','red','YColor','red')
    set(AX(2), 'XColor','blue','YColor','blue')

    %set axis colors and labels
    set(get(AX(1),'Xlabel'),'String','Synthetic Translation $[px]$','Interpreter','latex','Fontsize',10,'Color','red')
    set(get(AX(1),'Ylabel'),'String','Estimated Translation $[px]$','Interpreter','latex','Fontsize',10,'Color','red')

    set(get(AX(2),'Xlabel'),'String','Synthetic Rotation $[deg]$','Interpreter','latex','Fontsize',10,'Color','blue')
    set(get(AX(2),'Ylabel'),'String','Estimated Rotation $[deg]$','Interpreter','latex','Fontsize',10,'Color','blue')
else
    set(AX(1), 'XColor','black','YColor','black','XGrid','on')
    set(AX(2), 'XColor','black','YColor','black')

    %set axis colors and labels
    set(get(AX(1),'Xlabel'),'String','Synthetic Translation $[px]$','Interpreter','latex','Fontsize',10,'Color','black')
    set(get(AX(1),'Ylabel'),'String','Estimated Translation $[px]$','Interpreter','latex','Fontsize',10,'Color','black')

    set(get(AX(2),'Xlabel'),'String','Synthetic Rotation $[deg]$','Interpreter','latex','Fontsize',10,'Color','black')
    set(get(AX(2),'Ylabel'),'String','Estimated Rotation $[deg]$','Interpreter','latex','Fontsize',10,'Color','black')

end

set(gcf,'OuterPosition' ,[294   440   566   373])
set(gcf,'Position'      ,[302   448   550   281])
set(AX(1),'OuterPosition' ,[-0.0855    0.0071    1.1109    0.9196])
set(AX(1),'Position'      ,[0.0764    0.1495    0.8455    0.7117])
set(AX(2),'OuterPosition' ,[-0.0655    0.0534    1.1382    0.9395])
set(AX(2),'Position'      ,[0.0764    0.1495    0.8455    0.7117])

set(AX(1),'Ylim',[min(RealVec1) - 0.1*YRange1, max(RealVec1) + 0.1*YRange1])
set(AX(2),'Ylim',[min(RealVec2) - 0.1*YRange2, max(RealVec2) + 0.1*YRange2])

LegHandle   = legend([H1, H2, H3],'Identity','Estimate vs. synth. Translation','Estimate vs. synth. Rotation');
set(LegHandle,'Interpreter','latex','Location','NorthWest')
set(LegHandle,'OuterPosition',  [0.0812    0.5907    0.4455    0.2467])
set(LegHandle,'Position',       [0.0885    0.5979    0.4345    0.2396])

%xlim([ 0.5, 10.5 ])
%ylim([ min(RealVec1) - 0.05 * abs(XRange), max(RealVec1) + 0.05 * abs(XRange) ])

%xlabel('Ideal parameter [a.u.]','Interpreter','latex','Fontsize',10)
%ylabel('Estimated parameter [a.u.]','Interpreter','latex','Fontsize',10)
%title('Quality Parameter','Fontweight','bold','Interpreter','latex','Fontsize',12)

set(gca,'Fontsize',10)