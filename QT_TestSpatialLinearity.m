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
    %Run final Spatial Linearity evaluation, store and plot results

ReMeasureLocations   = 1;
%if ReMeasureLocations is set to one, the locations of the undistorted
%image will be remeasured using the rescaled image without any further
%distortions

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

Pref.Perform_Rotation                               = 0;
Pref.Dist_RotAngleDeg    = 2.0;
    
Pref.Perform_Translation                            = 0;
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
Pref.Dist_BarrelLambda 	= 0.0005;

Pref.Perform_PolynomialDeformation                  = 1;
% Pref.Dist_PolynomialT  	= [ 0      	0; ...
%                             1      	0; ...
%                             0     	1; ...
%                             0       0; ...
%                             0    	0; ...
%                             0       0];

%read images

if ~exist('I_res_raw','var')
    I_res_raw       = double(imread('Quality Tests\PhantomDummy_Resolution.tif'));
    % I_spatlin_raw     = double(imread('Quality Tests\PhantomDummy_Uniformity.tif'));
    % I_spatlin_raw   = double(imread('Quality Tests\PhantomDummy_SpatialLinearity.tif'));
end

if ~exist('I_spatlin_raw','var')
    % I_res_raw       = double(imread('Quality Tests\PhantomDummy_Resolution.tif'));
    % I_spatlin_raw     = double(imread('Quality Tests\PhantomDummy_Uniformity.tif'));
    I_spatlin_raw   = double(imread('Quality Tests\PhantomDummy_SpatialLinearity.tif'));
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
    
    Parameter.SL.PixelSpacing   = 1.0;
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
        
    % generate template 
    switch ReMeasureLocations
        case 0
            %Use previously stored template positions
            load('QT_CenterCellSpatLin.mat')
            
        case 1
            %rescale original image
            I_template  = imresize(I_spatlin_raw, Pref.AimResolution/size(I_spatlin_raw,1));
            I_template 	= I_template * (2^Pref.AimBitDepth - 1)/255;
            I_template 	= round(I_template .* Pref.ImageIntensity);
            
            I_template_loc  = imresize(I_res_raw, Pref.AimResolution/size(I_spatlin_raw,1));
            I_template_loc 	= I_template_loc * (2^Pref.AimBitDepth - 1)/255;
            I_template_loc 	= round(I_template_loc .* Pref.ImageIntensity);
            
            Parameter_template                  = Parameter;
            Parameter_template.GEN.PlotVisible  = 'off';
            
            Parameter_template = DetermineThreshold( I_template_loc, Parameter_template ); %.GEN.Threshold

            %All position parameters such as center, radius and angle are determined
            %using the start values from the "raw" data given by the
            %DetermineThreshold-function; afterwards these startvalues will be replaced
            %by the accurate results which will be further used as startvalues

            [CenterX, CenterY, Radius, Angle, ~] = GetPhantomCenter( I_template_loc, Parameter_template, 1, 0, 1 );

            %Save the position paramters to be used as start values for upcoming
            %calculations, if needed
            Parameter_template.GEN.CenterX   = CenterX;
            Parameter_template.GEN.CenterY   = CenterY;
            Parameter_template.GEN.Radius    = Radius;
            Parameter_template.GEN.Angle     = Angle;

            % Measure spatial linearity
            [Result_SL_tem, Parameter_template] = MeasureSpatialLinearity( I_template, Parameter_template );
            
            %save grid data
            CenterCell = Result_SL_tem.GridData;
    end

%% Final calculations

% Shift 0 to 70, overall 8 steps
% Angle 0 to 10 degree, overall 8 steps

SpatialDistortion  	= [0.0, linspace(0.04e-3,0.3e-3,9)];

EstDistortion    	= nan(size(SpatialDistortion));
RealDistortion     	= nan(size(SpatialDistortion));
MeanPointError      = nan(size(SpatialDistortion));
STDPointError       = nan(size(SpatialDistortion));

