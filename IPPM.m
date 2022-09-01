function [ GridDataNew, Result_SL ] = IPPM( GridData, Result_SL )

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
    %
    %IPPM :: Iterative Point-Point-Matching
    %This algorithm performs an iterative opimization approach to adjust
    %the ideal-grid to the real-grid. At each step, the possible
    %improvement by Shift, Rotation and Dilation is being performed and the
    %operation providing the optimal effect is being applied to the data.
    %Once no further improvement is possible the algorithm stops. The
    %solution is optimized in terms of least-squares...
    
    Weights         = [-4.5 -3.5 -2.5 -1.5 -0.5 0.5 1.5 2.5 3.5 4.5];
    RealXY          = nan(numel(GridData),2);
    IdealXY         = nan(numel(GridData),2);
    
    [SizeY, SizeX] = size(GridData);
    %% Create Input Vectors
    Counter = 1;
    for xInd = 1 : SizeX
        for yInd = 1 : SizeY
            if ~isempty(GridData{yInd, xInd})
                IdealX  = Weights(xInd) * Result_SL.GridSpace + Result_SL.GridCenterX;
                IdealY  = Weights(yInd) * Result_SL.GridSpace + Result_SL.GridCenterY;
                [ IdealXAdj, IdealYAdj ] = AdjustAngle( IdealX, IdealY, Result_SL.GridCenterX, Result_SL.GridCenterY, atan(Result_SL.GridSlope) );
            
                RealX   = GridData{yInd, xInd}(1);
                RealY   = GridData{yInd, xInd}(2);
                
                %Store Values
                RealXY(Counter,:)      = [RealX,  RealY];
                IdealXY(Counter,:)     = [IdealXAdj, IdealYAdj];
                
                Counter = Counter + 1;
            end
        end
    end
    
    RealXY( isnan(RealXY(:,1)),:) = [];
    IdealXY(isnan(IdealXY(:,1)),:) = [];
    
    %IPPM_Plot( RealXY, IdealXY, 100 ) 
    
    OldError        = IPPM_GetError( RealXY, IdealXY );  
    %disp(['   Error Vector: ',num2str(OldError)])
    %OldResult_SLError  = IPPM_GetError( RealXY, IPPM_CreateVectorFromResult_SL( GridData, Result_SL ) );
    %disp(['ResultSL Vector: ',num2str(OldResult_SLError)])
    %IPPM_Plot( RealXY, IdealXY, 1 ) 
    
    Done        = 0;
    Counter     = 0;
    ErrorVector = nan(3,1);
    NewError    = nan;
    
    PlotAllSteps    = 0;
    
    while Done == 0
        Counter = Counter + 1;
        %Calculate Error Vectors

        [IdealXYNew1, Result_SL1, ErrorVector(1)] = IPPM_PerformShift( RealXY, IdealXY, Result_SL );
        [IdealXYNew2, Result_SL2, ErrorVector(2)] = IPPM_PerformRotation( RealXY, IdealXY, Result_SL );
        [IdealXYNew3, Result_SL3, ErrorVector(3)] = IPPM_PerformDilation( RealXY, IdealXY, Result_SL );
               
        if ErrorVector(1) <= 0 && ErrorVector(2) <= 0 && ErrorVector(3) <= 0
            Done = 1;
%             disp([' >>> Converged after ',num2str(Counter),' Iterations!'])
%             disp(['      - Old Error ',num2str(OldError)])
%             disp(['      - New Error ',num2str(NewError)])
%             disp([' --> Error decreased by ',num2str(OldError - NewError)])
        else
            MaxEffect = find(ErrorVector == max(ErrorVector),1,'first');
            switch MaxEffect
                case 1
                    %Perform Shift-Operation
                    IdealXY     = IdealXYNew1;
                    Result_SL   = Result_SL1;
                    LastOp      = 'Shift';
                case 2
                    %Perform Rotation-Operation
                    IdealXY     = IdealXYNew2;
                    Result_SL   = Result_SL2;
                    LastOp      = 'Rotation';
                case 3
                    %Perform Dilation-Operation
                    IdealXY     = IdealXYNew3;
                    Result_SL   = Result_SL3;  
                    LastOp      = 'Dilation';
            end
            NewError = IPPM_GetError( RealXY, IdealXY );
%             fprintf(2,[' >>> New Error: ',num2str(NewError),'\n']);
            
            if PlotAllSteps == 1
%                disp(['Result_SL after step #',num2str(gcf + 1), '(',LastOp,')'])
%                disp(Result_SL)
               IPPM_Plot( RealXY, IdealXY, gcf + 1 ) 
            end
            
        end
    end
    
    %IPPM_Plot( RealXY, IdealXY, 2 ) 
    %disp('--------------------------------')
    %NewError        = IPPM_GetError( RealXY, IdealXY );    
    %disp(['   Error Vector: ',num2str(NewError)])
    %NewResult_SLError  = IPPM_GetError( RealXY, IPPM_CreateVectorFromResult_SL( GridData, Result_SL ) );
    %disp(['ResultSL Vector: ',num2str(NewResult_SLError)])    
    
    %Adjust GridData
    Counter     = 1;
    GridDataNew = cell(SizeY, SizeX);
    for xInd = 1 : SizeX
        for yInd = 1 : SizeY
            
            if ~isempty(GridData{yInd, xInd})
                GridDataNew{yInd, xInd} = [nan nan];        
                
                GridDataNew{yInd, xInd}(1) = RealXY(Counter,1);
                GridDataNew{yInd, xInd}(2) = RealXY(Counter,2);

                Counter = Counter + 1;
            end
        end
    end
    
    
    
end

