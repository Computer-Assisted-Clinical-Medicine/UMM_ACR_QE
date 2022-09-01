function [Result_CS, Parameter] = MeasureChemicalShift( Image, Parameter, Result_AP )

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
    %This function measures the chemical shift of the MR scanner. The 
    %chemical shift insert is composed of square structures, one containing
    %10mmol nickel chloride solution and the other vegetable fat . These 
    %square structures are arranged catty corner but will appear shifted 
    %toward or away from each other, depending on the direction of the 
    %chemical shift. Bandwidth (BW) can be assessed by measuring the 
    %chemical shift in millimeters, dividing the FOV by this and 
    %multiplying the result by 3.5 ppm of the magnet’s operating
    %frequency.
    %
    %The Millimeter-Shift is being performed as follows:
    %
    %   1)  Get an approximate position of the two squares by a template of
    %       a scanner with only few chemical shift
    %   2)  For both squares, determine a threshold to segment the square
    %       from the background
    %   3)  Calculate the center of each of the squares (using the center 
    %       of mass)
    %   4)  taking the angular position of the phantom in the scanner into
    %       account, calculate the chemical shift
    %   5)  using the chemical shift, calculate the bandwidth of the
    %       scanner, as described above
    
    AlgoType    = 2;
    % Type of optimization
    %   1 - Grayvalue Maximization
    %   2 - Gradient  Maximization
    
    UseFit      = 1;
    
    %get position and radius of the phantom inside the image
    [CenterX, CenterY, Radius, ~, ~] = GetPhantomCenter( Image, Parameter, 0, 0, 60 );
    Angle                            = Parameter.GEN.Angle;
    UseBinaryGradient                = 1;
    
    % UseBinaryGradient = 0:    No binary gradient
    % UseBinaryGradient = 1:    Simple binary gradient
    % UseBinaryGradient = 2:    Binary gradient, reweighted with image
    
    %   S1_x    = 
    %   S2_y    = 
    
    %relative defintion of square positions inside of the slice
    RelCenterX  = -0.4367;
    RelCenterY  = 0.4396;
    
    RelSquareSize     = 21/201.9089 * 1.07;
    
    RelRegionSize     = 27/201.8611;
    
    AbsRegionSize     = round(RelRegionSize * Radius);

    [Center]    = Template2Absolute([RelCenterX, RelCenterY], ...
                                     CenterX ,CenterY , ...
                                     Angle, Radius );
    AbsCenterX  = round(Center(1));
    AbsCenterY  = round(Center(2));
                               
    LimX        = [AbsCenterX - AbsRegionSize, AbsCenterX + AbsRegionSize];
    LimY        = [AbsCenterY - AbsRegionSize, AbsCenterY + AbsRegionSize];
    SubImage    = Image(LimY(1) : LimY(2), LimX(1) : LimX(2));
    
    CornerX     = LimX(1) - 1;
    CornerY     = LimY(1) - 1;
    
    %Plot ROI for chemical Shift determination
    figure(61)
    set(61, 'Visible', Parameter.GEN.PlotVisible)
    
    imshow(Image,'DisplayRange',[min(min(SubImage)), max(max(SubImage))]);
    
    hold on
    xlim(LimX);
    ylim(LimY);
    
        
    %Offset determination
    %RelativeROISize     = 0.4;
    
    %ROI_1_x_left        = round(AbsRegionSize + AbsRegionSize/2 - RelativeROISize * AbsRegionSize * 0.5) + CornerX + 1;
    %ROI_1_x_right       = round(AbsRegionSize + AbsRegionSize/2 + RelativeROISize * AbsRegionSize * 0.5) + CornerX + 1;
    %ROI_1_y_up          = round(AbsRegionSize - AbsRegionSize/2 - RelativeROISize * AbsRegionSize * 0.5) + CornerY + 1;
    %ROI_1_y_low         = round(AbsRegionSize - AbsRegionSize/2 + RelativeROISize * AbsRegionSize * 0.5) + CornerY + 1;
    
    %ROI_2_x_left        = round(AbsRegionSize - AbsRegionSize/2 - RelativeROISize * AbsRegionSize * 0.5) + CornerX + 1;
    %ROI_2_x_right       = round(AbsRegionSize - AbsRegionSize/2 + RelativeROISize * AbsRegionSize * 0.5) + CornerX + 1;
    %ROI_2_y_up          = round(AbsRegionSize + AbsRegionSize/2 - RelativeROISize * AbsRegionSize * 0.5) + CornerY + 1;
    %ROI_2_y_low         = round(AbsRegionSize + AbsRegionSize/2 + RelativeROISize * AbsRegionSize * 0.5) + CornerY + 1;
    
    
    %DrawRectangle(  ROI_1_x_left, ROI_1_x_right, ...
    %                ROI_1_y_up,   ROI_1_y_low  , 'yellow' );
    
    %DrawRectangle(  ROI_2_x_left, ROI_2_x_right, ...
    %                ROI_2_y_up,   ROI_2_y_low  , 'yellow' );
                
    %OffsetROI_1     = Image(ROI_1_y_up : ROI_1_y_low, ROI_1_x_left : ROI_1_x_right);
    %OffsetROI_2     = Image(ROI_2_y_up : ROI_2_y_low, ROI_2_x_left : ROI_2_x_right);
    
    %Offset          = 0.5 * (mean(OffsetROI_1) + mean(OffsetROI_2));
                
    %Plot template points
    %plot(S1_x, S1_y,'Marker','O','Color','red','Linewidth',2.5)
    %plot(S2_x, S2_y,'Marker','O','Color','red','Linewidth',2.5) 
    
    plot(AbsCenterX, AbsCenterY,'Marker','+','Color','yellow','Linewidth',2.5) 
    
    %Get Upper and Lower Threshold by k-means
    UpperOnes = triu(ones(size(SubImage)));
    UpperOnes = UpperOnes(:,end:-1:1);
    
    UpperVec        = SubImage(UpperOnes == 1);
    UpperThreshold  = kmeans(UpperVec);
    UpperSubImage   = SubImage .* UpperOnes;
    UpperBinImage   = double(UpperSubImage >= UpperThreshold);
    [UpperCenterY, UpperCenterX] = find(UpperBinImage == 1);
    
    for Index = 1 : numel(UpperCenterX)
       %plot(CornerX + UpperCenterX(Index),CornerY + UpperCenterY(Index),'o') 
    end
    
    UpperCenterX    = CornerX + mean(UpperCenterX);
    UpperCenterY    = CornerY + mean(UpperCenterY);
    
    %disp(['Upper Threshold = ',num2str(UpperThreshold)]);
    plot(UpperCenterX, UpperCenterY,'Marker','O','Color','red','Linewidth',2.5) 
    
    LowerOnes = tril(ones(size(SubImage)));
    LowerOnes = LowerOnes(:,end:-1:1);
    
    LowerVec        = SubImage(LowerOnes == 1);
    LowerThreshold  = kmeans(LowerVec);
    LowerSubImage   = SubImage .* LowerOnes;
    LowerBinImage   = double(LowerSubImage >= LowerThreshold);
    [LowerCenterY, LowerCenterX] = find(LowerBinImage == 1);
    
    for Index = 1 : numel(LowerCenterX)
       %plot(CornerX + LowerCenterX(Index),CornerY + LowerCenterY(Index),'o') 
    end
    
    LowerCenterX    = CornerX + mean(LowerCenterX);
    LowerCenterY    = CornerY + mean(LowerCenterY);
    
    %disp(['Lower Threshold = ',num2str(LowerThreshold)]);
    plot(LowerCenterX, LowerCenterY,'Marker','O','Color','red','Linewidth',2.5) 
   
    %get offset from to ROIs next to the two squares
    
    switch AlgoType
        case 1
            %===============================================================
            %=== T E M P L A T E  O B J E C T  D E T E R M I N A T I O N ===
            %===============================================================
            Template                = double(imread('ChemShiftTemplate.png','png'))/255;

            %Rotate according to determined angle
            Template                = imrotate(Template(:,:,1),Angle/pi * 180,'bilinear','loose');
            Size                    = 1033;
            AdjustmentFactor        = 0.97;
            SquareSizeFactor        = 0.93;
            Template                = imresize(Template, RelSquareSize * Radius / ((620 - 2 * 75)/620 * Size) * AdjustmentFactor);
            TemplateSquareSize      = RelSquareSize * Radius * SquareSizeFactor;


              %362;

            %normalize template to the both squares
            UpperROIPosX    = round(LowerCenterX);
            UpperROIPosY    = round(UpperCenterY);

            LowerROIPosX    = round(UpperCenterX);
            LowerROIPosY    = round(LowerCenterY);

            ROISizeX        = round((LowerCenterX - UpperCenterX) * 0.3);
            ROISizeY        = round((LowerCenterY - UpperCenterY) * 0.3);

            UpperOffsetMean    = mean(Image(UpperROIPosY - ROISizeY : UpperROIPosY - ROISizeY, ...
                                            UpperROIPosX - ROISizeX : UpperROIPosX - ROISizeX   ));
            LowerOffsetMean    = mean(Image(LowerROIPosY - ROISizeY : LowerROIPosY - ROISizeY, ...
                                            LowerROIPosX - ROISizeX : LowerROIPosX - ROISizeX   ));

            UpperSignalMean    = mean(SubImage(UpperBinImage == 1));
            LowerSignalMean    = mean(SubImage(LowerBinImage == 1));

            disp(['Offset:  Upper = ',num2str(UpperOffsetMean),'; Lower = ',num2str(LowerOffsetMean)])
            disp(['Signal:  Upper = ',num2str(UpperSignalMean),'; Lower = ',num2str(LowerSignalMean)])

            %Draw ROIs
            DrawRectangle(  UpperROIPosX - ROISizeX, UpperROIPosX + ROISizeX, ...
                            UpperROIPosY - ROISizeY, UpperROIPosY + ROISizeY, 'red' );
            DrawRectangle(  LowerROIPosX - ROISizeX, LowerROIPosX + ROISizeX, ...
                            LowerROIPosY - ROISizeY, LowerROIPosY + ROISizeY, 'red' );            

            %create normalized templates
            TemplateMin     = min(min(Template));
            TemplateMax     = max(max(Template));
            Offset          = mean([UpperOffsetMean, LowerOffsetMean]);

            UpperTemplate   = (Template - TemplateMin)/(TemplateMax - TemplateMin) * (UpperSignalMean - Offset) + Offset;
            LowerTemplate   = (Template - TemplateMin)/(TemplateMax - TemplateMin) * (LowerSignalMean - Offset) + Offset;


            %get size of template
            TemplateRadius      = ceil(size(Template)./2);
            TemplateRadiusY     = TemplateRadius(1);   
            TemplateRadiusX     = TemplateRadius(2); 

            [TemplateSizeY, TemplateSizeX]  = size(Template);
            UpperDistMin                    = inf;
            LowerDistMin                    = inf;
            Upper_Opt_x_Index               = nan;
            Upper_Opt_y_Index               = nan;
            Lower_Opt_x_Index               = nan;
            Lower_Opt_y_Index               = nan;

            [SubImageSizeY, SubImageSizeX]  = size(SubImage);

            DrawRectangle(  1 + TemplateRadiusX + LimX(1) - 1, SubImageSizeX - TemplateRadiusX - 1 + LimX(1) - 1, ...
                            1 + TemplateRadiusY + LimY(1) - 1, SubImageSizeY - TemplateRadiusY - 1 + LimY(1) - 1, 'yellow' );

            %to compensate for the pixel uncertainty, we store all weights
            %and try to perform a gaussian fit to the weights
  
            UpperWeights    = nan(  numel(1 + TemplateRadiusY : SubImageSizeY - TemplateRadiusY - 1), ...
                                    numel(1 + TemplateRadiusX : SubImageSizeX - TemplateRadiusX - 1));
            LowerWeights    = nan(  numel(1 + TemplateRadiusY : SubImageSizeY - TemplateRadiusY - 1), ...
                                    numel(1 + TemplateRadiusX : SubImageSizeX - TemplateRadiusX - 1));
                                
            for y_Index = 1 + TemplateRadiusY : SubImageSizeY - TemplateRadiusY - 1
                for x_Index = 1 + TemplateRadiusX : SubImageSizeX - TemplateRadiusX - 1

                    % ===== Adjust First Object =====
                    UpperTemplateImage = UpperSubImage( round(y_Index - TemplateSizeY/2) : round(y_Index - TemplateSizeY/2) + TemplateSizeY - 1 , ...
                                                        round(x_Index - TemplateSizeX/2) : round(x_Index - TemplateSizeX/2) + TemplateSizeX - 1 );
                    UpperDist          = sum(sum((UpperTemplateImage - UpperTemplate).^2));

                    UpperWeights(y_Index, x_Index)  = UpperDist;
                    
                    if UpperDist < UpperDistMin
                       UpperDistMin         = UpperDist;
                       Upper_Opt_x_Index    = x_Index - 1;
                       Upper_Opt_y_Index    = y_Index - 1;
                    end

                    % ===== Adjust Second Object =====
                    LowerTemplateImage = LowerSubImage( round(y_Index - TemplateSizeY/2) : round(y_Index - TemplateSizeY/2) + TemplateSizeY - 1 , ...
                                                        round(x_Index - TemplateSizeX/2) : round(x_Index - TemplateSizeX/2) + TemplateSizeX - 1 );
                    LowerDist          = sum(sum((LowerTemplateImage - LowerTemplate).^2));

                    LowerWeights(y_Index, x_Index)  = LowerDist;
                    
                    if LowerDist < LowerDistMin
                       LowerDistMin         = LowerDist;
                       Lower_Opt_x_Index    = x_Index - 1;
                       Lower_Opt_y_Index    = y_Index - 1;
                    end

                end        
            end
            
            save('Weights.mat',{'UpperWeights','LowerWeights'})

            %plot final results of square positions in the image
            FinalUpperPosX  = Upper_Opt_x_Index + LimX(1) - 1;
            FinalUpperPosY  = Upper_Opt_y_Index + LimY(1) - 1;
            FinalLowerPosX  = Lower_Opt_x_Index + LimX(1) - 1;
            FinalLowerPosY  = Lower_Opt_y_Index + LimY(1) - 1;


            plot(FinalUpperPosX, FinalUpperPosY, 'X','Color','green','Linewidth',2.5)
            plot(FinalLowerPosX, FinalLowerPosY, 'X','Color','green','Linewidth',2.5)

            %...and plot final rectangles
            UpperSquareCorners    = [ FinalUpperPosX - 0.5 * TemplateSquareSize, FinalUpperPosY - 0.5 * TemplateSquareSize; ...
                                      FinalUpperPosX + 0.5 * TemplateSquareSize, FinalUpperPosY - 0.5 * TemplateSquareSize; ...
                                      FinalUpperPosX - 0.5 * TemplateSquareSize, FinalUpperPosY + 0.5 * TemplateSquareSize; ...
                                      FinalUpperPosX + 0.5 * TemplateSquareSize, FinalUpperPosY + 0.5 * TemplateSquareSize ];
            [ Xadj, Yadj ] = AdjustAngle(   UpperSquareCorners(:,1), UpperSquareCorners(:,2), ...
                                            FinalUpperPosX, FinalUpperPosY, -Angle );
            line([Xadj(1), Xadj(2)], [Yadj(1), Yadj(2)], 'Linewidth',2)
            line([Xadj(3), Xadj(4)], [Yadj(3), Yadj(4)], 'Linewidth',2)
            line([Xadj(1), Xadj(3)], [Yadj(1), Yadj(3)], 'Linewidth',2)
            line([Xadj(2), Xadj(4)], [Yadj(2), Yadj(4)], 'Linewidth',2)

            LowerSquareCorners    = [ FinalLowerPosX - 0.5 * TemplateSquareSize, FinalLowerPosY - 0.5 * TemplateSquareSize; ...
                                      FinalLowerPosX + 0.5 * TemplateSquareSize, FinalLowerPosY - 0.5 * TemplateSquareSize; ...
                                      FinalLowerPosX - 0.5 * TemplateSquareSize, FinalLowerPosY + 0.5 * TemplateSquareSize; ...
                                      FinalLowerPosX + 0.5 * TemplateSquareSize, FinalLowerPosY + 0.5 * TemplateSquareSize ];
            [ Xadj, Yadj ] = AdjustAngle(   LowerSquareCorners(:,1), LowerSquareCorners(:,2), ...
                                            FinalLowerPosX, FinalLowerPosY, -Angle );
            line([Xadj(1), Xadj(2)], [Yadj(1), Yadj(2)], 'Linewidth',2)
            line([Xadj(3), Xadj(4)], [Yadj(3), Yadj(4)], 'Linewidth',2)
            line([Xadj(1), Xadj(3)], [Yadj(1), Yadj(3)], 'Linewidth',2)
            line([Xadj(2), Xadj(4)], [Yadj(2), Yadj(4)], 'Linewidth',2)

            %final chemical shift determination in x and y direction in mm
            Result_CS.ChemicalShiftX  = ((FinalLowerPosX - FinalUpperPosX) - TemplateSquareSize) * Parameter.SL.PixelSpacing;
            Result_CS.ChemicalShiftY  = ((FinalLowerPosY - FinalUpperPosY) - TemplateSquareSize) * Parameter.SL.PixelSpacing;
            disp(' *** Final Shift *** ')
            disp([' Shift x = ',num2str(Result_CS.ChemicalShiftX),' mm'])
            disp([' Shift y = ',num2str(Result_CS.ChemicalShiftY),' mm'])
            disp(' ******************* ')

            title(['Chemical Shift: x = ',num2str(Result_CS.ChemicalShiftX),' mm; y = ',num2str(Result_CS.ChemicalShiftY),' mm'])
    
        case 2
            %===============================================================
            %=== G R A D I E N T  O B J E C T  D E T E R M I N A T I O N ===
            %===============================================================
            
            %Load gradient template
            GradientTemplate        = double(imread('ChemShiftTemplateGrad.png','png'))/255;

            %Rotate according to determined angle
            GradientTemplate        = imrotate(GradientTemplate(:,:,1),Angle/pi * 180,'bilinear','loose');
            Size                    = 1033;
            AdjustmentFactor        = 1.07;
            SquareSizeFactor        = 0.99;
            GradientTemplate        = imresize(GradientTemplate, RelSquareSize * Radius / ((620 - 2 * 75)/620 * Size) * AdjustmentFactor);
            TemplateSquareSize      = RelSquareSize * Radius * SquareSizeFactor;
            
            %Expand SubImage by 2 * TemplateSquareSize (zero padding)
            [SubImageSizeY, SubImageSizeX]  = size(SubImage);
            SubImageExpanded                = zeros(SubImageSizeY + 2 * ceil(TemplateSquareSize), ...
                                                    SubImageSizeX + 2 * ceil(TemplateSquareSize));                                  
            SubImageExpanded(   ceil(TemplateSquareSize) + 1 : SubImageSizeY + ceil(TemplateSquareSize), ...
                                ceil(TemplateSquareSize) + 1 : SubImageSizeX + ceil(TemplateSquareSize)) ...
                                            = SubImage;
                                        
            SubImageBinary                = zeros(SubImageSizeY + 2 * ceil(TemplateSquareSize), ...
                                                  SubImageSizeX + 2 * ceil(TemplateSquareSize));                                  
            SubImageBinary(     ceil(TemplateSquareSize) + 2 : SubImageSizeY + ceil(TemplateSquareSize) - 1, ...
                                ceil(TemplateSquareSize) + 2 : SubImageSizeX + ceil(TemplateSquareSize) - 1) ...
                                            = 1;
                                        
            %adjust approximated centers
            UpperCenterX    = UpperCenterX + ceil(TemplateSquareSize);
            UpperCenterY    = UpperCenterY + ceil(TemplateSquareSize);                            
                                        
            LowerCenterX    = LowerCenterX + ceil(TemplateSquareSize);
            LowerCenterY    = LowerCenterY + ceil(TemplateSquareSize); 
            
            Gx  =   1/3 * [  -1  0  1; -1 0 1; -1 0 1  ];
            Gy  =   1/3 * [  -1 -1 -1;  0 0 0;  1 1 1  ];

            SubImageExpandedGx      = imfilter(SubImageExpanded,Gx);
            SubImageExpandedGy      = imfilter(SubImageExpanded,Gy);

            GradSubImageExpanded    = sqrt(double(SubImageExpandedGx).^2 + double(SubImageExpandedGy).^2); 
            GradSubImageExpanded    = GradSubImageExpanded .* SubImageBinary;
            
            %Create Binary image of gradient subimage
            %Threshold                                   = 1000;
            %BinGradSubImageExpanded                     = zeros(size(GradSubImageExpanded));
            %BinGradSubImageExpanded(GradSubImage >= Threshold)  = 1;
            
            %Iteration
            GradTemplateRadius      = ceil(size(GradientTemplate)./2);
            GradTemplateRadiusY     = GradTemplateRadius(1) + 1;   
            GradTemplateRadiusX     = GradTemplateRadius(2) + 1;

            [GradTemplateSizeY, GradTemplateSizeX]  = size(GradientTemplate);
            UpperWeightMax                  = 0;
            LowerWeightMax                  = 0;