for p = 1 : numel(SpatialDistortion)

    Pref.Dist_PolynomialT  	= [ 0           0; ...
                                1           0; ...
                                0           1; ...
                                0           0; ...
                                0           0; ...
                                SpatialDistortion(p)     0];  

    I_res       = QT_DistortImage( I_res_raw, Pref );
    I_spatlin  	= QT_DistortImage( I_spatlin_raw, Pref );
    
    RawImSize   = size(I_res_raw);
    ImSize      = size(I_res);
    
    %First of all, estimate the Threshold
    Parameter = DetermineThreshold( I_res, Parameter ); %.GEN.Threshold

    %All position parameters such as center, radius and angle are determined
    %using the start values from the "raw" data given by the
    %DetermineThreshold-function; afterwards these startvalues will be replaced
    %by the accurate results which will be further used as startvalues

    [CenterX, CenterY, Radius, Angle, ~] = GetPhantomCenter( I_res, Parameter, 1, 0, 1 );

    %Save the position paramters to be used as start values for upcoming
    %calculations, if needed
    Parameter.GEN.CenterX   = CenterX;
    Parameter.GEN.CenterY   = CenterY;
    Parameter.GEN.Radius    = Radius;
    Parameter.GEN.Angle     = Angle;
    
    % Measure spatial linearity
  	[Result_SL, Parameter] = MeasureSpatialLinearity( I_spatlin, Parameter );
    close(52)
        
    %The a template containing the ideal grid positions is
    %transformed with the same transformation. These grid positions should
    %be found by the automated procedure. The mean distance of the grid
    %points is an indicator of the accuracy of the method.
    
    set(0,'CurrentFigure',50)
    
    %Perform rotation, translation and transformation
    ErrorCell               = cell(size(CenterCell));
    ErrorVector             = nan(numel(CenterCell),1);
    
    ShiftVecX               = nan(numel(CenterCell),1);
    ShiftVecY               = nan(numel(CenterCell),1);

    %generate an image with high intensity pixels located at the center and
    %apply the spatial transformations to that image
    I_points                = zeros(size(I_spatlin));
    %write point locations

    for c = 1 : numel(CenterCell)
        if ~isempty(CenterCell{c})
            
            %read ideal data
            X   = CenterCell{c}(1);
            Y   = CenterCell{c}(2);
            
            I_points   = QT_WritePeakToImage( I_points, X, Y, 0.25 );
            
        end
    end 
    
    %apply transformations to image
    if Pref.Perform_Rotation
        I_points = imrotate(I_points, Pref.Dist_RotAngleDeg, 'bilinear', 'crop');
    end

    if Pref.Perform_Translation
        t = maketform('affine',[1 0 ; 0 1; Pref.Dist_ShiftXpx Pref.Dist_ShiftYpx]);
        I_points = imtransform(I_points,t,'XData',[1 size(I_points,2)],'YData',[1 size(I_points,1)]);
    end
    
    if Pref.Perform_PolynomialDeformation
        xybase = reshape(randn(12,1),6,2);
        t_poly = cp2tform(xybase,xybase,'polynomial',2);
        t_poly.tdata = Pref.Dist_PolynomialT;
        I_points = imtransform(I_points,t_poly,'FillValues',0,'Size',size(I_points),'XData',[1, size(I_points,2)],'YData',[1, size(I_points,1)]);
    end
    
    %now, iterate over all points that were found in the
    %MeasureSpatialLinearity method, find the corresponding point in I_points
    %and estimate the error
    
    SearchSize      = 10;
    RealErrorCell   = cell(size(Result_SL.GridData));
    for q = 1 : numel(Result_SL.GridData)
        if ~isempty(Result_SL.GridData{q})
            %find corresponding estimate point in I_points, 
            %i.e. the nearest point that exceeds 0.5
            %SearchMatX  = floor(Result_SL.GridData{q}(1)) - SearchSize/2;
            %SearchMatY  = floor(Result_SL.GridData{q}(2)) - SearchSize/2;
            
                            
            [y,x]       = find(I_points > 0.2);
            DistVec     = sqrt( (x-Result_SL.GridData{q}(1)).^2 + (y-Result_SL.GridData{q}(2)).^2 );
            MinIndex    = find(DistVec == min(DistVec),1,'first');
            CurDist     = DistVec(MinIndex);
            if CurDist > 2.0
               fprintf(2,'WARNING: Current distance > 2.0\n') 
            end
            
            SearchCenterX   = x(MinIndex);
            SearchCenterY   = y(MinIndex);
            
            SearchBorderX1  = SearchCenterX - SearchSize/2;
            SearchBorderX2  = SearchCenterX + SearchSize/2;
            SearchBorderY1  = SearchCenterY - SearchSize/2;
            SearchBorderY2  = SearchCenterY + SearchSize/2;
            
            %plot point and search area
            plot(SearchCenterX,SearchCenterY,'*r')
            DrawRectangle(  SearchBorderX1, SearchBorderX2, ...
                            SearchBorderY1, SearchBorderY2, 'blue' )
                
            SubMatrix       = I_points( SearchBorderY1 : SearchBorderY2, ...
                                        SearchBorderX1 : SearchBorderX2);
            [yInds,xInds]   = find(~isnan(SubMatrix));
            W               = SubMatrix(:);
            
            %get accurate peak position by averaging weighted indices
            xIdeal              = sum(W/sum(W) .* xInds) + SearchBorderX1 - 1;
            yIdeal              = sum(W/sum(W) .* yInds) + SearchBorderY1 - 1;
            RealErrorCell{q}    = [xIdeal,yIdeal];
            
            plot(xIdeal,yIdeal,'*y')
            
            %calculate and store error
            
            ErrorX =  xIdeal - Result_SL.GridData{q}(1);
            ErrorY =  yIdeal - Result_SL.GridData{q}(2);
            
            ShiftVecX(q)    = ErrorX;
            ShiftVecY(q)    = ErrorY;

            ErrorVector(q)   	= sqrt( ErrorX^2 + ErrorY^2 );
            
            ErrorCell{q}      	= [ErrorVector(q), ...
                              	atan(-(ErrorY)/(ErrorX))]; 
        	if MySign(-ErrorX) > 0
            	ErrorCell{q}(2) = ErrorCell{q}(2) + pi;
         	end
        
        end
    end

    ErrorVector(isnan(ErrorVector)) = [];
    
    ErrorMean                       = mean(ErrorVector);
    ErrorSTD                        = std(ErrorVector);
    ErrorMax                        = max(ErrorVector); 
    
    %finally we need to get the real amount of distortion in the images
    %therefore, we use the same procedures, but based on the real
    %distortions stored in RealErrorCell
    [ FinalCenterX, FinalCenterY, FinalGridSpace, FinalSlope ] = DetermineGridParameterByFit( RealErrorCell, CenterX, CenterY, Parameter );
    Result_SL_real.GridCenterX   = FinalCenterX;
    Result_SL_real.GridCenterY   = FinalCenterY;
    Result_SL_real.GridSpace     = FinalGridSpace;
    Result_SL_real.GridSlope     = FinalSlope;
    
    %disp('Result_SL after LinFit')
    %disp(Result_SL)
    
    %PostProcessing by IPPM
    [RealErrorCell, Result_SL_real] = IPPM( RealErrorCell, Result_SL_real );
    
    figure
    hold on
    PlotSpatialGrid( Result_SL_real.GridCenterX, Result_SL_real.GridCenterY, Result_SL_real.GridSpace, Result_SL_real.GridSpace, atan(Result_SL_real.GridSlope) )
    
    %Plot grid points
   	Mat = cell2mat(RealErrorCell(:));
  	plot(Mat(:,1), Mat(:,2), 'X','Linewidth',2,'Markersize',8,'Color','yellow')
    
    [GridErrorCell_real, GridErrorVector_real] = DetermineGridError( RealErrorCell, Result_SL_real, Parameter.SL.PixelSpacing );
    
    Result_SL_real.MaxError   = max(GridErrorVector_real);
    Result_SL_real.MinError   = min(GridErrorVector_real);
    Result_SL_real.MeanError  = mean(GridErrorVector_real);
    Result_SL_real.STDError   = std(GridErrorVector_real);
    
    %results
    fprintf(' ********************************* \n')
    fprintf(' **** L O C A L I Z A T I O N **** \n')
    fprintf(' ********************************* \n')
    fprintf('   CenterX: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftXpx, CenterX)
    fprintf('   CenterY: Real = %.2f | Estim. = %.2f\n', Pref.AimResolution/2 + Pref.Dist_ShiftYpx, CenterY)
    fprintf('    Radius: Real = %.2f | Estim. = %.2f\n', 0.5 * 2834 * Pref.AimResolution/RawImSize(1), Radius)
    %fprintf('     Angle: Real = %.2f | Estim. = %.2f\n', Pref.Dist_RotAngleDeg, AngleEst / pi * 180.0)
    fprintf(' ****************************************** \n')
    fprintf(' *** S P A T I A L   L I N E A R I T Y***** \n')
    fprintf(' ****************************************** \n')
    fprintf('Mean Error     = %.3f\n',ErrorMean)
    fprintf(' STD Error     = %.3f\n',ErrorSTD)
    fprintf('Max. Error     = %.3f\n',ErrorMax)
    
    %store all relevant results
    EstDistortion(p)   	= Result_SL.MeanError;
    RealDistortion(p) 	= Result_SL_real.MeanError;
    MeanPointError(p) 	= ErrorMean;
    STDPointError(p)   	= ErrorSTD;

end

%store results for final evaluation
save('QA Results\QA_SpatialLinearity.mat','EstDistortion','RealDistortion')

LH = QT_PlotEstimatesAgainstReal( EstDistortion, RealDistortion );

title('\textbf{Spatial Linearity}','Interpreter','latex','Fontsize',12)
set(LH,'String',{'Identity','Estimated vs. Synthetic'});
set(LH,'Interpreter','latex','Location','NorthWest')
set(LH,'OuterPosition',  [0.1303    0.7038    0.5085    0.1779])
set(LH,'Position',       [0.1389    0.7115    0.4957    0.1702])
xlabel('Synthetic Mean Distortion $[px]$','Interpreter','latex')
ylabel('Estimated Mean Distortion $[px]$','Interpreter','latex')
grid on
ylim([0 2])
