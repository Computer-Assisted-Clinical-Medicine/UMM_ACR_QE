function [Result_SL, Parameter] = MeasureSpatialLinearity( Image, Parameter )

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
    %Based on a given slice of the phantom, the methods tries to etimate
    %the level of geometric distortions in the slice. The slice contains a
    %large grid struture that are being extracted. If no distortions are
    %present, the grid structure elements will be located on an ideal grid.
    %Otherwise shifts will ocur. These shifts are detected by registrating
    %the ideal grid and the grid centers of the measurement.
    
    %Plot grid data over ideal grid
    PlotAfterwards  = 1;
    
    %get angle from parameter-struct 
    Angle                                   = Parameter.GEN.Angle;
    
    %the position and the radius of the phantom is, as always, being
    %calculated for each phantom individually
    [CenterX, CenterY,  Radius  ,   ~  , ~] = GetPhantomCenter( Image,  Parameter, 0, 0, 50 );
    
    %store the results in the Result_SL-struct
    Result_SL.CenterX   = CenterX;
    Result_SL.CenterY   = CenterY;
    Result_SL.Radius    = Radius;
    
    %calculate ExpectedObjectSize and ExpectedObjectVolume based on the
    %parameter RelExpObjectSize (expected diameter of one single object 
    %relatively to the radius of the phantom)
    ExpectedObjectSize                      = round(Radius * Parameter.SL.RelExpObjectSize);
    ExpectedObjectVolume                    = ExpectedObjectSize^2;
    
    % Region Growing Part
    Counter             = 0;
    
    % Load ObjectTemplate, Take the radius into account, perform angular
    % adjustement, and use these values as start values for the
    % RegionGrowing - Algorithm
    ObjectTemplate = load('ObjectTemplate.mat');
    ObjectTemplate = ObjectTemplate.ObjectTemplate;
    [ ObjectTemplate(:,1), ObjectTemplate(:,2) ] = AdjustAngle( ObjectTemplate(:,1) * Radius + CenterX, ... 
                                                                ObjectTemplate(:,2) * Radius + CenterY, ...
                                                                CenterX, ...
                                                                CenterY, ...
                                                                -Angle );
    
    % Create empty variables "GridData" & "RegionGrowingResults" to store
    % the determined data calculated using the region growing
    GridData                 = cell(10, 10);
    RegionGrowingResults     = cell(10, 10);
    
    %now, the following steps are performed for each of the 88 objects of
    %the spatial-linearity-grid:
    for ObjectIndex = 1 : length(ObjectTemplate)
        
       %set counter to current object 
       Counter = Counter + 1;
       
       %Seed points given by the ObjectTemplate-list
       SeedX  = round(ObjectTemplate(ObjectIndex, 1));
       SeedY  = round(ObjectTemplate(ObjectIndex, 2));

       % using the seed-points and the ExpectedObjectSize, an area
       % surrounding the seed is created. Its being used to determine a
       % suitable threshold using a k-means-approach (this is done to 
       % compensate a background gradient over the image, if present)
       SubArea                  = GetCircularROI( Image, SeedX, SeedY, ExpectedObjectSize );
       Threshold                = kmeans(SubArea); 

       % Now the actual RegionGrowing is being performed with the
       % k-means-threshold, and the weight is calculated to validate the
       % object
       Segmentation             = RegionGrowing(Image, SeedX, SeedY, Threshold);
       Weight                   = sum(sum(Segmentation(Segmentation == 1)));

       % If segmented Region has the correct size, it corresponds to a
       % single object of the Phantom-Grid
       if Weight >= Parameter.SL.AreaRange(1) * ExpectedObjectVolume && Weight <= Parameter.SL.AreaRange(2) * ExpectedObjectVolume
           
           %Calculate Center of gravity
           [yVals, xVals]   = find(Segmentation > 0);
           CoG              = [sum(xVals)/numel(xVals), sum(yVals)/numel(yVals)];
           if ~PlotAfterwards
            plot(CoG(1), CoG(2), 'X','Linewidth',2,'Markersize',8,'Color','yellow')
           end
           
           %First, find the correct index using the ObjectTemplate
           % --> Object with minimum distance is being chosen
           Distances = sqrt( (ObjectTemplate(:,1) - CoG(1)).^2 + (ObjectTemplate(:,2) - CoG(2)).^2 );
           Index     = ObjectTemplate(Distances == min(Distances),3);
 
           %Store positions of the objects given by the Center-Of-Gravity
           %(CoG)
           GridData{Index} = [CoG(1), CoG(2)];
           
           %Store the RegionGrowingResults in order to plot them later
           RegionGrowingResults{Index} = Segmentation;
           
           %disp(['Found new CoG at x = ',num2str(CoG(1)),', y = ',num2str(CoG(2)),' --> #',num2str(Index),' (D = ',num2str(min(Distances)),')'])
       end
       pause(0.01)
    end
       
    [ FinalCenterX, FinalCenterY, FinalGridSpace, FinalSlope ] = DetermineGridParameterByFit( GridData, CenterX, CenterY, Parameter );
    Result_SL.GridCenterX   = FinalCenterX;
    Result_SL.GridCenterY   = FinalCenterY;
    Result_SL.GridSpace     = FinalGridSpace;
    Result_SL.GridSlope     = FinalSlope;
    
    %disp('Result_SL after LinFit')
    %disp(Result_SL)
    
    %PostProcessing by IPPM
    [GridData, Result_SL] = IPPM( GridData, Result_SL );
    
    %Plot the Grid Result
    PlotSpatialGrid( Result_SL.GridCenterX, Result_SL.GridCenterY, Result_SL.GridSpace, Result_SL.GridSpace, atan(Result_SL.GridSlope) )
    
    %Plot grid points
    if PlotAfterwards
        Mat = cell2mat(GridData(:));
        plot(Mat(:,1), Mat(:,2), 'X','Linewidth',2,'Markersize',8,'Color','yellow')
    end
    
    %Calculate the ErrorVector for all Objects according to the GridData,
    %calculated by "DetermineGridParameterByFit"
    [GridErrorCell, GridErrorVector] = DetermineGridError( GridData, Result_SL, Parameter.SL.PixelSpacing );
    
    Result_SL.MaxError   = max(GridErrorVector);
    Result_SL.MinError   = min(GridErrorVector);
    Result_SL.MeanError  = mean(GridErrorVector);
    Result_SL.STDError   = std(GridErrorVector);
    
    title(['MeanError = ',num2str(Result_SL.MeanError),' ± ',num2str(Result_SL.STDError),' mm; MaxError = ',num2str(Result_SL.MaxError)])
    
    PlotGridError( Image, GridData ,RegionGrowingResults, GridErrorCell, ExpectedObjectSize, Parameter );
    title(['MeanError = ',num2str(Result_SL.MeanError),' ± ',num2str(Result_SL.STDError),' mm; MaxError = ',num2str(Result_SL.MaxError)])
    
    Result_SL.GridData              = GridData;

end