%             Upper_Opt_x_Index               = nan;
%             Upper_Opt_y_Index               = nan;
%             Lower_Opt_x_Index               = nan;
%             Lower_Opt_y_Index               = nan;

            %create matrices with ones above upper and lower diagonal
            UpperOnesExpanded = triu(ones(size(SubImageExpanded)));
            UpperOnesExpanded = UpperOnesExpanded(:,end:-1:1);
            
            LowerOnesExpanded = tril(ones(size(SubImageExpanded)));
            LowerOnesExpanded = LowerOnesExpanded(:,end:-1:1);
            
            UpperGradSubImageExpanded = GradSubImageExpanded .* UpperOnesExpanded;
            LowerGradSubImageExpanded = GradSubImageExpanded .* LowerOnesExpanded;
            
            if UseBinaryGradient > 0
                %disp('Using Binary Gradient Images!')
                UpperThreshold   =  0.8 * kmeans(UpperGradSubImageExpanded);
                LowerThreshold   =  0.8 * kmeans(LowerGradSubImageExpanded);
                
                UpperGradSubImageExpandedBinary     = zeros(size(UpperGradSubImageExpanded));
                UpperGradSubImageExpandedBinary(UpperGradSubImageExpanded >= UpperThreshold) = 1;

                LowerGradSubImageExpandedBinary     = zeros(size(LowerGradSubImageExpanded));
                LowerGradSubImageExpandedBinary(LowerGradSubImageExpanded >= LowerThreshold) = 1;

                if UseBinaryGradient == 2
                    %perform reweighting 
                    UpperGradSubImageExpanded           = UpperGradSubImageExpandedBinary .* UpperGradSubImageExpanded; 
                    LowerGradSubImageExpanded           = LowerGradSubImageExpandedBinary .* LowerGradSubImageExpanded; 
                else
                    LowerGradSubImageExpanded           = LowerGradSubImageExpandedBinary;
                    UpperGradSubImageExpanded           = UpperGradSubImageExpandedBinary;
                end
                
                GradSubImageExpanded 	= UpperGradSubImageExpandedBinary;
                GradSubImageExpanded(LowerGradSubImageExpandedBinary > UpperGradSubImageExpandedBinary) = ...
                    LowerGradSubImageExpandedBinary(LowerGradSubImageExpandedBinary > UpperGradSubImageExpandedBinary);
            end

            figure(62)
            set(62, 'Visible', Parameter.GEN.PlotVisible)
            imshow(GradSubImageExpanded,'DisplayRange',[0 2])
            hold on
            plot(UpperCenterX - LimX(1) + 1, UpperCenterY - LimY(1) + 1,'Marker','O','Color','red','Linewidth',2.5) 
            plot(LowerCenterX - LimX(1) + 1, LowerCenterY - LimY(1) + 1,'Marker','O','Color','red','Linewidth',2.5) 

            [GradSubImageExpandedSizeY, GradSubImageExpandedSizeX]  = size(GradSubImageExpanded);

            DrawRectangle(  1 + GradTemplateRadiusX, GradSubImageExpandedSizeX - GradTemplateRadiusX - 1, ...
                            1 + GradTemplateRadiusY, GradSubImageExpandedSizeY - GradTemplateRadiusY - 1, 'yellow' );

            UpperWeights    = nan(  numel(1 + GradTemplateRadiusY : GradSubImageExpandedSizeY - GradTemplateRadiusY - 1), ...
                                    numel(1 + GradTemplateRadiusX : GradSubImageExpandedSizeX - GradTemplateRadiusX - 1));
            LowerWeights    = nan(  numel(1 + GradTemplateRadiusY : GradSubImageExpandedSizeY - GradTemplateRadiusY - 1), ...
                                    numel(1 + GradTemplateRadiusX : GradSubImageExpandedSizeX - GradTemplateRadiusX - 1));
                   
            for y_Index = 1 + GradTemplateRadiusY : GradSubImageExpandedSizeY - GradTemplateRadiusY - 1
                for x_Index = 1 + GradTemplateRadiusX : GradSubImageExpandedSizeX - GradTemplateRadiusX - 1

                    % ===== Adjust First Object =====
                    UpperTemplateImage = UpperGradSubImageExpanded( round(y_Index - GradTemplateSizeY/2) : round(y_Index - GradTemplateSizeY/2) + GradTemplateSizeY - 1 , ...
                                                                    round(x_Index - GradTemplateSizeX/2) : round(x_Index - GradTemplateSizeX/2) + GradTemplateSizeX - 1 );
                    UpperWeight     = sum(sum(UpperTemplateImage .* GradientTemplate));

                    UpperWeights(y_Index, x_Index)  = UpperWeight;
                    
                    if UpperWeight > UpperWeightMax
                       UpperWeightMax       = UpperWeight;
