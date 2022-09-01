function PlotGridError( ImageRaw, GridData, RegionGrowingResults, GridError, ExpObjSize, Parameter )

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
    %Based on the results of the spatial linearty estimation this method
    %plots the results. The slices is plottet and each grid element of
    %overlayed with an arrow indication the direction and level of
    %distortion.

    MapType     = 2;
    % 1     = Colored Segementation
    % 2     = Colored Arrows

    figure(52)
    set(52, 'Visible', Parameter.GEN.PlotVisible)
    
    PixelSpacing                = Parameter.SL.PixelSpacing;
    [ SizeY, ~ ]                = size(ImageRaw);
    [ CellSizeY, CellSizeX ]    = size(GridData);
    %First part of the Colormap is grayscale (for PhantomSlice), second
    %part is a real Colormap (blue to red) for the ObjectErrors
    GrayNum     = 1000;
    ColorNum    = 1000;
    GrayCMAP    = [linspace(0, 1, GrayNum )', linspace(0, 1, GrayNum )', linspace(0, 1, GrayNum )'];
    ColorCMAP   = colormap(jet(ColorNum)); %[linspace(0, 1, GrayNum )', zeros(1000,1), linspace(1, 0, ColorNum )'];
    Colormap    = [GrayCMAP; ColorCMAP];
    
    Image       = ImageRaw / max(max(ImageRaw)) * GrayNum;
    
    Errorvector = [GridError{:}];
    MinError    = 0;        %min(Errorvector(1:2:end));    
    MaxError    = 1;     %max(Errorvector(1:2:end));
    Radius      = ExpObjSize * 0.6;

    if MapType == 1
        %This Loop sets the values of the segemtation result in the
        %Image-Matrix to the correct pixel colors (according to the error)
        for xInd = 1 : CellSizeX
            for yInd = 1 : CellSizeY
                if ~isempty(RegionGrowingResults{yInd, xInd})
                    RegionGrowingResult                 = RegionGrowingResults{yInd ,xInd};
                    [yVec, xVec]                        = find(RegionGrowingResult > 0);
                    Image(yVec + SizeY * (xVec - 1))    = GrayNum + GridError{yInd, xInd}(1) / MaxError * ColorNum;
                end
            end
        end
    end
    
    imshow( Image, Colormap )
    set(52, 'Position', get(0,'Screensize'));
    
    if MapType == 2
        hold on
        %This Loop draws the error-arrows according to the corresponding
        %error-value and the error-angle
        for xInd = 1 : CellSizeX
            for yInd = 1 : CellSizeY
                if ~isempty(GridData{yInd, xInd})
                    CenterX     = GridData{yInd, xInd}(1);
                    CenterY     = GridData{yInd, xInd}(2);
                    Error       = GridError{yInd, xInd}(1);
                    Angle       = GridError{yInd, xInd}(2);   
                    DrawArrow( CenterX, CenterY, Radius, Angle, Radius * 0.4, ColorCMAP(min(ColorNum ,ceil(Error / MaxError * 1000)),:) );                end
            end
        end
    end    
    
    cbh = colorbar;
    set(cbh,'YLim',[1000,2000])
    set(get(cbh,'ylabel'),'String', 'Real-Ideal-GridDistance [mm]');
    Num = length(get(cbh,'YTickLabel'));
    set(cbh,'YTickLabel',linspace(MinError,MaxError,Num))

end

