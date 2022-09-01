function PrepareSaveFolders

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
    %check if the folders for saving the results exist. If any folder does
    %not exist, its being created

    %Phantom Results
    %Create Folder for Results
    if ~exist('Phantom Results','dir')
       mkdir('Phantom Results') 
       disp('Folder Created: Phantom Results')
    end

    %Single Images
    %Main Folder
    if ~exist('Single Images','dir')
       mkdir('Single Images') 
       disp('Folder Created: Single Images')
    end
    
    %SubFolder
    if ~exist('Single Images/Chemical Shift','dir')
       mkdir('Single Images/Chemical Shift') 
       disp('Folder Created: Single Images/Chemical Shift')
    end

    if ~exist('Single Images/Chemical Shift Gradient','dir')
       mkdir('Single Images/Chemical Shift Gradient') 
       disp('Folder Created: Single Images/Chemical Shift Gradient')
    end
    
    if ~exist('Single Images/Contrast 1','dir')
       mkdir('Single Images/Contrast 1') 
       disp('Folder Created: Single Images/Contrast 1')
    end
    
    if ~exist('Single Images/Contrast 2','dir')
       mkdir('Single Images/Contrast 2') 
       disp('Folder Created: Single Images/Contrast 2')
    end
    
    if ~exist('Single Images/Contrast 3','dir')
       mkdir('Single Images/Contrast 3') 
       disp('Folder Created: Single Images/Contrast 3')
    end
    
    if ~exist('Single Images/Image Uniformity','dir')
       mkdir('Single Images/Image Uniformity') 
       disp('Folder Created: Single Images/Image Uniformity')
    end
    
    if ~exist('Single Images/Localizer','dir')
       mkdir('Single Images/Localizer') 
       disp('Folder Created: Single Images/Localizer')
    end
    
    if ~exist('Single Images/Resolution 1','dir')
       mkdir('Single Images/Resolution 1') 
       disp('Folder Created: Single Images/Resolution 1')
    end
    
    if ~exist('Single Images/Resolution 2','dir')
       mkdir('Single Images/Resolution 2') 
       disp('Folder Created: Single Images/Resolution 2')
    end
    
    if ~exist('Single Images/Resolution 3','dir')
       mkdir('Single Images/Resolution 3') 
       disp('Folder Created: Single Images/Resolution 3')
    end
    
    if ~exist('Single Images/Resolution Localizer','dir')
       mkdir('Single Images/Resolution Localizer') 
       disp('Folder Created: Single Images/Resolution Localizer')
    end
    
    if ~exist('Single Images/Resolution Summary','dir')
       mkdir('Single Images/Resolution Summary') 
       disp('Folder Created: Single Images/Resolution Summary')
    end    
    
    if ~exist('Single Images/Signal-To-Noise Ratio','dir')
       mkdir('Single Images/Signal-To-Noise Ratio') 
       disp('Folder Created: Single Images/Signal-To-Noise Ratio')
    end    
    
    if ~exist('Single Images/Spatial Linearity','dir')
       mkdir('Single Images/Spatial Linearity') 
       disp('Folder Created: Single Images/Spatial Linearity')
    end
    
    if ~exist('Single Images/Spatial Linearity - Error Map','dir')
       mkdir('Single Images/Spatial Linearity - Error Map') 
       disp('Folder Created: Single Images/Spatial Linearity - Error Map')
    end  
    
    if ~exist('Single Images/Undefined','dir')
       mkdir('Single Images/Undefined') 
       disp('Folder Created: Single Images/Undefined')
    end 
    
end

