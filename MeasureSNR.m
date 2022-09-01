function [Result_SNR, Parameter] = MeasureSNR( Image, Parameter )

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
    
    GhostFactorType     = 2;
    %   1:  Merging Corner ROIs
    %   2:  Set new ROIs at Edges, if possible

    %This function calculates the SNR of a ROI in the center of the
    %phantom, this is done by calculating the mean-value of the ROI an
    %dividing it by the SNR-value which is being calculated by choosing 4
    %regions of equal size in the corners of the image
    %
    % Result_SNR contains:
    %
    %   1)      CenterX
    %   2)      CenterY
    %   3)      Radius
    %   4)      InnerMean
    %   5)      BorderSTD
    %   6)      SNR

    %get position and radius of the phantom inside the image
    [CenterX, CenterY, Radius, ~, ~] = GetPhantomCenter( Image, Parameter, 0, 0, 30 );

    %store the results to the Result_SNR-struct
    Result_SNR.CenterX  = CenterX;
    Result_SNR.CenterY  = CenterY;
    Result_SNR.Radius   = Radius;
    
    %First calculate the radius of the inner roi, and extract the ROI, then
    %draw the ROI to the current plot and caclulate the mean-value of all
    %ROI pixels
    InnerRadius             = Radius * Parameter.SNR.RelInnerROIRadius;
    InnerROI                = GetCircularROI( Image, CenterX, CenterY, InnerRadius );
    %save('Test.mat', 'Image','InnerROI','CenterX','CenterY','InnerRadius')
    DrawCircle(CenterX, CenterY, InnerRadius, 'red')
    Result_SNR.InnerMean    = mean(InnerROI);
    
    %get dimensions of image
    [SizeY, SizeX]      = size(Image);

    %Get distance from the current corner-point the the outer border of the
    %phantom, the distance is using a line crossing the center-point of the
    %phantom, that means, the line is perpendicular to the outer border of
    %the phantom
    
    %From the CornerToRadius, get the the two border-points of the
    %rectangle in the corner of the image, the first on is the corner
    %nearest to the corresponding corner of the overall image, the second
    %one is the one closest to the border of the phanom#
    
    switch Parameter.SNR.BorderROIinCorner
        case 0
            %Put the SNR_ROIs near to the Phantom in a symmetric way
            
            %Makeing the image such, that the Phantom-Center is the center
            %of the image, the borders of the image are adjusted in terms
            %of the following new image corners
            RadX                = min(CenterX, SizeX - CenterX);
            RadY                = min(CenterY, SizeY - CenterY);
            
            SymLeftX            = max(CenterX - RadX, 1);
            SymRightX           = min(CenterX + RadX, SizeX);
            
            SymUpY            = max(CenterY - RadY, 1);
            SymLowY           = min(CenterY + RadY, SizeY);    
            
            DrawRectangle( SymLeftX, SymRightX, SymUpY, SymLowY, 'red' );
            
            %=================
            %== Upper Left  ==
            %=================
            CurrentCorner       = [SymLeftX, SymUpY];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius / norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));
            
            InnerCornerYX1 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX1 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);

            %=================
            %== Upper Right ==
            %=================
            CurrentCorner       = [SymRightX, SymUpY];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

            InnerCornerYX2 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX2 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);

            %================
            %== Lower Left ==
            %================
            CurrentCorner       = [SymLeftX, SymLowY];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

            InnerCornerYX3 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX3 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);

            %=================
            %== Lower Right ==
            %=================
            CurrentCorner       = [SymRightX, SymLowY];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

            InnerCornerYX4 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX4 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);
  
        case 1
            %Put the SNR-ROIs to the 4-Corners of the Image
            
            %=================
            %== Upper Left  ==
            %=================
            CurrentCorner       = [1 1];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius / norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));            
            
            InnerCornerYX1 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX1 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);

            %=================
            %== Upper Right ==
            %=================
            CurrentCorner       = [SizeX 1];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

            InnerCornerYX2 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX2 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);

            %================
            %== Lower Left ==
            %================
            CurrentCorner       = [1 SizeY];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

            InnerCornerYX3 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX3 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);

            %=================
            %== Lower Right ==
            %=================
            CurrentCorner       = [SizeX SizeY];
            CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (Radius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

            InnerCornerYX4 = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
            OuterCornerYX4 = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);
    end
    

   
    %Adjust ROIs, if equal STD-areas should be used (Parameter.SNR.EqualSTDAreas == 1)
    if Parameter.SNR.EqualSTDAreas == 1
        
        %Make all Regions equally large
        MinSizeX    = min([ abs(InnerCornerYX1(2) - OuterCornerYX1(2)), ...
                            abs(InnerCornerYX2(2) - OuterCornerYX2(2)), ...
                            abs(InnerCornerYX3(2) - OuterCornerYX3(2)), ...
                            abs(InnerCornerYX4(2) - OuterCornerYX4(2)) ]);
        MinSizeY    = min([ abs(InnerCornerYX1(1) - OuterCornerYX1(1)), ...
                            abs(InnerCornerYX2(1) - OuterCornerYX2(1)), ...
                            abs(InnerCornerYX3(1) - OuterCornerYX3(1)), ...
                            abs(InnerCornerYX4(1) - OuterCornerYX4(1)) ]);
        
        switch Parameter.SNR.BorderROIinCorner
            case 0
                %Adjust all OuterCorners to make the four rectangles equally large                
                OuterCornerYX1 = InnerCornerYX1 - [+MinSizeY, +MinSizeX];
                OuterCornerYX2 = InnerCornerYX2 - [+MinSizeY, -MinSizeX];
                OuterCornerYX3 = InnerCornerYX3 - [-MinSizeY, +MinSizeX];
                OuterCornerYX4 = InnerCornerYX4 - [-MinSizeY, -MinSizeX];
            case 1
                %Adjust all InnerCorners to make the four rectangles equally large                
                InnerCornerYX1 = OuterCornerYX1 + [+MinSizeY, +MinSizeX];
                InnerCornerYX2 = OuterCornerYX2 + [+MinSizeY, -MinSizeX];
                InnerCornerYX3 = OuterCornerYX3 + [-MinSizeY, +MinSizeX];
                InnerCornerYX4 = OuterCornerYX4 + [-MinSizeY, -MinSizeX];
        end
        
    end
    
    %Get all four ROIs 1,...,4 from the image using the CornerValues and
    %plot them to the current figure
    
    ROI1           = Image(     min([InnerCornerYX1(1), OuterCornerYX1(1)]) : max([InnerCornerYX1(1), OuterCornerYX1(1)]), ...
                                min([InnerCornerYX1(2), OuterCornerYX1(2)]) : max([InnerCornerYX1(2), OuterCornerYX1(2)]) );
    DrawRectangle( InnerCornerYX1(2), OuterCornerYX1(2), InnerCornerYX1(1), OuterCornerYX1(1), 'yellow' )    
    
    ROI2           = Image(     min([InnerCornerYX2(1), OuterCornerYX2(1)]) : max([InnerCornerYX2(1), OuterCornerYX2(1)]), ...
                                min([InnerCornerYX2(2), OuterCornerYX2(2)]) : max([InnerCornerYX2(2), OuterCornerYX2(2)]) );  
    DrawRectangle( InnerCornerYX2(2), OuterCornerYX2(2), InnerCornerYX2(1), OuterCornerYX2(1), 'yellow' )    
    
    ROI3           = Image(     min([InnerCornerYX3(1), OuterCornerYX3(1)]) : max([InnerCornerYX3(1), OuterCornerYX3(1)]), ...
                                min([InnerCornerYX3(2), OuterCornerYX3(2)]) : max([InnerCornerYX3(2), OuterCornerYX3(2)]) );                             
    DrawRectangle( InnerCornerYX3(2), OuterCornerYX3(2), InnerCornerYX3(1), OuterCornerYX3(1), 'yellow' )
                            
    ROI4           = Image(     min([InnerCornerYX4(1), OuterCornerYX4(1)]) : max([InnerCornerYX4(1), OuterCornerYX4(1)]), ...
                                min([InnerCornerYX4(2), OuterCornerYX4(2)]) : max([InnerCornerYX4(2), OuterCornerYX4(2)]) );                       
    DrawRectangle( InnerCornerYX4(2), OuterCornerYX4(2), InnerCornerYX4(1), OuterCornerYX4(1), 'yellow' ) 
       
    
    %Calculate the overall STD of the Border-ractangles, and finally,
    %calculate the signal-to-noise ratio, store both to the
    %Result_SNR-struct
    Result_SNR.BorderMean  = mean([ROI1(:); ROI2(:); ROI3(:); ROI4(:)]);
    Result_SNR.BorderSTD   = std([ROI1(:); ROI2(:); ROI3(:); ROI4(:)]);
    Result_SNR.SNR         = Result_SNR.InnerMean/Result_SNR.BorderSTD;
    
    %corrected SNR takes into parallel imaging:
    %SNR_R = SNR_0 / (g * sqrt(R)) for a geometry factor g (always >= 1) 
    %and an acceleration factor R.
    g   = 1;
    R   = 2;
    Result_SNR.SNRCorr     = Result_SNR.SNR / (g * sqrt(R));
    Result_SNR.RayFactor   = Result_SNR.BorderMean/Result_SNR.BorderSTD;
    %in case of rayleigh distribution of the noise: 
    %the ratio of mean/std
    %should not significantly vary from 1.91 indicating the noise to be
    %rayleigh distributed
    
    
    %Percent Signal Ghosting
    %Ghosting Ratio = |(top + bottom)-(left + right)|/(2*largeROI)
    switch GhostFactorType
        case 1
            % Merging Corner ROIs
    
            Top     = mean([ROI1(:); ROI2(:)]);
            Bottom  = mean([ROI3(:); ROI4(:)]);
            Left    = mean([ROI1(:); ROI3(:)]);
            Right   = mean([ROI2(:); ROI4(:)]);
            Result_SNR.PercentageGhostingRatio = 100 * abs((Top + Bottom)-(Left + Right))/(2*Result_SNR.InnerMean);
            %PassCriterion: <= 2.5%
    
        case 2
            % Set new ROIs at Edges, if possible
            RelLeftMargin       = (CenterX - Radius)/SizeX; 
            RelRightMargin      = 1 - ((2 * Radius)/SizeX + RelLeftMargin); 
            RelTopMargin        = (CenterY - Radius)/SizeY; 
            RelBottomMargin     = 1 - ((2 * Radius)/SizeY + RelTopMargin); 
            MinEdgeMargin       = min([RelLeftMargin, RelRightMargin, RelTopMargin, RelBottomMargin]);
            
            %check if margins are valid
            if MinEdgeMargin >= Parameter.SNR.MinEdgeMargin
                EdgeMargin  = min(MinEdgeMargin, Parameter.SNR.MaxEdgeMargin);
                %get size of GhostFactorROIs
                SizePerp    = EdgeMargin * Parameter.SNR.ROISizePerp * Radius;
                SizeTang    = Parameter.SNR.ROISizeTang * Radius;
                
                %Get and plot ROIs
                %=======
                %=  1  =    Left
                %=======
                GF_CenterX  = CenterX - Radius - SizePerp - Parameter.SNR.BorderROIMargin * Radius;
                plot(CenterX - Radius, CenterY, 'X')
                GF_CenterY  = CenterY;
                Corner_Xmin    = round(GF_CenterX - SizePerp);
                Corner_Xmax    = round(GF_CenterX + SizePerp);
                Corner_Ymin    = round(GF_CenterY - SizeTang);
                Corner_Ymax    = round(GF_CenterY + SizeTang);

                GF_ROIA     = Image(    Corner_Ymin : Corner_Ymax, ...
                                        Corner_Xmin : Corner_Xmax     );
                DrawRectangle(  Corner_Xmin, Corner_Xmax, ...
                                Corner_Ymin, Corner_Ymax, 'green' )
                            
                %Get and plot ROIs
                %=======
                %=  2  =    Top
                %=======
                GF_CenterX  = CenterX;
                GF_CenterY  = CenterY - Radius - SizePerp - Parameter.SNR.BorderROIMargin * Radius;
                Corner_Xmin    = round(GF_CenterX - SizeTang);
                Corner_Xmax    = round(GF_CenterX + SizeTang);
                Corner_Ymin    = round(GF_CenterY - SizePerp);
                Corner_Ymax    = round(GF_CenterY + SizePerp);

                GF_ROIB     = Image(    Corner_Ymin : Corner_Ymax, ...
                                        Corner_Xmin : Corner_Xmax     );
                DrawRectangle(  Corner_Xmin, Corner_Xmax, ...
                                Corner_Ymin, Corner_Ymax, 'green' )
                            
                %Get and plot ROIs
                %=======
                %=  3  =    Right
                %=======
                GF_CenterX  = CenterX + Radius + SizePerp + Parameter.SNR.BorderROIMargin * Radius;
                GF_CenterY  = CenterY;
                Corner_Xmin    = round(GF_CenterX - SizePerp);
                Corner_Xmax    = round(GF_CenterX + SizePerp);
                Corner_Ymin    = round(GF_CenterY - SizeTang);
                Corner_Ymax    = round(GF_CenterY + SizeTang);

                GF_ROIC     = Image(    Corner_Ymin : Corner_Ymax, ...
                                        Corner_Xmin : Corner_Xmax     );
                DrawRectangle(  Corner_Xmin, Corner_Xmax, ...
                                Corner_Ymin, Corner_Ymax, 'green' )
                            
                %Get and plot ROIs
                %=======
                %=  4  =    Bottom
                %=======
                GF_CenterX  = CenterX;
                GF_CenterY  = CenterY + Radius + SizePerp + Parameter.SNR.BorderROIMargin * Radius;
                Corner_Xmin    = round(GF_CenterX - SizeTang);
                Corner_Xmax    = round(GF_CenterX + SizeTang);
                Corner_Ymin    = round(GF_CenterY - SizePerp);
                Corner_Ymax    = round(GF_CenterY + SizePerp);

                GF_ROID     = Image(    Corner_Ymin : Corner_Ymax, ...
                                        Corner_Xmin : Corner_Xmax     );
                DrawRectangle(  Corner_Xmin, Corner_Xmax, ...
                                Corner_Ymin, Corner_Ymax, 'green' )
                            
                %Ghost Factor Calculation
                Left    = mean(GF_ROIA(:));
                Top     = mean(GF_ROIB(:));
                Right   = mean(GF_ROIC(:));
                Bottom  = mean(GF_ROID(:));
                Result_SNR.GhostingRatio = abs((Top + Bottom)-(Left + Right))/(2*Result_SNR.InnerMean);
                %change display range to make ghosts visible
                %caxis(gca, [0, max(max([GF_ROIA(:); GF_ROIB(:); GF_ROIC(:); GF_ROID(:)]))])
                
            else
                Error('WARNING: GhostFactor could not be calculated:')
                Error('         Edge Margins insufficient!')
                Result_SNR.GhostingRatio = nan;
            end
            
            title(['SNR = ',sprintf('%.2f',Result_SNR.SNR),'; RayFactor = ',sprintf('%.2f',Result_SNR.RayFactor),'; Ghosting Ratio = ',sprintf('%.4f',Result_SNR.GhostingRatio)])
            
    end
    
end