%                        Upper_Opt_x_Index    = (2*round(x_Index - GradTemplateSizeX/2) + GradTemplateSizeX - 1) / 2;
%                        Upper_Opt_y_Index    = (2*round(y_Index - GradTemplateSizeY/2) + GradTemplateSizeY - 1) / 2;

                       %create image overlayed with current mask
                       UpperOptGradientTemplateFull = zeros(size(SubImage));
                       UpperOptGradientTemplateFull( round(y_Index - GradTemplateSizeY/2) : round(y_Index - GradTemplateSizeY/2) + GradTemplateSizeY - 1 , ...
                                                     round(x_Index - GradTemplateSizeX/2) : round(x_Index - GradTemplateSizeX/2) + GradTemplateSizeX - 1 ) ...
                                                    = GradientTemplate;             
                    end

                    % ===== Adjust Second Object =====
                    LowerTemplateImage = LowerGradSubImageExpanded( round(y_Index - GradTemplateSizeY/2) : round(y_Index - GradTemplateSizeY/2) + GradTemplateSizeY - 1 , ...
                                                                    round(x_Index - GradTemplateSizeX/2) : round(x_Index - GradTemplateSizeX/2) + GradTemplateSizeX - 1 );
                    LowerWeight          = sum(sum(LowerTemplateImage .* GradientTemplate));

                    LowerWeights(y_Index, x_Index)  = LowerWeight;
                    
                    if LowerWeight > LowerWeightMax
                       LowerWeightMax       = LowerWeight;
