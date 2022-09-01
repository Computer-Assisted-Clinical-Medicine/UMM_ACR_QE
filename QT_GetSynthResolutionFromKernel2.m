function W_final = QT_GetSynthResolutionFromKernel2( Sigma, F )

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
    
    %use numerical approach and a set of rect-functions to estimate
    %resolution
    
    %get raw resolution
    W_raw = 2*QT_GetSynthResolutionFromKernel( Sigma, F );
    
    W_final = W_raw;
    
%     W_max = ceil(2*W_raw);
%     W_min = max([1,floor(1/2*W_raw)]);
%     
%     W_vec = W_min : 0.5 : W_max;
%     F_vec = nan(numel(W_vec),1);
%     
%     for k = 1 : numel(F_vec)
%        [ Diff, ~, ~ ] = QT_ConvolveRect( W_vec(k), Sigma );
%        F_vec(k) = Diff;
%     end
%     
%     %get crosssection with y=F by interpolation
%     W_int   = linspace(W_min, W_max,10000);
%     F_int   = interp1(W_vec,F_vec,W_int,'cubic');
%     W_index = find(F_int >= F,1,'first');
%     
%     W_final = W_int(W_index);
%     F_final = F_int(W_index);
%     
%     figure
%     hold on
%     box on
%     grid on
%     
%     plot(W_int,F_int)
%     plot(W_vec,F_vec,'*r')
%     plot(W_final,F_final,'x','Markersize',7,'Linewidth',4,'Color','green')
