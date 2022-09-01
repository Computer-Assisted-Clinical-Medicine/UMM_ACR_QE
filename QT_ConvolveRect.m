function [ Diff, PeakValue, ValleyValue ] = QT_ConvolveRect( Width, Sigma )

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

    %this method convolves a set of rects and determines the hight of the
    %peaks and the valleys

	Res             = 0.01;
    
    %adjust
    Width_adj       = round(Width/Res);
    if mod(Width_adj,2) == 1
        Width_adj = Width_adj + 1;
    end
    %Res_adj         = 1/Width_adj;
    
    %generate signal
    V_full          = [ones(1,Width_adj/2),zeros(1,Width_adj),ones(1,Width_adj/2)];
    
    %filter with gaussian, note, that sigma has to be adjusted defined by
    %Res
    
    Fac             = Width_adj/Width;
    G               = fspecial('gaussian', [1,numel(V_full)], Sigma*Fac);
    %G               = G * Fac;
    V_conv          = imfilter( V_full,G,'symmetric','same');
    
    PeakValue       = max(V_conv);
    ValleyValue     = min(V_conv);
    Diff            = PeakValue - ValleyValue;

%     figure
%     hold on
%     box on
%     grid on
%     ylim([-0.05 1.2])
%     
%     plot((1:numel(V_full))*Res, V_full,'Linewidth',2,'Color','blue')
%     plot((1:numel(V_full))*Res, V_conv,'Linestyle','--','Linewidth',2,'Color','blue')
%     
%     plot((1:numel(V_full))*Res, G,'Linestyle','--','Linewidth',2,'Color','red')
    
    
    