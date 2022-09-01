function [CenterX, CenterY, Radius, Angle, WedgeFactor] = GetPhantomCenter( Image, Parameter, DetermineAngle, DetermineWedgePosition, DoPlotResults )
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
    
    %Method Description:
    %-------------------
    %       This function determines the center (via matrix indices) of the
    %       current slice of the phantom by:
    %       Sampling the border-pixels of the phantom and and fitting 2
    %       circular functions using the border points. The Radius is
    %       determined by using the Center Bar of e.g. the resolution slice
    %       and fitting a linear function using these points
    
    %Input
    %       Image               [One slice of the Phantom-Dataset, should 
    %                           contain the CenterBar (e.g. ResolutionSlice)]
    %                           to be able to determine the angular
    %                           distortion
    %       Parameter           [ --> Threshold]
    %       DetermineAngle      1, if angle needs to be determined (expects 
    %                           correct slice to be given, 0 otherwise)
    
    %Output
    %       CenterX
    %       CenterY
    %       Radius
    %       Angle
    
    %======================================================
    
    try

        [SizeY, SizeX]      = size(Image);

        Threshold           = kmeans(Image);
        [ObjIndY, ObjIndX]  = find(Image > Threshold);
        LowerY              = max(ObjIndY);
        LowerX              = round(mean(ObjIndX(ObjIndY == max(ObjIndY))));
        Radius              = (max(ObjIndY) - min(ObjIndY))/2;

        CenterXApprox       = LowerX;
        CenterYApprox       = LowerY - Radius;

        %UpperY Value increase by approx 0.4 of the radius
        %Avoid area of approx 0.3 of radius to left and right,0.06 in Y
        SampleValuesX       = round([ linspace(max(CenterXApprox - 0.85 * Radius, 5),  min(CenterXApprox - 0.25 * Radius, SizeX - 4 ), 15), ...
                                      linspace(max(CenterXApprox + 0.25 * Radius, 5),  min(CenterXApprox + 0.85 * Radius, SizeX - 4 ), 15)]);

        %Rescale
        SampleValuesX(SampleValuesX < 1)                = 1;
        SampleValuesX(SampleValuesX > size(Image,2))    = 1;


        SampleValuesYLow    = nan(numel(SampleValuesX),1);
        SampleValuesYUp     = nan(numel(SampleValuesX),1);

        for Index = 1 : numel(SampleValuesX)
           CurrentColumn                = Image(:,SampleValuesX(Index));
           SampleValuesYLow(Index)      = find(CurrentColumn > Threshold, 1, 'first');
           SampleValuesYUp(Index)       = find(CurrentColumn > Threshold, 1, 'last');  
        end

        %Perform Fit to fit optimal Phantom Center and Radius
        FitOpt  = fitoptions(   'method','NonlinearLeastSquares',...
                                'Lower',        [0                      0               0             ],...
                                'Upper',        [max(SizeY,SizeX)       SizeX           SizeY         ],...
                                'Startpoint',   [Radius                 CenterXApprox   CenterYApprox ]);

        FitTypeUp   = fittype('sqrt(max(R^2 - (x - xShift)^2,0)) + yShift',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'R', 'xShift', 'yShift'});

        FitTypeLow  = fittype('-sqrt(max(R^2 - (x - xShift)^2,0)) + yShift',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'R', 'xShift', 'yShift'});

        % Fit this model using new data
        CurveFitUp      = fit(SampleValuesX', SampleValuesYUp,  FitTypeUp,  FitOpt);
        CurveFitLow     = fit(SampleValuesX', SampleValuesYLow, FitTypeLow, FitOpt);

        %Center Results
        CenterX    = (CurveFitUp.xShift + CurveFitLow.xShift) / 2;
        CenterY    = (CurveFitUp.yShift + CurveFitLow.yShift) / 2;
        Radius     = (CurveFitUp.R + CurveFitLow.R) / 2;

        % =======================================================
        % === Only if angle is about to be determined as well ===
        % =======================================================
        if DetermineAngle == 1

            %first of all, perform Regiongrowing with CenterValue as Seed Point
            SampleNum               = 30;
            AngleSampleShiftX       = linspace(1, round(0.8 * Radius),SampleNum);
            AngleSampleValuesX      = nan(2 * SampleNum, 1);
            AngleSampleValuesYLow   = nan(2 * SampleNum, 1);
            AngleSampleValuesYUp    = nan(2 * SampleNum, 1);
            LastCenterYLeft         = round(CenterY);
            LastCenterYRight        = round(CenterY);
            for AngleIndex = 1 : SampleNum
                %In left direction

                %Check if the x-Sample-Point is running into negative values
                if round(CenterX - AngleSampleShiftX(AngleIndex)) > 0
                    AngleSampleValuesX(SampleNum - AngleIndex + 1)      = round(CenterX - AngleSampleShiftX(AngleIndex));
                    AngleSampleValuesYLow(SampleNum - AngleIndex + 1)   = find( Image(1 : LastCenterYLeft, ...
                                                                                round(CenterX - AngleSampleShiftX(AngleIndex))) > Threshold,... 
                                                                                1, 'last');
                    AngleSampleValuesYUp(SampleNum - AngleIndex + 1)    = find( Image(LastCenterYLeft : end,...
                                                                                round(CenterX - AngleSampleShiftX(AngleIndex))) > Threshold,...
                                                                                1, 'first') + LastCenterYLeft - 1;
                else
                    AngleSampleValuesX(SampleNum - AngleIndex + 1)      = nan;
                    AngleSampleValuesYLow(SampleNum - AngleIndex + 1)   = nan;
                    AngleSampleValuesYUp(SampleNum - AngleIndex + 1)    = nan;
                end
                LastCenterYLeft     = round(mean([AngleSampleValuesYLow(SampleNum - AngleIndex + 1), AngleSampleValuesYUp(SampleNum - AngleIndex + 1)]));

                %In right direction

                %Check if the x-Sample-Point is running into values larger than
                %SizeX

                if round(CenterX + AngleSampleShiftX(AngleIndex)) < SizeX
                    AngleSampleValuesX(SampleNum + AngleIndex)    = round(CenterX + AngleSampleShiftX(AngleIndex));
                    AngleSampleValuesYLow(SampleNum + AngleIndex) = find( Image(1 : LastCenterYRight, ...
                                                                          round(CenterX + AngleSampleShiftX(AngleIndex))) > Threshold,... 
                                                                          1, 'last');
                    AngleSampleValuesYUp(SampleNum + AngleIndex)  = find( Image(LastCenterYRight : end,...
                                                                          round(CenterX + AngleSampleShiftX(AngleIndex))) > Threshold,...
                                                                          1,'first') + LastCenterYRight - 1;
                else
                    AngleSampleValuesX(SampleNum + AngleIndex)    = nan;
                    AngleSampleValuesYLow(SampleNum + AngleIndex) = nan;
                    AngleSampleValuesYUp(SampleNum + AngleIndex)  = nan;
                end
                LastCenterYRight    = round(mean([AngleSampleValuesYLow(SampleNum + AngleIndex), AngleSampleValuesYUp(SampleNum + AngleIndex)])); 


            end

            %Remove NaNs
            AngleSampleValuesX(isnan(AngleSampleValuesX))           = [];
            AngleSampleValuesYLow(isnan(AngleSampleValuesYLow))     = [];
            AngleSampleValuesYUp(isnan(AngleSampleValuesYUp))       = [];

            %Remove NaNs
            AngleSampleValuesX(isnan(AngleSampleValuesX))           = [];
            AngleSampleValuesYLow(isnan(AngleSampleValuesYLow))     = [];
            AngleSampleValuesYUp(isnan(AngleSampleValuesYUp))       = [];

            %Perform Simple Linear Fit to determine Angle
            FitOpt  = fitoptions(   'method','NonlinearLeastSquares',...
                                    'Lower',        [-Inf, -Inf],...
                                    'Upper',        [Inf, Inf],...
                                    'Startpoint',   [0, CenterY] );

            FitType = fittype('m * x + n',...
                'dependent',{'y'},'independent',{'x'},...
                'coefficients',{'m', 'n'});

            % Fit this model using new data
            AngleFitUp      = fit(AngleSampleValuesX, AngleSampleValuesYUp,  FitType,  FitOpt);
            AngleFitLow     = fit(AngleSampleValuesX, AngleSampleValuesYLow, FitType, FitOpt);


            %Angle Results Results, as mean value of the fit results
            Angle      = atan( -mean([AngleFitUp.m, AngleFitLow.m]) );    

            %disp(['CenterX = ',num2str(CenterX),', CenterY = ',num2str(CenterY),', Radius = ',num2str(Radius), ', Angle m = ',num2str(Angle)])

        else
            %otherwise set Angle to 'nan'
            Angle = nan;
        end

        % =======================================================
        % === Only if Wedge is about to be determined as well ===
        % =======================================================
        if DetermineWedgePosition == 1
            WedgeCenter     = 0.976; %WedgeRadialPosition / Radius
            HorizontalShift = round(0.03 * Radius);
            WedgeYPosition      = CenterY - WedgeCenter * Radius;
            WedgeXPosition      = CenterX;

            %Get Left and Right Sub Array

            % ===>>     Handle left Array
            LeftWedgeArray  = Image(  round(WedgeYPosition) : round(WedgeYPosition + 0.5 * Radius), ...
                                             round(WedgeXPosition - 1.5 * HorizontalShift) : round(WedgeXPosition - 0.5 * HorizontalShift));
            [~, SizeXLeft]  = size(LeftWedgeArray); 
            IndicesLeft     = nan(SizeXLeft, 1);
            for Index = 1 : SizeXLeft
                IndicesLeft(Index) = find(LeftWedgeArray(:,Index) > Threshold, 1, 'first');
            end     
            LeftMean  = mean(IndicesLeft) + WedgeYPosition

            % ===>>     Handle right Array
            RightWedgeArray = Image(  round(WedgeYPosition) : round(WedgeYPosition + 0.5 * Radius), ...
                                             round(WedgeXPosition + 0.5 * HorizontalShift) : round(WedgeXPosition + 1.5 * HorizontalShift));
            [~, SizeXRight] = size(RightWedgeArray);
            IndicesRight    = nan(SizeXRight, 1);
            for Index = 1 : SizeXLeft
                IndicesRight(Index) = find(RightWedgeArray(:,Index) > Threshold, 1, 'first');
            end

            RightMean = mean(IndicesRight) + WedgeYPosition

        else
            WedgeFactor = nan;

        end


        %Plot, only for testing purpose
        if DoPlotResults > 0
            figure(DoPlotResults)
            set(DoPlotResults, 'Visible', Parameter.GEN.PlotVisible)
            imshow(Image,'DisplayRange',[min(min(Image)), max(max(Image))])
            hold on
            %plot(LowerX, LowerY, 'X','Linewidth',2,'Color','red')
            %plot(CenterXApprox, CenterYApprox, 'O','Linewidth',2,'Color','yellow')

            CF1 = plot(CurveFitUp,  'fit');
            CF2 = plot(CurveFitLow, 'fit');
            set(CF1,'Linewidth', 2)
            set(CF2,'Linewidth', 2)

            plot(CenterX, CenterY, 'X','Linewidth',2,'Markersize',8,'Color','red')

            plot(SampleValuesX, SampleValuesYLow, 'X','Linewidth',2,'Markersize',8,'Color','yellow')
            plot(SampleValuesX, SampleValuesYUp, 'X','Linewidth',2,'Markersize',8,'Color','yellow')

            if DetermineAngle == 1

                CF3 = plot(AngleFitUp,  'fit');
                CF4 = plot(AngleFitLow, 'fit');
                set(CF3,'Linestyle','--', 'Linewidth', 2)
                set(CF4,'Linestyle','--', 'Linewidth', 2)

                plot(AngleSampleValuesX, AngleSampleValuesYLow, 'X','Linewidth',2,'Markersize',8,'Color','yellow')
                plot(AngleSampleValuesX, AngleSampleValuesYUp, 'X','Linewidth',2,'Markersize',8,'Color','yellow')
            end
            legend off
        end
        
    catch exception
        warning('The phantom could not be localized correctly, trying localization with smoothed image version!')
        
        
        [SizeY, SizeX]      = size(Image);
        
        %use smoothed image
        GaussFilt           = fspecial('gaussian', round(0.1*[SizeY,SizeX]), 2.0);
        Image               = imfilter(Image,GaussFilt);

        Threshold           = kmeans(Image);
        [ObjIndY, ObjIndX]  = find(Image > Threshold);
        LowerY              = max(ObjIndY);
        LowerX              = round(mean(ObjIndX(ObjIndY == max(ObjIndY))));
        Radius              = (max(ObjIndY) - min(ObjIndY))/2;

        CenterXApprox       = LowerX;
        CenterYApprox       = LowerY - Radius;

        %UpperY Value increase by approx 0.4 of the radius
        %Avoid area of approx 0.3 of radius to left and right,0.06 in Y
        SampleValuesX       = round([ linspace(max(CenterXApprox - 0.85 * Radius, 5),  min(CenterXApprox - 0.25 * Radius, SizeX - 4 ), 15), ...
                                      linspace(max(CenterXApprox + 0.25 * Radius, 5),  min(CenterXApprox + 0.85 * Radius, SizeX - 4 ), 15)]);

        %Rescale
        SampleValuesX(SampleValuesX < 1)                = 1;
        SampleValuesX(SampleValuesX > size(Image,2))    = 1;


        SampleValuesYLow    = nan(numel(SampleValuesX),1);
        SampleValuesYUp     = nan(numel(SampleValuesX),1);

        for Index = 1 : numel(SampleValuesX)
           CurrentColumn                = Image(:,SampleValuesX(Index));
           SampleValuesYLow(Index)      = find(CurrentColumn > Threshold, 1, 'first');
           SampleValuesYUp(Index)       = find(CurrentColumn > Threshold, 1, 'last');  
        end

        %Perform Fit to fit optimal Phantom Center and Radius
        FitOpt  = fitoptions(   'method','NonlinearLeastSquares',...
                                'Lower',        [0                      0               0             ],...
                                'Upper',        [max(SizeY,SizeX)       SizeX           SizeY         ],...
                                'Startpoint',   [Radius                 CenterXApprox   CenterYApprox ]);

        FitTypeUp   = fittype('sqrt(max(R^2 - (x - xShift)^2,0)) + yShift',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'R', 'xShift', 'yShift'});

        FitTypeLow  = fittype('-sqrt(max(R^2 - (x - xShift)^2,0)) + yShift',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'R', 'xShift', 'yShift'});

        % Fit this model using new data
        CurveFitUp      = fit(SampleValuesX', SampleValuesYUp,  FitTypeUp,  FitOpt);
        CurveFitLow     = fit(SampleValuesX', SampleValuesYLow, FitTypeLow, FitOpt);

        %Center Results
        CenterX    = (CurveFitUp.xShift + CurveFitLow.xShift) / 2;
        CenterY    = (CurveFitUp.yShift + CurveFitLow.yShift) / 2;
        Radius     = (CurveFitUp.R + CurveFitLow.R) / 2;

        % =======================================================
        % === Only if angle is about to be determined as well ===
        % =======================================================
        if DetermineAngle == 1

            %first of all, perform Regiongrowing with CenterValue as Seed Point
            SampleNum               = 30;
            AngleSampleShiftX       = linspace(1, round(0.8 * Radius),SampleNum);
            AngleSampleValuesX      = nan(2 * SampleNum, 1);
            AngleSampleValuesYLow   = nan(2 * SampleNum, 1);
            AngleSampleValuesYUp    = nan(2 * SampleNum, 1);
            LastCenterYLeft         = round(CenterY);
            LastCenterYRight        = round(CenterY);
            for AngleIndex = 1 : SampleNum
                %In left direction

                %Check if the x-Sample-Point is running into negative values
                if round(CenterX - AngleSampleShiftX(AngleIndex)) > 0
                    AngleSampleValuesX(SampleNum - AngleIndex + 1)      = round(CenterX - AngleSampleShiftX(AngleIndex));
                    AngleSampleValuesYLow(SampleNum - AngleIndex + 1)   = find( Image(1 : LastCenterYLeft, ...
                                                                                round(CenterX - AngleSampleShiftX(AngleIndex))) > Threshold,... 
                                                                                1, 'last');
                    AngleSampleValuesYUp(SampleNum - AngleIndex + 1)    = find( Image(LastCenterYLeft : end,...
                                                                                round(CenterX - AngleSampleShiftX(AngleIndex))) > Threshold,...
                                                                                1, 'first') + LastCenterYLeft - 1;
                else
                    AngleSampleValuesX(SampleNum - AngleIndex + 1)      = nan;
                    AngleSampleValuesYLow(SampleNum - AngleIndex + 1)   = nan;
                    AngleSampleValuesYUp(SampleNum - AngleIndex + 1)    = nan;
                end
                LastCenterYLeft     = round(mean([AngleSampleValuesYLow(SampleNum - AngleIndex + 1), AngleSampleValuesYUp(SampleNum - AngleIndex + 1)]));

                %In right direction

                %Check if the x-Sample-Point is running into values larger than
                %SizeX

                if round(CenterX + AngleSampleShiftX(AngleIndex)) < SizeX
                    AngleSampleValuesX(SampleNum + AngleIndex)    = round(CenterX + AngleSampleShiftX(AngleIndex));
                    AngleSampleValuesYLow(SampleNum + AngleIndex) = find( Image(1 : LastCenterYRight, ...
                                                                          round(CenterX + AngleSampleShiftX(AngleIndex))) > Threshold,... 
                                                                          1, 'last');
                    AngleSampleValuesYUp(SampleNum + AngleIndex)  = find( Image(LastCenterYRight : end,...
                                                                          round(CenterX + AngleSampleShiftX(AngleIndex))) > Threshold,...
                                                                          1,'first') + LastCenterYRight - 1;
                else
                    AngleSampleValuesX(SampleNum + AngleIndex)    = nan;
                    AngleSampleValuesYLow(SampleNum + AngleIndex) = nan;
                    AngleSampleValuesYUp(SampleNum + AngleIndex)  = nan;
                end
                LastCenterYRight    = round(mean([AngleSampleValuesYLow(SampleNum + AngleIndex), AngleSampleValuesYUp(SampleNum + AngleIndex)])); 


            end

            %Remove NaNs
            AngleSampleValuesX(isnan(AngleSampleValuesX))           = [];
            AngleSampleValuesYLow(isnan(AngleSampleValuesYLow))     = [];
            AngleSampleValuesYUp(isnan(AngleSampleValuesYUp))       = [];

            %Remove NaNs
            AngleSampleValuesX(isnan(AngleSampleValuesX))           = [];
            AngleSampleValuesYLow(isnan(AngleSampleValuesYLow))     = [];
            AngleSampleValuesYUp(isnan(AngleSampleValuesYUp))       = [];

            %Perform Simple Linear Fit to determine Angle
            FitOpt  = fitoptions(   'method','NonlinearLeastSquares',...
                                    'Lower',        [-Inf, -Inf],...
                                    'Upper',        [Inf, Inf],...
                                    'Startpoint',   [0, CenterY] );

            FitType = fittype('m * x + n',...
                'dependent',{'y'},'independent',{'x'},...
                'coefficients',{'m', 'n'});

            % Fit this model using new data
            AngleFitUp      = fit(AngleSampleValuesX, AngleSampleValuesYUp,  FitType,  FitOpt);
            AngleFitLow     = fit(AngleSampleValuesX, AngleSampleValuesYLow, FitType, FitOpt);


            %Angle Results Results, as mean value of the fit results
            Angle      = atan( -mean([AngleFitUp.m, AngleFitLow.m]) );    

            %disp(['CenterX = ',num2str(CenterX),', CenterY = ',num2str(CenterY),', Radius = ',num2str(Radius), ', Angle m = ',num2str(Angle)])

        else
            %otherwise set Angle to 'nan'
            Angle = nan;
        end

        % =======================================================
        % === Only if Wedge is about to be determined as well ===
        % =======================================================
        if DetermineWedgePosition == 1
            WedgeCenter     = 0.976; %WedgeRadialPosition / Radius
            HorizontalShift = round(0.03 * Radius);
            WedgeYPosition      = CenterY - WedgeCenter * Radius;
            WedgeXPosition      = CenterX;

            %Get Left and Right Sub Array

            % ===>>     Handle left Array
            LeftWedgeArray  = Image(  round(WedgeYPosition) : round(WedgeYPosition + 0.5 * Radius), ...
                                             round(WedgeXPosition - 1.5 * HorizontalShift) : round(WedgeXPosition - 0.5 * HorizontalShift));
            [~, SizeXLeft]  = size(LeftWedgeArray); 
            IndicesLeft     = nan(SizeXLeft, 1);
            for Index = 1 : SizeXLeft
                IndicesLeft(Index) = find(LeftWedgeArray(:,Index) > Threshold, 1, 'first');
            end     
            LeftMean  = mean(IndicesLeft) + WedgeYPosition

            % ===>>     Handle right Array
            RightWedgeArray = Image(  round(WedgeYPosition) : round(WedgeYPosition + 0.5 * Radius), ...
                                             round(WedgeXPosition + 0.5 * HorizontalShift) : round(WedgeXPosition + 1.5 * HorizontalShift));
            [~, SizeXRight] = size(RightWedgeArray);
            IndicesRight    = nan(SizeXRight, 1);
            for Index = 1 : SizeXLeft
                IndicesRight(Index) = find(RightWedgeArray(:,Index) > Threshold, 1, 'first');
            end

            RightMean = mean(IndicesRight) + WedgeYPosition

        else
            WedgeFactor = nan;

        end


        %Plot, only for testing purpose
        if DoPlotResults > 0
            figure(DoPlotResults)
            set(DoPlotResults, 'Visible', Parameter.GEN.PlotVisible)
            imshow(Image,'DisplayRange',[min(min(Image)), max(max(Image))])
            hold on
            %plot(LowerX, LowerY, 'X','Linewidth',2,'Color','red')
            %plot(CenterXApprox, CenterYApprox, 'O','Linewidth',2,'Color','yellow')

            CF1 = plot(CurveFitUp,  'fit');
            CF2 = plot(CurveFitLow, 'fit');
            set(CF1,'Linewidth', 2)
            set(CF2,'Linewidth', 2)

            plot(CenterX, CenterY, 'X','Linewidth',2,'Markersize',8,'Color','red')

            plot(SampleValuesX, SampleValuesYLow, 'X','Linewidth',2,'Markersize',8,'Color','yellow')
            plot(SampleValuesX, SampleValuesYUp, 'X','Linewidth',2,'Markersize',8,'Color','yellow')

            if DetermineAngle == 1

                CF3 = plot(AngleFitUp,  'fit');
                CF4 = plot(AngleFitLow, 'fit');
                set(CF3,'Linestyle','--', 'Linewidth', 2)
                set(CF4,'Linestyle','--', 'Linewidth', 2)

                plot(AngleSampleValuesX, AngleSampleValuesYLow, 'X','Linewidth',2,'Markersize',8,'Color','yellow')
                plot(AngleSampleValuesX, AngleSampleValuesYUp, 'X','Linewidth',2,'Markersize',8,'Color','yellow')
            end
            legend off
        end
        
    end

