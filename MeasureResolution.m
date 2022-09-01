function [Result_RES, Parameter] = MeasureResolution( ImageInit, Parameter )

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

    %ImageInit   = Dataset.Image{Dataset.Index_RES};
    UseWeighting            = 0;
    ResolutionOverviewType  = 2;
    DetailPlot              = 1;
    %   1 = Using SubPlots
    %   2 = One plot containing both vertical and horizontal
    
    %Visualization in Paper: 1/ --> 11

    %This Method Performs the following steps for all three resolution
    %areas of the MRI-phantom
    %
    % 1)    Detect all 31 Objects 
    % 2)    Correlate the objects to the reference position
    % 3)    For the 2 subunits (upper left, lower right), extract the 4
    %       collumns and the 4 lines for MTF-evaluation
    % 4)    For each of the overall 2 * (4 + 4) = 16 MTF-Vectors, determine
    %       The maximum and minimum intensity and evaluate the MTF
    
    %Predefinition of all the variables being stored in the
    %Result_RES-struct
    
    %n x 2-matrices, each containing the peak and valley values with the
    %pixel distance
    Result_RES.MTFValuesV1 = [];
    Result_RES.MTFValuesH1 = [];
    Result_RES.MTFValuesV2 = [];
    Result_RES.MTFValuesH2 = [];
    Result_RES.MTFValuesV3 = [];
    Result_RES.MTFValuesH3 = [];
    
    %for all 3 resolution arrays and both vertical and horizontal direction
    %per array, the mean and std for the grayvalue difference AND mean and
    %std for the distance between peak and valley are stored
    
    %===========
    %= V1 & H1 =
    %===========
    Result_RES.V1_GrayDist_Mean = [];
    Result_RES.V1_GrayDist_STD  = [];
    Result_RES.V1_PeakDist_Mean = [];
    Result_RES.V1_PeakDist_STD  = [];
 
    Result_RES.H1_GrayDist_Mean = [];
    Result_RES.H1_GrayDist_STD  = [];
    Result_RES.H1_PeakDist_Mean = [];
    Result_RES.H1_PeakDist_STD  = [];
    
    %===========
    %= V2 & H2 =
    %===========
    Result_RES.V2_GrayDist_Mean = [];
    Result_RES.V2_GrayDist_STD  = [];
    Result_RES.V2_PeakDist_Mean = [];
    Result_RES.V2_PeakDist_STD  = [];
    
    Result_RES.H2_GrayDist_Mean = [];
    Result_RES.H2_GrayDist_STD  = [];
    Result_RES.H2_PeakDist_Mean = [];
    Result_RES.H2_PeakDist_STD  = [];
    
    %===========
    %= V3 & H3 =
    %===========
    Result_RES.V3_GrayDist_Mean = [];
    Result_RES.V3_GrayDist_STD  = [];
    Result_RES.V3_PeakDist_Mean = [];
    Result_RES.V3_PeakDist_STD  = [];
    
    Result_RES.H3_GrayDist_Mean = [];
    Result_RES.H3_GrayDist_STD  = [];
    Result_RES.H3_PeakDist_Mean = [];
    Result_RES.H3_PeakDist_STD  = [];    
    
    %==============
    %= Fit Params =
    %==============
    Result_RES.MinResolveableDetailSizeH = [];
    Result_RES.FitResultH   = [];
    Result_RES.FitGoFH      = [];
    Result_RES.MinResolveableDetailSizeV = [];
    Result_RES.FitResultV   = [];
    Result_RES.FitGoFV      = [];

    
    %only for testing purpose
    Test = 0;
    if Test == 1
        clc
        clear all
        close all

        DatasetIndex = 2;
        switch DatasetIndex
            case 1
                DatasetName = 'MANNHEIM - 062000000006 (SIEMENS) - 2009-06-03_17_46_11.0 - 2009-06-03_17_46_11.0 - SessionB - QC_T2.mat';
            case 2
                DatasetName = 'BERLIN - 041000000400 (SIEMENS) 2011-04-13_16_45_57.0 - SessionA - T2.mat';

        end
        Dataset     = load(['Phantom Datasets/',DatasetName]);
        Dataset     = Dataset.Dataset;

        % Only for testing purpose
        ImageInit   = Dataset.Image{Dataset.Index_RES};

        % General
        Parameter.GEN.SaveFolder            = DatasetName(1 : end - 3);
        Parameter.GEN.SavePath              = ['Phantom Results/', DatasetName(1 : end - 4) ];
        Parameter.GEN.Threshold             = 1000;         %DEFAULT, will be changed
        Parameter.GEN.Angle                 = 0;            %DEFAULT, will be changed

        %Start Values for Center
        Parameter.GEN.CenterX               = nan;
        Parameter.GEN.CenterY               = nan;
        Parameter.GEN.Radius                = nan;
        
        Parameter.RES.AdjustPeakByFit       = 0;
        
        %Angle = 0.018676;
    end
    
    %determine the position and the radius of the phantom in the image
    [CenterX, CenterY,  Radius  , ~, ~] = GetPhantomCenter( ImageInit,  Parameter, 0, 0, 41 );
    
    %store the three values in the Result_RES-struct
    Result_RES.CenterX   = CenterX;
    Result_RES.CenterY   = CenterY;
    Result_RES.Radius    = Radius;
    
    %calculate ProfileRegionRadius (which is the radius of the area, in which 
    %the peak-position can be adjusted such, that the maximum of the peak-profile is found)
    ProfileRegionRadius  = round(Parameter.RES.RelProfileRegionRadius * Radius);
    Angle                = Parameter.GEN.Angle;
    
    %relative positions (with the center of the phantom defined as the
    %origin) of the three resolution arrays of the phantom
    % --> given by (x, y)
    ROICenter  =   [    -0.1472    0.4015 ; ...
                        0.0991     0.4015 ; ...
                        0.3390     0.4015  ];
     
    %iterate over all three resolution-arrays
    for ROIIndex = 1 : 3
        
        %Set Initial Image
        Image = ImageInit;
        
        if DetailPlot
            figure(41 + ROIIndex)
            set(41 + ROIIndex, 'Visible', Parameter.GEN.PlotVisible)
            set(gcf,'Position',[413, 19, 1202, 735])
            set(gcf,'OuterPosition',[405, 11, 1218, 827])
        end
        
        %get the positions of the four ROIs surround one resolution array based
        %on the predefined ROICenter-array and the center and radius values
        %of the phantom, thats calculated for each phantom individually.
        %The four regions are than used to remove the grayvalue 
        UpLeft  =  [ (ROICenter(ROIIndex,1) - Parameter.RES.RelRegionSizeRadius) * Radius + CenterX , ...
                     (ROICenter(ROIIndex,2) - Parameter.RES.RelRegionSizeRadius) * Radius + CenterY   ];
        UpRight =  [ (ROICenter(ROIIndex,1) + Parameter.RES.RelRegionSizeRadius) * Radius + CenterX , ...
                     (ROICenter(ROIIndex,2) - Parameter.RES.RelRegionSizeRadius) * Radius + CenterY   ];        
        LowLeft =  [ (ROICenter(ROIIndex,1) - Parameter.RES.RelRegionSizeRadius) * Radius + CenterX , ...
                     (ROICenter(ROIIndex,2) + Parameter.RES.RelRegionSizeRadius) * Radius + CenterY   ];        
        LowRight=  [ (ROICenter(ROIIndex,1) + Parameter.RES.RelRegionSizeRadius) * Radius + CenterX , ...
                     (ROICenter(ROIIndex,2) + Parameter.RES.RelRegionSizeRadius) * Radius + CenterY   ]; 
              
        %rotate the points according to the angular position of the phantom
        [ UpLeft(1),   UpLeft(2)   ] = AdjustAngle( UpLeft(1),   UpLeft(2),   CenterX, CenterY, -Angle );
        [ UpRight(1),  UpRight(2)  ] = AdjustAngle( UpRight(1),  UpRight(2),  CenterX, CenterY, -Angle );
        [ LowLeft(1),  LowLeft(2)  ] = AdjustAngle( LowLeft(1),  LowLeft(2),  CenterX, CenterY, -Angle );
        [ LowRight(1), LowRight(2) ] = AdjustAngle( LowRight(1), LowRight(2), CenterX, CenterY, -Angle );
        
        %round values to match the real pixel values
        UpLeft   = round(UpLeft);
        UpRight  = round(UpRight);
        LowLeft  = round(LowLeft);
        LowRight = round(LowRight);

        %calculate the mean values of each corner ROI
        UpLeftMean      = mean(GetCircularROI( Image, UpLeft(1),   UpLeft(2),   Parameter.RES.RelGradientAreaRadius * Radius ));
        UpRightMean     = mean(GetCircularROI( Image, UpRight(1),  UpRight(2),  Parameter.RES.RelGradientAreaRadius * Radius ));
        LowLeftMean     = mean(GetCircularROI( Image, LowLeft(1),  LowLeft(2),  Parameter.RES.RelGradientAreaRadius * Radius ));
        LowRightMean    = mean(GetCircularROI( Image, LowRight(1), LowRight(2), Parameter.RES.RelGradientAreaRadius * Radius ));
                     
        %get the corner points of the whole area being defined by the ROI
        %center points. inside of this area, the gray value gradient, if
        %existing, is being removed. The gradient (of the layer) is defined
        %by the four ROI-mean-values of the corners, points in between
        %these four points will be interpolated
        RangeX1 = min([UpLeft(1), UpRight(1), LowLeft(1), LowRight(1)]);
        RangeX2 = max([UpLeft(1), UpRight(1), LowLeft(1), LowRight(1)]);
        RangeY1 = min([UpLeft(2), UpRight(2), LowLeft(2), LowRight(2)]);
        RangeY2 = max([UpLeft(2), UpRight(2), LowLeft(2), LowRight(2)]);  
        
        %remove gradient, if Parameter.RES.RemoveGrayValueGradient is set
        %to 1
        if Parameter.RES.RemoveGrayValueGradient == 1
            Image = RemoveGrayvalueGradient( Image, UpLeftMean,   UpLeft(1),   UpLeft(2), ...
                                                    UpRightMean,  UpRight(1),  UpRight(2), ...
                                                    LowLeftMean,  LowLeft(1),  LowLeft(2), ...
                                                    LowRightMean, LowRight(1), LowRight(2), ...
                                                    RangeX1, RangeX2, ...
                                                    RangeY1, RangeY2 );
        end
        
        %subplot
        if DetailPlot
            SP  = (ones(8,1) * (1:8) + (0:7)' * 24 * ones(1,8))';
            SPImageHandle = subplot(8,24,SP(:));

            hold on

            %show the image in the figure
            imshow(Image, 'DisplayRange', [min(min(Image)) max(max(Image))]);
            set(gca,'Position',[0.0483, 0.1100, 0.3349, 0.8150])
            set(gca,'OuterPosition',[0.0225, 0.0940, 0.3706, 0.8398])

            %plot 4 circles representing the 4 ROIs
            DrawCircle( UpLeft(1),   UpLeft(2),   Parameter.RES.RelGradientAreaRadius * Radius, 'red' )
            DrawCircle( UpRight(1),  UpRight(2),  Parameter.RES.RelGradientAreaRadius * Radius, 'red' )
            DrawCircle( LowLeft(1),  LowLeft(2),  Parameter.RES.RelGradientAreaRadius * Radius, 'red' )
            DrawCircle( LowRight(1), LowRight(2), Parameter.RES.RelGradientAreaRadius * Radius, 'red' )

            %for each ROI plot the center in the circle as well
            plot(UpLeft(1),  UpLeft(2),  'X','Color','red','Linewidth',2)
            plot(UpRight(1), UpRight(2), 'X','Color','red','Linewidth',2)
            plot(LowLeft(1), LowLeft(2), 'X','Color','red','Linewidth',2)
            plot(LowRight(1),LowRight(2),'X','Color','red','Linewidth',2)
        else
            SPImageHandle = [];
        end
                                                    
        CurrentROI      = Image(RangeY1 : RangeY2, RangeX1 : RangeX2);
        Threshold       = kmeans(CurrentROI);
        [y,x]           = find(CurrentROI >= Threshold);
        ObjectCenterX   = RangeX1 + mean(x) - 1;
        ObjectCenterY   = RangeY1 + mean(y) - 1;
        
        if DetailPlot
            plot(ObjectCenterX,  ObjectCenterY,  'O','Color','yellow','Linewidth',2)
        end
        
        ProfileFitResults   = cell(31,1);
        ProfileFitGoF       = cell(31,1);

        if Parameter.RES.AdjustPeak == 2
            A               = nan(31,1);
            Aoff            = nan(31,1);
            Sigma           = nan(31,1);
            Gamma           = nan(31,1);
            
            %Precalculation of Offset
            GlobalThresh   = kmeans(CurrentROI);
            GlobalOffset   = mean(CurrentROI(CurrentROI < GlobalThresh));
        end
        
        %To sort the peaks one after another, a reference matrix is being used
        ResLocaterRel = load(['ResLoc',num2str(ROIIndex),'Temp.mat']);
        ResLocaterRel = ResLocaterRel.ResLocTemp;
        [ySize,xSize] = size(ResLocaterRel);
        PosMat  = nan(ySize * xSize, 4);
        Counter = 1;
        for yInd = 1 : ySize
            for xInd = 1 : xSize
                if ~isempty(ResLocaterRel{yInd,xInd})
                    PosMat(Counter, 1) = ResLocaterRel{yInd,xInd}(1);
                    PosMat(Counter, 2) = ResLocaterRel{yInd,xInd}(2);
                    PosMat(Counter, 3) = xInd;
                    PosMat(Counter, 4) = yInd;
                    Counter = Counter + 1; 
                end
            end 
        end
        PosMat( Counter : end, : ) = [];
        PosMat                     = PosMat .* (ones(length(PosMat),1) * [Radius Radius 1 1]) + ones(length(PosMat),1) * [CenterX, CenterY, 0, 0];
        [PosMat(:,1) PosMat(:,2)]  = AdjustAngle( PosMat(:,1), PosMat(:,2), CenterX, CenterY, -Angle );
        PeaksCell = cell(ySize,xSize);
        
        [PosMatAdj, ~, ~]   = OptimizeResolutionGrid( Image, PosMat );
        PosMat(:,1:2)                       = PosMatAdj;
        %disp(['Resolution Optimized | ShiftXMax = ',num2str(ShiftXMax),'; ShiftYMax = ',num2str(ShiftYMax)])

        % ==================================================== %
        % =====   I T E R A T E   O V E R   P E A K S    ===== %
        % ==================================================== %
        
        for ProfileCounter = 1 : 31

            plot(PosMat(ProfileCounter,1), PosMat(ProfileCounter,2), 'O','Linewidth',2,'Color','yellow')
            
            if Parameter.RES.AdjustPeak == 1
                ProfileROI                 = Image(round(PosMat(ProfileCounter,2)) - ProfileRegionRadius : round(PosMat(ProfileCounter,2)) + ProfileRegionRadius , ...
                                                   round(PosMat(ProfileCounter,1)) - ProfileRegionRadius : round(PosMat(ProfileCounter,1)) + ProfileRegionRadius  );  
                [ProfileYRel, ProfileXRel] = find(ProfileROI == max(max(ProfileROI)), 1, 'first');
                ProfileXAbs                = ProfileXRel - ProfileRegionRadius - 1 + round(PosMat(ProfileCounter,1));
                ProfileYAbs                = ProfileYRel - ProfileRegionRadius - 1 + round(PosMat(ProfileCounter,2));
            elseif Parameter.RES.AdjustPeak == 2
                
                ProfileXAbs                = PosMat(ProfileCounter,1);
                ProfileYAbs                = PosMat(ProfileCounter,2);

            % ==================================================== %
            % =====      A D J U S T      B Y     F I T      ===== %
            % ==================================================== %
                
                FitRadius     = ceil(Parameter.RES.RelProfileRegionRadius * Radius);
                ProfileRegion = Image( round(ProfileYAbs) - FitRadius : round(ProfileYAbs) + FitRadius, ... 
                                       round(ProfileXAbs) - FitRadius : round(ProfileXAbs) + FitRadius );
                                
                ProfileXRel                = ProfileXAbs + FitRadius + 1 - round(ProfileXAbs);
                ProfileYRel                = ProfileYAbs + FitRadius + 1 - round(ProfileYAbs);
                
                [yVec, xVec]    = find(~isnan(ProfileRegion));
                zVec            = ProfileRegion(:);

                %Perform Fit
                % Initialization.

                % Fit: 'untitled fit 1'.
                FitType =   fittype(    '(A - Aoff) * exp(-sqrt((x - xCenter)^2 + (y - yCenter)^2)^Gamma/Sigma) + Aoff', ...
                                        'indep', {'x', 'y'}, ... 
                                        'depend', 'z' );
                FitOpt  = fitoptions( FitType );
                FitOpt.Display = 'Off';

                CB  = 2 * ProfileRegionRadius + 1;
                AS  = max(max(ProfileRegion));
                AOS = GlobalOffset;

                PeakArea          = Parameter.RES.PeakFitArea(ROIIndex) * Radius;
                %Fit Parameter            A       Aoff          Gamma       Sigma   xCenter                 yCenter 
                FitOpt.Lower      =   [   0       AOS-0.1       0           0       ProfileXRel - PeakArea  ProfileYRel - PeakArea  ];
                FitOpt.StartPoint =   [   AS      AOS           2           3.5     ProfileXRel             ProfileYRel             ];
                FitOpt.Upper      =   [   2*AS    AOS+0.1       Inf         100     ProfileXRel + PeakArea  ProfileYRel + PeakArea  ];
                
                if UseWeighting
                    %some advanced weighting prefs: make larger weight to high
                    %and small values, and decreasing the weight of the values
                    %in between
                    WeightOffset      = 0.0;
                    MinValue          = min(zVec);
                    MaxValue          = max(zVec);
                    MeanVec           = 0.5 * (MinValue + MaxValue);
                    WeightFunction    = @(z) WeightOffset + abs(z - MeanVec)/(MaxValue - MeanVec) * (1 - WeightOffset);
                    FitOpt.Weights    = WeightFunction(zVec);
                end

                [FitResult, GoF]    = fit( [xVec, yVec], zVec, FitType, FitOpt );

                %plot(ProfileXAbs + FitResult.xCenter - ProfileRegionRadius - 1, ProfileYAbs + FitResult.yCenter - ProfileRegionRadius - 1, 'X','Linewidth',2,'Color','red')

                A(ProfileCounter)       = FitResult.A;
                Aoff(ProfileCounter)    = FitResult.Aoff;
                Sigma(ProfileCounter)   = FitResult.Sigma;
                Gamma(ProfileCounter)   = FitResult.Gamma;
                
                ProfileXRel             = FitResult.xCenter;
                ProfileYRel             = FitResult.yCenter;
                
                %Plot fit with data.
                %figure( ProfileCounter );
                %h = plot( FitResult, [xVec, yVec], zVec );
                %legend( h, 'untitled fit 1', 'zVec vs. xVec, yVec', 'Location', 'NorthEast' );

                ProfileFitResults{ProfileCounter}   = FitResult;
                ProfileFitGoF{ProfileCounter}   	= GoF;
                
                %Adjust Values of CurrentProfileROI
                %CurrentROI( max(ProfileYAbs - ProfileRegionRadius, 1) : min(ProfileYAbs + ProfileRegionRadius, 2 * Parameter.RES.RelRegionSizeRadius + 1), ... 
                %            max(ProfileXAbs - ProfileRegionRadius, 1) : min(ProfileXAbs + ProfileRegionRadius, 2 * Parameter.RES.RelRegionSizeRadius + 1)) ...
                %        = GlobalOffset;   
                
                %draw area that was used for peak search

                %plot(FitResult.xCenter, FitResult.yCenter, 'X','Linewidth',2,'Color','red')
                
                %Set new profile positions
                %ProfileXAbs                = ProfileXAbs - FitRadius + FitResult.xCenter - 1;
                %ProfileYAbs                = ProfileYAbs - FitRadius + FitResult.yCenter - 1;
                
                ProfileXAbs                = ProfileXRel - FitRadius - 1 + round(ProfileXAbs);
                ProfileYAbs                = ProfileYRel - FitRadius - 1 + round(ProfileYAbs);
                
                DrawRectangle(  PosMat(ProfileCounter,1) - PeakArea, PosMat(ProfileCounter,1) + PeakArea, ...
                                PosMat(ProfileCounter,2) - PeakArea, PosMat(ProfileCounter,2) + PeakArea, 'blue' )
                            
            else
                ProfileXAbs                = PosMat(ProfileCounter,1);
                ProfileYAbs                = PosMat(ProfileCounter,2);
                            
            end
            % ==================================================== %
            % ==================================================== %
            % ==================================================== %  
            
            %this are the final positions of each peak
            if DetailPlot
                plot(ProfileXAbs, ProfileYAbs, 'X','Linewidth',2,'Markersize',8,'Color','red')
            end
            
            %Show Results
            %disp(['i = ',num2str(ProfileCounter),' :: A = ',num2str(FitResult.A),'; Sigma = ',num2str(FitResult.Sigma),'; Gamma = ',num2str(FitResult.Gamma)])

            %Save the current Position of the Peak in the correct Position of
            %the PeaksCell by finding the nearest element of the RefMatrix
            
            PeaksCell{ PosMat( ProfileCounter,4 ), PosMat( ProfileCounter,3 ) }(1) = ProfileXAbs ;
            PeaksCell{ PosMat( ProfileCounter,4 ), PosMat( ProfileCounter,3 ) }(2) = ProfileYAbs ;

            pause(0.01)
            
        end

        %Summary of all Fits
        if Parameter.RES.AdjustPeak == 2
            Result_RES.AMean        = mean(A);
            Result_RES.AoffMean     = mean(Aoff);
            Result_RES.SigmaMean    = mean(Sigma);
            Result_RES.GammaMean    = mean(Gamma);

            Result_RES.ASTD         = std(A);
            Result_RES.AoffSTD      = std(Aoff);
            Result_RES.SigmaSTD     = std(Sigma);
            Result_RES.GammaSTD     = std(Gamma);

            [Result_RES.ARobMean,     Result_RES.ARobSTD]       = RobustMean( A );
            [Result_RES.AoffRobMean,  Result_RES.AoffRobSTD]    = RobustMean( Aoff );
            [Result_RES.SigmaRobMean, Result_RES.SigmaRobSTD]   = RobustMean( Sigma );
            [Result_RES.GammaRobMean, Result_RES.GammaRobSTD]   = RobustMean( Gamma );
        end

        %MTF Calculalation
        PeaksSubCell1    = PeaksCell( 1:4 , 1:4 );
        PeaksSubCell1T   = PeaksSubCell1';
        PeaksSubCell2    = PeaksCell( 4:7 , 4:7 );
        PeaksSubCell2T   = PeaksSubCell2';
        MTFVectors  = cell(16,1);
        MTFValuesV  = nan(8,2);
        MTFValuesH  = nan(8,2);
        
        %Adjust xlim and ylim
        CenterPeak  = PeaksCell{ 4 , 4 };
        CenterPeakX = CenterPeak(1);
        CenterPeakY = CenterPeak(2);
        if DetailPlot
            xlim([CenterPeakX - 0.18 * Radius, CenterPeakX + 0.18 * Radius])
            ylim([CenterPeakY - 0.18 * Radius, CenterPeakY + 0.18 * Radius])
        end
        
        %ROImin  = min(min(Image(min(UpLeft(1),LowLeft(1)) : max(UpRight(1),LowRight(1)) , ...
        %                        min(UpLeft(2),UpRight(2)) : max(LowLeft(2),LowRight(2)))));
        %ROImax  = max(max(Image(min(UpLeft(1),LowLeft(1)) : max(UpRight(1),LowRight(1)) , ...
        %                        min(UpLeft(2),UpRight(2)) : max(LowLeft(2),LowRight(2)))));                    
                            
        if DetailPlot
            set(gca,'CLimMode','manual','CLim',[0 max(max(Image(round(CenterPeakY - 0.18 * Radius) : round(CenterPeakY + 0.18 * Radius), ...
                                                                round(CenterPeakX - 0.18 * Radius) : round(CenterPeakX + 0.18 * Radius))))])

            %Set Title
            title(['Resolution Grid #',num2str(ROIIndex)])
        end
        %set to one, if MTF-results should be printed to the command window
        Output = 0;
        
        % ==================================================== %
        % =====   C R E A T E    M T F - V E C T O R S   ===== %
        % ==================================================== %
        
        %for each resolution array, there are four iterations, one for each
        %row/column of both the upper left sub-array AND the lower right
        %sub-array
        for Index = 1 : 4
            
            %for each the following 4 "substeps", the same calculation is
            %done:
            %
            % 1)    get the PeakCell-elements according to the current row
            %       or column
            % 2)    get the pixel-line-vector according to these peaks
            %       (see also MatrixLineRootMTF-comments)
            % 3)    calculate the mean of the distvec and the mean distance
            %       between the minima and maxima, which represents the 
            %       actual resolution according to the 
            %       modulation-transfer-function (MTF)
            
            %==================
            %== Upper Column ==
            %==================
            UpperCol             = cell2mat(PeaksSubCell1(:,Index));
            [ MTFVectors{Index}, MinVec, MaxVec, DistVec ] = MatrixLineRootMTF( Image, UpperCol(:,1), UpperCol(:,2), SPImageHandle );
            DistVec              = DistVec * Parameter.RES.PixelSpacing;
            MTFValuesV(Index, 1) = 2*mean(DistVec);
            MTFValuesV(Index, 2) = mean(MaxVec) - mean(MinVec);
            if Output == 1
                disp([' Upper Column ',num2str(Index),':'])
                disp(['Max : ',num2str(MaxVec')])
                disp(['Min : ',num2str(MinVec')])
                disp(['Dist: ',num2str(DistVec')])
            end
            
                %Plot
                if DetailPlot
                    subplot( 8,24, (10 : 16) + (Index - 1) * 24 )
                    bar(MTFVectors{Index})
                end
            %==================
            %==  Upper Row   ==
            %==================
            UpperRow             = cell2mat(PeaksSubCell1T(:,Index));
            [ MTFVectors{Index + 4}, MinVec, MaxVec, DistVec ] = MatrixLineRootMTF( Image, UpperRow(:,1), UpperRow(:,2), SPImageHandle );
            DistVec              = DistVec * Parameter.RES.PixelSpacing;
            MTFValuesH(Index, 1) = 2*mean(DistVec);
            MTFValuesH(Index, 2) = mean(MaxVec) - mean(MinVec);
            if Output == 1
                disp([' Upper Row ',num2str(Index),':'])
                disp(['Max: ',num2str(MaxVec')])
                disp(['Min: ',num2str(MinVec')])
                disp(['Dist: ',num2str(DistVec')])
            end
                %Plot
                if DetailPlot
                    subplot( 8,24, (18 : 24) + (Index - 1) * 24 )
                    bar(MTFVectors{Index + 4})        
                end
            %==================
            %==  Lower Colum ==
            %==================
            LowerCol                    = cell2mat(PeaksSubCell2(:,Index));
            [ MTFVectors{Index + 8}, MinVec, MaxVec, DistVec ] = MatrixLineRootMTF( Image, LowerCol(:,1), LowerCol(:,2), SPImageHandle );
            DistVec                     = DistVec * Parameter.RES.PixelSpacing;
            MTFValuesV(Index + 4, 1)    = 2*mean(DistVec);
            MTFValuesV(Index + 4, 2)    = mean(MaxVec) - mean(MinVec);
            if Output == 1
                disp([' Lower Column ',num2str(Index),':'])
                disp(['Max: ',num2str(MaxVec')])
                disp(['Min: ',num2str(MinVec')])
                disp(['Dist: ',num2str(DistVec')])
            end
            
                %Plot
                if DetailPlot
                    subplot( 8,24, (10 : 16) + (Index + 4 - 1) * 24 )
                    bar(MTFVectors{Index + 8})      
                end

            %==================
            %==  Lower Row   ==
            %==================
            LowerRow                    = cell2mat(PeaksSubCell2T(:,Index));
            [ MTFVectors{Index + 12}, MinVec, MaxVec, DistVec ] = MatrixLineRootMTF( Image, LowerRow(:,1), LowerRow(:,2), SPImageHandle );
            DistVec                     = DistVec * Parameter.RES.PixelSpacing;
            MTFValuesH(Index + 4, 1)    = 2*mean(DistVec);
            MTFValuesH(Index + 4, 2)    = mean(MaxVec) - mean(MinVec);
            if Output == 1
                disp([' Lower Row ',num2str(Index),':'])
                disp(['Max: ',num2str(MaxVec')])
                disp(['Min: ',num2str(MinVec')])
                disp(['Dist: ',num2str(DistVec')])
            end
            
                %Plot
                if DetailPlot
                    subplot( 8,24, (18 : 24) + (Index + 4 - 1) * 24 )
                    bar(MTFVectors{Index + 12})  
                end

        end
        
        %Store results
        Result_RES.(['MTFValuesV',num2str(ROIIndex)]) = MTFValuesV;
        Result_RES.(['MTFValuesH',num2str(ROIIndex)]) = MTFValuesH;
        
        Result_RES.(['V',num2str(ROIIndex),'_GrayDist_Mean']) = mean(MTFValuesV(:,2));
        Result_RES.(['V',num2str(ROIIndex),'_GrayDist_STD'])  = std( MTFValuesV(:,2));
        Result_RES.(['V',num2str(ROIIndex),'_PeakDist_Mean']) = mean(MTFValuesV(:,1));
        Result_RES.(['V',num2str(ROIIndex),'_PeakDist_STD'])  = std( MTFValuesV(:,1));
        
        Result_RES.(['H',num2str(ROIIndex),'_GrayDist_Mean']) = mean(MTFValuesH(:,2));
        Result_RES.(['H',num2str(ROIIndex),'_GrayDist_STD'])  = std( MTFValuesH(:,2));
        Result_RES.(['H',num2str(ROIIndex),'_PeakDist_Mean']) = mean(MTFValuesH(:,1));
        Result_RES.(['H',num2str(ROIIndex),'_PeakDist_STD'])  = std( MTFValuesH(:,1));      
        
    end
    
    %now, perform a linear fit for both the vertical and horizontal
    %resolution values, get the crosssection point with the
    %ResolutionThreshold (200 by default) and use this crosssection as the 
    %smallest visible detailed, which can be resolved
    
    FitType = fittype('m*x + n','dependent',{'y'}, ...
                                'independent',{'x'}, ...
                                'coefficients',{'m', 'n'});
    
    %Horizontal Values
    AllHorizontal   = [Result_RES.MTFValuesH1; Result_RES.MTFValuesH2; Result_RES.MTFValuesH3];
    AllHorizontalX  = AllHorizontal(:,1);
    AllHorizontalY  = AllHorizontal(:,2);
    
    %Start value determination
    PointH1x        = mean(Result_RES.MTFValuesH1(:,1));
    PointH1y        = mean(Result_RES.MTFValuesH1(:,2));
    
    PointH3x        = mean(Result_RES.MTFValuesH3(:,1));
    PointH3y        = mean(Result_RES.MTFValuesH3(:,2));
    
    % m = (y1-y2)/(x1-x2)
    % y = mx + n
    % --> n = y - mx
    m_H             = (PointH3y - PointH1y) / (PointH3x - PointH1x);
    n_H             = PointH1y - m_H * PointH1x;
    
    [CurveFitH,GoFH]    = fit(AllHorizontalX,AllHorizontalY,FitType,'Startpoint',[m_H, n_H]);
    
    %Vertical Values
    AllVertical     = [Result_RES.MTFValuesV1; Result_RES.MTFValuesV2; Result_RES.MTFValuesV3];
    AllVerticalX    = AllVertical(:,1);
    AllVerticalY  	= AllVertical(:,2);
    
    %Start value determination
    PointV1x        = mean(Result_RES.MTFValuesV1(:,1));
    PointV1y        = mean(Result_RES.MTFValuesV1(:,2));
    
    PointV3x        = mean(Result_RES.MTFValuesV3(:,1));
    PointV3y        = mean(Result_RES.MTFValuesV3(:,2));
    
    % m = (y1-y2)/(x1-x2)
    % y = mx + n
    % --> n = y - mx
    m_V             = (PointV3y - PointV1y) / (PointV3x - PointV1x);
    n_V             = PointV1y - m_V * PointV1x;
    
    [CurveFitV,GoFV]    = fit(AllVerticalX,AllVerticalY,FitType,'Startpoint',[m_V, n_V]);
    
    %Now, get the crosssection points for both horizonatal and vertical
    %resolution
    
    %TH = m*xTH + n --> xTH = (TH - n)/m
    MinResolveableDetailSizeH = 0.5 * (Parameter.RES.GrayvalueVisibilityThreshold - CurveFitH.n)/CurveFitH.m;
    MinResolveableDetailSizeV = 0.5 * (Parameter.RES.GrayvalueVisibilityThreshold - CurveFitV.n)/CurveFitV.m;
    
    Result_RES.MinResolveableDetailSizeH    = MinResolveableDetailSizeH;
    Result_RES.FitResultH                   = CurveFitH;
    Result_RES.FitGoFH                      = GoFH;
    
    Result_RES.MinResolveableDetailSizeV    = MinResolveableDetailSizeV;
    Result_RES.FitResultV                   = CurveFitV;
    Result_RES.FitGoFV                      = GoFV;
    
    
    %open new figure for the resolution overview
    figure(45)
    if ResolutionOverviewType == 1
        %plot horizontal and vertical results in two seperated subplots
        set(45, 'Visible', Parameter.GEN.PlotVisible)

        subplot(4,10,1:20)
        hold on
        box on
        title(['Horizontal Resolution: Smallest Resolvable Detail = ',num2str(MinResolveableDetailSizeH)])
        ylabel('Grayvalue Difference [bit]')

        %plot fit
        xMinH  = min(AllHorizontalX);
        xMaxH  = max(AllHorizontalX);
        Hplot4 = line([xMinH, xMaxH],[CurveFitH(xMinH), CurveFitH(xMaxH)],'Linewidth',1.5,'Color',[1 0.7 0],'Linestyle','--');
        Hplot5 = line([xMinH, xMaxH],[Parameter.RES.GrayvalueVisibilityThreshold, Parameter.RES.GrayvalueVisibilityThreshold],'Linewidth',1.5,'Color',[0.25 0.55 0],'Linestyle','--');

        Hplot1 = plot(Result_RES.MTFValuesH1(:,1),Result_RES.MTFValuesH1(:,2),'X','Color','red','Linewidth',3);
        Hplot2 = plot(Result_RES.MTFValuesH2(:,1),Result_RES.MTFValuesH2(:,2),'X','Color','green','Linewidth',3);
        Hplot3 = plot(Result_RES.MTFValuesH3(:,1),Result_RES.MTFValuesH3(:,2),'X','Color','blue','Linewidth',3);

        LegHandle = legend([Hplot1, Hplot2, Hplot3, Hplot4, Hplot5],'Horizontal MTF 1','Horizontal MTF 2','Horizontal MTF 3','Linear Fit',['Threshold = ',num2str(Parameter.RES.GrayvalueVisibilityThreshold)]);
        set(LegHandle,'Location','NorthWest')   
        xlim([xMinH - 0.05, xMaxH + 0.05])

        subplot(4,10,21:40)
        hold on
        box on
        title(['Vertical Resolution: Smallest Resolvable Detail = ',num2str(MinResolveableDetailSizeV)])
        xlabel('Peak Distance [mm]')
        ylabel('Grayvalue Difference [bit]')

        xMinV  = min(AllVerticalX);
        xMaxV  = max(AllVerticalX);
        Vplot4 = line([xMinV, xMaxV],[CurveFitV(xMinV), CurveFitV(xMaxV)],'Linewidth',1.5,'Color',[1 0.7 0],'Linestyle','--');
        Vplot5 = line([xMinV, xMaxV],[Parameter.RES.GrayvalueVisibilityThreshold, Parameter.RES.GrayvalueVisibilityThreshold],'Linewidth',1.5,'Color',[0.25 0.55 0],'Linestyle','--');

        Vplot1 = plot(Result_RES.MTFValuesV1(:,1),Result_RES.MTFValuesV1(:,2),'X','Color','red','Linewidth',3);
        Vplot2 = plot(Result_RES.MTFValuesV2(:,1),Result_RES.MTFValuesV2(:,2),'X','Color','green','Linewidth',3);
        Vplot3 = plot(Result_RES.MTFValuesV3(:,1),Result_RES.MTFValuesV3(:,2),'X','Color','blue','Linewidth',3);

        LegHandle = legend([Vplot1, Vplot2, Vplot3, Vplot4, Vplot5],'Vertical MTF 1','Vertical MTF 2','Vertical MTF 3','Linear Fit',['Threshold = ',num2str(Parameter.RES.GrayvalueVisibilityThreshold)]);
        set(LegHandle,'Location','NorthWest')   
        xlim([xMinV - 0.05, xMaxV + 0.05])
    else
        %% plot horizontal and vertical results in a single plot
        
        set(45, 'Visible', Parameter.GEN.PlotVisible)

        box on
        hold on
        %title(['Horizontal Resolution: Smallest Resolvable Detail = ',num2str(MinResolveableDetailSizeH)])
        
        xlabel('Peak Distance [mm]')
        ylabel('Grayvalue Difference [bit]')
        
        ColorVertical   = 'red';
        ColorHorizontal = 'blue';
        Marker          = 'x';
        Markersize      = 8;
        Linewidth       = 2;

        %plot fit
        xMinH  = min(AllHorizontalX);
        xMaxH  = max(AllHorizontalX);
        Hplot2 = line([xMinH, xMaxH],[CurveFitH(xMinH), CurveFitH(xMaxH)],'Linewidth',1.5,'Color',ColorHorizontal,'Linestyle','-');

                 plot(Result_RES.MTFValuesH1(:,1),Result_RES.MTFValuesH1(:,2),Marker,'Markersize',Markersize,'Color',ColorHorizontal,'Linewidth',Linewidth);
                 plot(Result_RES.MTFValuesH2(:,1),Result_RES.MTFValuesH2(:,2),Marker,'Markersize',Markersize,'Color',ColorHorizontal,'Linewidth',Linewidth);
        Hplot1 = plot(Result_RES.MTFValuesH3(:,1),Result_RES.MTFValuesH3(:,2),Marker,'Markersize',Markersize,'Color',ColorHorizontal,'Linewidth',Linewidth);

        xMinV  = min(AllVerticalX);
        xMaxV  = max(AllVerticalX);
        Vplot2 = line([xMinV, xMaxV],[CurveFitV(xMinV), CurveFitV(xMaxV)],'Linewidth',1.5,'Color',ColorVertical,'Linestyle','-');

                 plot(Result_RES.MTFValuesV1(:,1),Result_RES.MTFValuesV1(:,2),Marker,'Markersize',Markersize,'Color',ColorVertical,'Linewidth',Linewidth);
                 plot(Result_RES.MTFValuesV2(:,1),Result_RES.MTFValuesV2(:,2),Marker,'Markersize',Markersize,'Color',ColorVertical,'Linewidth',Linewidth);
        Vplot1 = plot(Result_RES.MTFValuesV3(:,1),Result_RES.MTFValuesV3(:,2),Marker,'Markersize',Markersize,'Color',ColorVertical,'Linewidth',Linewidth);

        Tplot1 = line([xMinV, xMaxV],[Parameter.RES.GrayvalueVisibilityThreshold, Parameter.RES.GrayvalueVisibilityThreshold],'Linewidth',1.5,'Color',[0.25 0.55 0],'Linestyle','--');
        
        LegHandle = legend([Hplot1, Vplot1, Hplot2, Vplot2, Tplot1],'Horizontal Paths','Vertical Paths','Horizontal MTF-Fit','Vertical MTF-Fit',['Threshold = ',num2str(Parameter.RES.GrayvalueVisibilityThreshold)]);
        set(LegHandle,'Location','NorthWest')   
        xlim([min(xMinV,xMinH) - 0.05, max(xMaxV, xMaxH) + 0.05])        
    end
        
                                
end