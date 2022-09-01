function [Parameter] = DetermineThreshold( Image, Parameter )

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
    %Based on a simple slice, perform a kmeans clustering to find a
    %suitable threshold seperating the background from the high signal
    %intensity parts of the image. The results are stored in Parameter to
    %be handed to the subsequent methods

    Usekmeans   = 1;

    if Usekmeans == 0
        %Old Approach for determining Threshold
        [SizeY, SizeX]              = size(Image);

        RawThreshold                = 100;
        [yRawWhite,xRawWhite]       = find(Image > RawThreshold);
        CenterY                     = round(mean(yRawWhite));
        CenterX                     = round(mean(xRawWhite));
        RawRadius                   = sqrt(numel(yRawWhite) / pi);
        %CircularROI                 = GetCircularROI( Image, CenterX, CenterY, RawRadius * 0.5 );
        %WhiteMean                   = mean(CircularROI);
        %imshowSc(Image)

        %Upper Left
        CurrentCorner       = [1 1];
        CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (RawRadius / norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

        InnerCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
        OuterCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);
        %DrawRectangle( InnerCornerYX(2), OuterCornerYX(2), InnerCornerYX(1), OuterCornerYX(1), 'yellow' )

        ROI1    = Image       (     min([InnerCornerYX(1), OuterCornerYX(1)]) : max([InnerCornerYX(1), OuterCornerYX(1)]), ...
                                    min([InnerCornerYX(2), OuterCornerYX(2)]) : max([InnerCornerYX(2), OuterCornerYX(2)]) );

        %Upper Right
        CurrentCorner       = [SizeX 1];
        CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (RawRadius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

        InnerCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
        OuterCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);
        %DrawRectangle( InnerCornerYX(2), OuterCornerYX(2), InnerCornerYX(1), OuterCornerYX(1), 'yellow' )

        ROI2    = Image       (     min([InnerCornerYX(1), OuterCornerYX(1)]) : max([InnerCornerYX(1), OuterCornerYX(1)]), ...
                                    min([InnerCornerYX(2), OuterCornerYX(2)]) : max([InnerCornerYX(2), OuterCornerYX(2)]) );  

        %Lower Left
        CurrentCorner       = [1 SizeY];
        CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (RawRadius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

        InnerCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
        OuterCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);
        %DrawRectangle( InnerCornerYX(2), OuterCornerYX(2), InnerCornerYX(1), OuterCornerYX(1), 'yellow' )

        ROI3    = Image       (     min([InnerCornerYX(1), OuterCornerYX(1)]) : max([InnerCornerYX(1), OuterCornerYX(1)]), ...
                                    min([InnerCornerYX(2), OuterCornerYX(2)]) : max([InnerCornerYX(2), OuterCornerYX(2)]) );                             

        %Lower Right
        CurrentCorner       = [SizeX SizeY];
        CornerToRadius      = CurrentCorner - ([CenterX, CenterY] + (RawRadius /norm(CurrentCorner - [CenterX, CenterY], 2)) * (CurrentCorner - [CenterX, CenterY]));

        InnerCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.9, CurrentCorner(1) - CornerToRadius(1) * 0.9]);
        OuterCornerYX = round([CurrentCorner(2) - CornerToRadius(2) * 0.1, CurrentCorner(1) - CornerToRadius(1) * 0.1]);
        %DrawRectangle( InnerCornerYX(2), OuterCornerYX(2), InnerCornerYX(1), OuterCornerYX(1), 'yellow' )

        ROI4    = Image       (     min([InnerCornerYX(1), OuterCornerYX(1)]) : max([InnerCornerYX(1), OuterCornerYX(1)]), ...
                                    min([InnerCornerYX(2), OuterCornerYX(2)]) : max([InnerCornerYX(2), OuterCornerYX(2)]) );                             

        %BlackMean   = mean([ROI1(:); ROI2(:); ROI3(:); ROI4(:)]);
        BlackMax    = max([ROI1(:); ROI2(:); ROI3(:); ROI4(:)]);

        if BlackMax > 150
           Error('WARNING: Large Pixelvalues in Background detected!') 
        end

        Parameter.GEN.Threshold     = BlackMax * 9;
        Parameter.GEN.CenterY       = CenterY;
        Parameter.GEN.CenterX       = CenterX;
        Parameter.GEN.Radius        = RawRadius;
    else
        %k-means-approach for determining threshold
        Threshold                   = kmeans(Image);
        [yWhite,xWhite]             = find(Image > Threshold);
        CenterY                     = round(mean(yWhite));
        CenterX                     = round(mean(xWhite));
        RawRadius                   = sqrt(numel(xWhite) / pi);
        
        Parameter.GEN.Threshold     = Threshold;
        Parameter.GEN.CenterY       = CenterY;
        Parameter.GEN.CenterX       = CenterX;
        Parameter.GEN.Radius        = RawRadius;
        
    end
end

