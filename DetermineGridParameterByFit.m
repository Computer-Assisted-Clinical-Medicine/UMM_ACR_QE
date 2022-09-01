function [ FinalCenterX, FinalCenterY, FinalGridSpace, FinalSlope ] = DetermineGridParameterByFit( GridData, CenterX, CenterY, Parameter )

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
    %
    %From given centers of the grid structure perform an estimation of the
    %ideal overlayed grid by seperately fitting the rows and columns of the
    %structure, and from that, calculating the grid spacing, the ideal
    %center and the angle. This is just an estimate, and will be further
    %optimized by the IterativePointPoint-matching approach, implemented by
    %IPPM

    NonEmptyIndices     = find(~cellfun('isempty',GridData));
    NonEmptyElements    = cell2mat(GridData(NonEmptyIndices));
    
    xVals   = NonEmptyElements(:, 1);
    yVals   = NonEmptyElements(:, 2);
    zVals   = ones(numel(NonEmptyIndices),1);
    
    ObjectCenterX   = mean(xVals);
    ObjectCenterY   = mean(yVals);

    %HorizonalSpaces     = nan(10,1);
    HorizontalSlopes    = nan(10,1);
    %VerticalSpaces      = nan(10,1);
    VerticalSlopes      = nan(10,1);
    
    FitOptV  = fitoptions(   'method','NonlinearLeastSquares',...
                             'Lower',        [-Inf, -Inf],...
                             'Upper',        [Inf,  Inf] );
                         
    FitOptH  = fitoptions(   'method','NonlinearLeastSquares',...
                             'Lower',        [-Inf, -Inf],...
                             'Upper',        [Inf,  Inf] );                         

    FitType = fittype('m * x + n',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'m', 'n'});
    
    FitResultsV     = cell(10,1);    
    FitResultsH     = cell(10,1);    
    
    for Index = 1 : 10
        
        %Horizonal Fit
            SubCellH                = cell2mat( GridData(Index,:) );
            FitOptH.StartPoint      = [  0, mean(SubCellH(2:2:end)) ];
            LinearFitH = fit(SubCellH(1:2:end)', SubCellH(2:2:end)',  FitType,  FitOptH);
            
            FitResultsH{Index}      = LinearFitH;
            HorizontalSlopes(Index)  = LinearFitH.m;
            %HorizonalSpaces(Index)  = abs( CenterY - LinearFitH(CenterX) ) * cos(atan(LinearFitH.m));
            %plot(LinearFitH, 'fit')
     
        %Vertical Fit
            SubCellV = cell2mat(GridData(:,Index));
            
            %Adjust Dara --> Rotation by 90° clockwise in Image
            %Coordinate-System
            [ Xadj, Yadj ] = AdjustAngle( SubCellV(:,1), SubCellV(:,2), CenterX, CenterY, pi/2 );
            
            FitOptV.StartPoint      = [  0, mean(Yadj) ];
            LinearFitV = fit(Xadj, Yadj,  FitType,  FitOptV);
            
            FitResultsV{Index}      = LinearFitV;
            VerticalSlopes(Index)   = LinearFitV.m;
            %VerticalSpaces(Index)   = abs( CenterY - LinearFitV(CenterX) ) * cos(atan(LinearFitV.m));
            %plot(LinearFitV, 'fit')
            
    end
   
    %Two linear function are being defined, that each are perpendicular 
    %(according to the mean angle value) to all 10 lines. They are then
    %used to determine a distances between the lines, the object sizes
    %respectively
    
    %HorizontalCrossFunction
    HorizontalCrossM        = tan(atan(mean(VerticalSlopes)) - pi/2);
    HorizontalCrossN        = ObjectCenterY - HorizontalCrossM * ObjectCenterX;
    HorizontalCrossPoints   = nan(10,2);
    for Index = 1 : 10
        HorizontalCrossPoints(Index,1) = (FitResultsV{Index}.n - HorizontalCrossN)/(HorizontalCrossM - FitResultsV{Index}.m);
        HorizontalCrossPoints(Index,2) = HorizontalCrossM * HorizontalCrossPoints(Index,1) + HorizontalCrossN;
    end
    
    HorizontalSpaces        = nan(9,1);
    for Index = 1 : 9
        HorizontalSpaces(Index) = sqrt( (HorizontalCrossPoints(Index,1) - HorizontalCrossPoints(Index + 1,1))^2 + ...
                                        (HorizontalCrossPoints(Index,2) - HorizontalCrossPoints(Index + 1,2))^2 );
    end
    
    %VerticalCrossFunction
    VerticalCrossM        = tan(atan(mean(HorizontalSlopes)) - pi/2);
    VerticalCrossN        = ObjectCenterY - VerticalCrossM * ObjectCenterX;
    VerticalCrossPoints   = nan(10,2);
    for Index = 1 : 10
        VerticalCrossPoints(Index,1) = (FitResultsH{Index}.n - VerticalCrossN)/(VerticalCrossM - FitResultsH{Index}.m);
        VerticalCrossPoints(Index,2) = VerticalCrossM * VerticalCrossPoints(Index,1) + VerticalCrossN;
    end
    
    VerticalSpaces        = nan(9,1);
    for Index = 1 : 9
        VerticalSpaces(Index) = sqrt( (VerticalCrossPoints(Index,1) - VerticalCrossPoints(Index + 1,1))^2 + ...
                                      (VerticalCrossPoints(Index,2) - VerticalCrossPoints(Index + 1,2))^2 );
    end
    
    SlopeMean   = mean(mean([HorizontalSlopes,VerticalSlopes]));
    SpaceMean   = mean(mean([HorizontalSpaces,VerticalSpaces]));
    
    %SpaceMeanH  = sum(Weights1 ./ Weights2 .* HorizonalSpaces')/sum(Weights1);
    %SpaceMeanV  = sum(Weights1 ./ Weights2 .* VerticalSpaces')/sum(Weights1);
    %SpaceMean   = (SpaceMeanH + SpaceMeanV) / 2;
    
   
    %For further enhencement, the grid ican be fitted by the
    %DoubleSinApproach 
    if Parameter.SL.BiSinFit == 1

        % Set up fittype and options.
        SinFitType  = fittype( 'max(0.5 * sin((((x-CenterX) - m * (y-CenterY))/dist * cos(atan(m)))*2*pi - pi/2) + 0.5 * sin((( +m * (x-CenterX) + (y-CenterY))/dist * cos(atan(m)))*2*pi - pi/2),0).^6', 'indep', {'x', 'y'}, 'depend', 'z' );
        SinFitOpt   = fitoptions( SinFitType );
        SinFitOpt.Display = 'Off';
        AngleRange  = 3;

        mRange      = [tan(atan(SlopeMean) - AngleRange), tan(atan(SlopeMean) + AngleRange)];

        %FitParameter                   CenterX     CenterY     dist            m
        SinFitOpt.Lower         = [     min(xVals)  min(yVals)  0               min(mRange)      ];
        SinFitOpt.StartPoint    = [     CenterX     CenterY     SpaceMean       SlopeMean        ];
        SinFitOpt.Upper         = [     max(xVals)  max(yVals)  2 * SpaceMean   max(mRange)      ];

        %Example Parameter
        %CenterX =          237.9  (237.8, 238.1)
        %CenterY =          321.1  (320.9, 321.3)
        %dist =             40.29  (40.25, 40.33)
        %m =                0.01055  (0.00967, 0.01143)

        % Fit model to data.
        FitResult       = fit( [xVals, yVals], zVals, SinFitType, SinFitOpt );
        
        FinalCenterX    = FitResult.CenterX;
        FinalCenterY    = FitResult.CenterY;
        FinalGridSpace  = FitResult.dist;
        FinalSlope      = -FitResult.m;
        
    else
        
        FinalCenterX    = ObjectCenterX;
        FinalCenterY    = ObjectCenterY;
        FinalGridSpace  = SpaceMean;
        FinalSlope      = SlopeMean;
    
    end
    
end

