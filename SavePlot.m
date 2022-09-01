function SavePlot( Parameter, ID, FigureHandle )
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
    %saves the plots that has been created during evaluation

    switch ID
        case 'LOC'
            ImageTitle  = 'Localizer';
        case 'IU'
            ImageTitle  = 'Image Uniformity';
        case 'SNR'
            ImageTitle  = 'Signal-To-Noise Ratio';
        case 'SL'
            ImageTitle  = 'Spatial Linearity';
        case 'SLMAP'
            ImageTitle  = 'Spatial Linearity - Error Map';
        case 'CON1'
            ImageTitle  = 'Contrast 1';
        case 'CON2'
            ImageTitle  = 'Contrast 2';
        case 'CON3'
            ImageTitle  = 'Contrast 3';
        case 'RES1'
            ImageTitle  = 'Resolution 1';
        case 'RES2'
            ImageTitle  = 'Resolution 2';
        case 'RES3'
            ImageTitle  = 'Resolution 3';
        case 'RESSUM'
            ImageTitle  = 'Resolution Summary';     
        case 'RESLOC'
            ImageTitle  = 'Resolution Localizer';   
        case 'CS'
            ImageTitle  = 'Chemical Shift';    
        case 'CSG'
            ImageTitle  = 'Chemical Shift Gradient';   
        otherwise
            ImageTitle  = 'Undefined';       
    end
    
    set(FigureHandle, 'Position', get(0,'Screensize'));
    saveas(FigureHandle,[Parameter.GEN.SavePath,'\',ImageTitle,'.png'], 'png')
    saveas(FigureHandle,['Single Images\',ImageTitle,'\',Parameter.GEN.SaveFolder,'.png'], 'png')

end

