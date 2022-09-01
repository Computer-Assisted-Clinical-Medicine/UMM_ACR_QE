function [ RootVector, MinVec, MaxVec, DistVec ] = MatrixLineRootMTF( Matrix, xIndexVector, yIndexVector, AxesHandle )


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

    %this function is used to finally extract the information from the
    %image that is used to calculate the MTF-values. The input is an
    %arbitrary matrix (in this case the image), and two vectors of equal
    %length representing the root-points, that define the route, that is
    %used to calculate the MTF-values. In detail, the following is done:
    %
    %   1)  for each pair of two root-points (x_(n),y_(n)) and 
    %       (x_(n+1),y_(n+1)) and, extract
    %       all pixel-values, that represent the line connecting the two
    %       root-points.
    %   2)  for each of these sub-vectors, define the maximum of the
    %       vector to be the first pixel value (as the root-values 
    %       represent the peaks of the image) and the minimum is the
    %       minimum of the vector. the distance is simply the distance of
    %       the two root-points
    %   3)  for each of these three sub-vectors, do the same calculation.
    %       All four subvectors are concatenated, all min's (3), max's (4) and
    %       dist's (3) are stored in vectors
    %   4)  for the last subvector, define the last maximum #1 as the
    %       value of the last root-point
    %   

    %only for testing purpose
    Test = 0;
    if Test == 1
        Matrix = [ 1  2  3  4  5  6  7  8;  ...
                   9  10 11 12 13 14 15 16; ...
                   17 18 19 20 21 22 23 24; ...
                   25 26 27 28 29 30 31 32; ...
                   33 34 35 36 37 38 39 40; ...
                   41 42 43 44 45 46 47 48; ...
                   49 50 51 52 53 54 55 56];
        xIndexVector = [1, 7, 7, 1];
        yIndexVector = [1, 1, 7, 7];
    end

    [NumOfRoots, ~] = size(xIndexVector);
    RootVector      = [];
    MinVec          = nan(NumOfRoots - 1, 1);
    DistVec         = nan(NumOfRoots - 1, 1);    
    MaxVec          = nan(NumOfRoots, 1);
    MinIndices      = nan(NumOfRoots - 1, 1);
    
    for Index = 1 : NumOfRoots - 1
        %disp(['Checking Root: (',num2str(xIndexVector(Index)),',',num2str(yIndexVector(Index)),') to (',num2str(xIndexVector(Index + 1)),',',num2str(yIndexVector(Index + 1)),') : ', num2str(Matrix(yIndexVector(Index),xIndexVector(Index))),' --> ',num2str(Matrix(xIndexVector(Index),yIndexVector(Index)))])
        CurrentRootVector = MatrixLine2Vector( Matrix, ...
                                               xIndexVector(Index),        yIndexVector(Index), ...
                                               xIndexVector(Index + 1),    yIndexVector(Index + 1));
        if ~isempty(AxesHandle)
            set(gcf,'CurrentAxes',AxesHandle)
            hold on
            line([xIndexVector(Index) xIndexVector(Index + 1)],[yIndexVector(Index),yIndexVector(Index + 1)],'Color','red','Linewidth',2);
        end
        
        [~ , MinIndices(Index)] = find(CurrentRootVector == min(CurrentRootVector),1,'first');
        MinVec(Index)           = CurrentRootVector(MinIndices(Index));
        MinIndices(Index)       = MinIndices(Index) + max(length(RootVector),1) - 1;                               
        RootVector              = [ RootVector(1 : end - 1), CurrentRootVector ];
        DistVec(Index)          = 0.5 * sqrt((xIndexVector(Index) - xIndexVector(Index + 1))^2 + (yIndexVector(Index) - yIndexVector(Index + 1))^2);
    end
    
    %RootVector
    MinIndices = [1, MinIndices', numel(RootVector)];
    for Index = 1 : NumOfRoots
        SubVector           = RootVector(MinIndices(Index) : MinIndices(Index + 1));
        MaxVec(Index)       = max(SubVector);
    end

end