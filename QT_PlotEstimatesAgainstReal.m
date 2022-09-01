function LegHandle = QT_PlotEstimatesAgainstReal( EstVec, RealVec )
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
    %This method is used to plot the estimated quality parameters against
    %the real ones used in the synthetic phantom
    
    %only for testing purpose
    %RealVec  	= [ 100 200 300 400 500 600 700 800 900 1000];
    %EstVec      = [ 120.6256  205.9738  288.4191  373.3550  465.0396  561.8254  653.8758  747.9911  833.6909 930.6898];

%     RealVec     = RealSNR;
%     EstVec      = EstSNR;
    
    figure
    box on
    grid off
    hold on
    
    %plot identity line
    XRange   = max(RealVec) - min(RealVec);
    YRange   = max(EstVec) - min(EstVec);
    
    H1 = line(  [ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ], ...
                [ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ], ...
                'Linewidth',1,'Color',[0.5 0.5 0.5],'Linestyle','-');
    H2 = plot( RealVec, EstVec,'*','Marker','x','Markersize',7,'Linewidth',2,'Color','red' );
    
    set(gcf,'OuterPosition' ,[436   338   484   352])
    set(gcf,'Position'      ,[444   346   468   260])
    set(gca,'OuterPosition' ,[-0.1603   -0.0115    1.2359    0.9923])
    set(gca,'Position'      ,[0.1282    0.1538    0.8440    0.7462])
    
    LegHandle   = legend([H1, H2],'Identity','Estimate vs. ideal parameter');
    set(LegHandle,'Interpreter','latex','Location','NorthWest')
	set(LegHandle,'OuterPosition',  [0.1303    0.7038    0.5085    0.1779])
    set(LegHandle,'Position',       [0.1389    0.7115    0.4957    0.1702])
    
    xlim([ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ])
    %ylim([ min(RealVec) - 0.05 * abs(XRange), max(RealVec) + 0.05 * abs(XRange) ])
    
    xlabel('Ideal parameter [a.u.]','Interpreter','latex','Fontsize',10)
    ylabel('Estimated parameter [a.u.]','Interpreter','latex','Fontsize',10)
    title('Quality Parameter','Fontweight','bold','Interpreter','latex','Fontsize',12)
    
    set(gca,'Fontsize',10)
    
    