%                        Lower_Opt_x_Index    = (2*round(x_Index - GradTemplateSizeX/2) + GradTemplateSizeX - 1) / 2;
%                        Lower_Opt_y_Index    = (2*round(y_Index - GradTemplateSizeY/2) + GradTemplateSizeY - 1) / 2;

                       %create image overlayed with current mask
                       LowerOptGradientTemplateFull = zeros(size(SubImage));
                       LowerOptGradientTemplateFull( round(y_Index - GradTemplateSizeY/2) : round(y_Index - GradTemplateSizeY/2) + GradTemplateSizeY - 1 , ...
                                                     round(x_Index - GradTemplateSizeX/2) : round(x_Index - GradTemplateSizeX/2) + GradTemplateSizeX - 1 ) ...
                                                    = GradientTemplate; 

                    end

                end        
            end
            
            if UseFit
                
                [PosXUpper,PosYUpper]   = FindSquarePosition( UpperWeights );
                Upper_Opt_x_Index    = (2*(PosXUpper - GradTemplateSizeX/2) + GradTemplateSizeX - 1) / 2;
                Upper_Opt_y_Index    = (2*(PosYUpper - GradTemplateSizeY/2) + GradTemplateSizeY - 1) / 2;

                [PosXLower,PosYLower]   = FindSquarePosition( LowerWeights );
                Lower_Opt_x_Index    = (2*(PosXLower - GradTemplateSizeX/2) + GradTemplateSizeX - 1) / 2;
                Lower_Opt_y_Index    = (2*(PosYLower - GradTemplateSizeY/2) + GradTemplateSizeY - 1) / 2;

            end
            
            save('Weights.mat','UpperWeights','LowerWeights')

            %plot final results of square positions in the image
            plot(Upper_Opt_x_Index, Upper_Opt_y_Index, 'X','MarkerSize',8,'Color','yellow','Linewidth',2)
            plot(Lower_Opt_x_Index, Lower_Opt_y_Index, 'X','MarkerSize',8,'Color','yellow','Linewidth',2)

            %plot template overlayed to gradient image
            [UpperIndsY,UpperIndsX]   = find(UpperOptGradientTemplateFull >= 0.1);
            [LowerIndsY,LowerIndsX]   = find(LowerOptGradientTemplateFull >= 0.1);
            plot([UpperIndsX,LowerIndsX], [UpperIndsY,LowerIndsY],'.','Color','white')
            set(gca,'Position',[0.15    0.150    0.7    0.650])
            title({'Gradient Image, Gradient Segmentation (dotted red)';['Angle = ',num2str(Angle)]})
            
            xlim([ceil(TemplateSquareSize) - 7, GradSubImageExpandedSizeX - ceil(TemplateSquareSize) + 7]);
            ylim([ceil(TemplateSquareSize) - 7, GradSubImageExpandedSizeY - ceil(TemplateSquareSize) + 7]);
            
            set(0,'CurrentFigure',61)
            
            %plot final results of square positions in the image
            FinalUpperPosX  = Upper_Opt_x_Index + LimX(1) - 1 - ceil(TemplateSquareSize);
            FinalUpperPosY  = Upper_Opt_y_Index + LimY(1) - 1 - ceil(TemplateSquareSize);
            FinalLowerPosX  = Lower_Opt_x_Index + LimX(1) - 1 - ceil(TemplateSquareSize);
            FinalLowerPosY  = Lower_Opt_y_Index + LimY(1) - 1 - ceil(TemplateSquareSize);

            plot(FinalUpperPosX, FinalUpperPosY, 'X','MarkerSize',8,'Color','yellow','Linewidth',2)
            plot(FinalLowerPosX, FinalLowerPosY, 'X','MarkerSize',8,'Color','yellow','Linewidth',2)

            %...and plot final rectangles
            UpperSquareCorners    = [ FinalUpperPosX - 0.5 * TemplateSquareSize, FinalUpperPosY - 0.5 * TemplateSquareSize; ...
                                      FinalUpperPosX + 0.5 * TemplateSquareSize, FinalUpperPosY - 0.5 * TemplateSquareSize; ...
                                      FinalUpperPosX - 0.5 * TemplateSquareSize, FinalUpperPosY + 0.5 * TemplateSquareSize; ...
                                      FinalUpperPosX + 0.5 * TemplateSquareSize, FinalUpperPosY + 0.5 * TemplateSquareSize ];
            [ Xadj, Yadj ] = AdjustAngle(   UpperSquareCorners(:,1), UpperSquareCorners(:,2), ...
                                            FinalUpperPosX, FinalUpperPosY, -Angle );
            LWidth  = 3;
            LStyle  = '--';
            line([Xadj(1), Xadj(2)], [Yadj(1), Yadj(2)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')
            line([Xadj(3), Xadj(4)], [Yadj(3), Yadj(4)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')
            line([Xadj(1), Xadj(3)], [Yadj(1), Yadj(3)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')
            line([Xadj(2), Xadj(4)], [Yadj(2), Yadj(4)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')

            LowerSquareCorners    = [ FinalLowerPosX - 0.5 * TemplateSquareSize, FinalLowerPosY - 0.5 * TemplateSquareSize; ...
                                      FinalLowerPosX + 0.5 * TemplateSquareSize, FinalLowerPosY - 0.5 * TemplateSquareSize; ...
                                      FinalLowerPosX - 0.5 * TemplateSquareSize, FinalLowerPosY + 0.5 * TemplateSquareSize; ...
                                      FinalLowerPosX + 0.5 * TemplateSquareSize, FinalLowerPosY + 0.5 * TemplateSquareSize ];
            [ Xadj, Yadj ] = AdjustAngle(   LowerSquareCorners(:,1), LowerSquareCorners(:,2), ...
                                            FinalLowerPosX, FinalLowerPosY, -Angle );
            line([Xadj(1), Xadj(2)], [Yadj(1), Yadj(2)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')
            line([Xadj(3), Xadj(4)], [Yadj(3), Yadj(4)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')
            line([Xadj(1), Xadj(3)], [Yadj(1), Yadj(3)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')
            line([Xadj(2), Xadj(4)], [Yadj(2), Yadj(4)], 'Linestyle', LStyle, 'Linewidth',LWidth,'Color','red')

            %final chemical shift determination in x and y direction in mm
            Result_CS.PixelChemicalShiftX       = ((FinalLowerPosX - FinalUpperPosX) - TemplateSquareSize) + 0.5;
            Result_CS.PixelChemicalShiftY       = ((FinalLowerPosY - FinalUpperPosY) - TemplateSquareSize) - 0.5;
            Result_CS.PixelChemicalShiftFull    = sqrt( Result_CS.PixelChemicalShiftX^2 + Result_CS.PixelChemicalShiftY^2 );
            
            if isnumeric(Parameter.SL.PixelSpacing)
                Result_CS.MillimeterChemicalShiftX      = Result_CS.PixelChemicalShiftX * Parameter.SL.PixelSpacing;
                Result_CS.MillimeterChemicalShiftY      = Result_CS.PixelChemicalShiftY * Parameter.SL.PixelSpacing;
            else
                Result_CS.MillimeterChemicalShiftX = nan;
                Result_CS.MillimeterChemicalShiftY = nan;
                Error('WARNING: Result_AP.PixelSpacing is inconsistent')
                Error('         Millimeter Shifts can not be determined')
            end
            
            Result_CS.MillimeterChemicalShiftFull   = sqrt( Result_CS.MillimeterChemicalShiftX^2 + Result_CS.MillimeterChemicalShiftY^2 );
            
            
            %Bandwidth (BW) can be assessed by measuring the chemical shift 
            %in millimeters, dividing the FOV by this and multiplying the 
            %result by 3.5 ppm of the magnet’s operating frequency. The
            %Result_AP struct is used for this calculation!
            Gamma               = 2.675222005e8;
            if isnumeric(Result_AP.FOVX) && ...
               isnumeric(Result_AP.FOVY) && ...
               isnumeric(Result_AP.MagneticFieldStrength) && ...
               isnumeric(Result_AP.PixelBandwidth) && ...
               isnumeric(Result_AP.FrequencyColumns) && ...
               isnumeric(Result_AP.PhaseRows)
                if isnumeric(Result_AP.FrequencyColumns) ~= isnumeric(Result_AP.PhaseRows)
                   Error('WARNING: FrequencyColumns ~= PhaseRows!') 
                end
                Result_CS.Bandwidth         = Result_AP.FOVY/Result_CS.MillimeterChemicalShiftY * 3.5e-6 * Result_AP.MagneticFieldStrength * Gamma / (2*pi) / Result_AP.FrequencyColumns;
                Result_CS.RelBandwidth      = Result_CS.Bandwidth / Result_AP.PixelBandwidth;
                Result_CS.RelAbsBandwidth   = abs( Result_CS.Bandwidth / Result_AP.PixelBandwidth );
            else
                Result_CS.Bandwidth         = nan;
                Result_CS.RelBandwidth      = nan;
                Result_CS.RelAbsBandwidth   = nan;
                Error('WARNING: FOVX or FOVY or FieldStrength is inconsistent')
                Error('         Result_CS.Bandwidth can not be determined')
            end
            
%             disp(' *** Final Shift *** ')
%             disp([' Shift x                 = ',num2str(Result_CS.MillimeterChemicalShiftX),' mm'])
%             disp([' Shift y                 = ',num2str(Result_CS.MillimeterChemicalShiftY),' mm'])
%             disp([' Pixel Shift x           = ',num2str(Result_CS.PixelChemicalShiftX),' px'])
%             disp([' Pixel Shift y           = ',num2str(Result_CS.PixelChemicalShiftY),' px'])
%             disp([' Bandwidth               = ',num2str(Result_CS.Bandwidth),' Hz'])
%             disp([' Relative Bandwidth      = ',num2str(Result_CS.RelBandwidth)])
%             disp([' Abs Relative Bandwidth  = ',num2str(Result_CS.RelAbsBandwidth)])
%             disp(' ******************* ')

            title({['Chemical Shift: x = ',num2str(Result_CS.MillimeterChemicalShiftX),' mm; y = ',num2str(Result_CS.MillimeterChemicalShiftY),' mm'];['Relative Bandwidth = ',num2str(Result_CS.RelBandwidth)]})
            set(gca,'Position',[0.1500    0.1500    0.7000    0.6300])
        
    end

