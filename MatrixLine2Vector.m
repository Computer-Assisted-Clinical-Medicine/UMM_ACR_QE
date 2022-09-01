function Vector = MatrixLine2Vector( Matrix, xIndex1, yIndex1, xIndex2, yIndex2 )
    

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
    %From a given matrix and two points extract all pixel values linearly
    %between the two points (used in the extraction of the grayvalue 
    %paths for resolution estimation)

    %PreProcessing
    xIndex1 = round(xIndex1);
    yIndex1 = round(yIndex1);
    xIndex2 = round(xIndex2);
    yIndex2 = round(yIndex2);
    
    %Transform InputValues if LinAngle is larger than 45°
    if abs(xIndex2 - xIndex1) < abs(yIndex2 - yIndex1) 
        Matrix = Matrix';
        Temp1 = xIndex1;
        Temp2 = xIndex2;
        xIndex1 = yIndex1;
        xIndex2 = yIndex2;
        yIndex1 = Temp1;
        yIndex2 = Temp2;
        %Error('Transposed Matrix')
        %disp(['New Index1: x = ',num2str(xIndex1),'; y = ',num2str(yIndex1)])
        %disp(['New Index2: x = ',num2str(xIndex2),'; y = ',num2str(yIndex2)])
    end

    %Error Handling
    if  (xIndex1 == xIndex2) && (yIndex1 == yIndex2)
        %Error('WARNING: Points do equal!')
        Vector = Matrix(yIndex1, xIndex1);
    else
        %Extract Corresponding Vector from Matrix
        [ ySize , ~] = size(Matrix);
        m   = (yIndex2 - yIndex1)/(xIndex2 - xIndex1) ;
        n   = yIndex1 - m * xIndex1 ;
        f   = @(x) m * x + n ;
        %xInd = min(xIndex1, xIndex2) : max(xIndex1, xIndex2);
        xInd = xIndex1 : MySign(xIndex2-xIndex1) : xIndex2;
        yInd = round(f(xInd));
        Vector  = Matrix(yInd + ySize * (xInd - 1));
    end
    
        
end

