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
    %this script load the quality test results in QA Results and performs some
    %averaging. Perform all QT methods (QT_Test...) before running this
    %script

%Translation and Rotation
if exist('QA Results\QA_Localization.mat','file')
    F = load('QA Results\QA_Localization.mat');
    %rel shift error
    RealVec         = F.RealShift;
    EstVec          = F.EstShiftMean;
    Norm            = F.RealShift;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Translation    :: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
    
    %rel angle error
    RealVec         = F.RealAngle;
    EstVec          = F.EstAngle;
    Norm            = F.RealAngle;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Rotation       :: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Homogeneity
if exist('QA Results\QA_Homogeneity.mat','file')
    F = load('QA Results\QA_Homogeneity.mat');
    %rel shift error
    RealVec         = F.RealInhomogeneity;
    EstVec          = F.EstInhomogeneity;
    Norm            = F.RealInhomogeneity;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Homogeneity    :: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Signal to Noise
if exist('QA Results\QA_SNR.mat','file')
    F = load('QA Results\QA_SNR.mat');
    %rel shift error
    RealVec         = F.RealSNR;
    EstVec          = F.EstSNR;
    Norm            = F.RealSNR;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('SNR            :: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Chemical Shift
if exist('QA Results\QA_ChemicalShift.mat','file')
    F = load('QA Results\QA_ChemicalShift.mat');
    %rel shift error
    RealVec         = F.RealChemShift;
    EstVec          = F.EstChemShift;
    Norm            = F.RealChemShift;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Chemical Shift :: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Ghosting
if exist('QA Results\QA_Ghosting.mat','file')
    F = load('QA Results\QA_Ghosting.mat');
    %rel shift error
    RealVec         = F.RealGhost;
    EstVec          = F.EstGhost;
    Norm            = F.RealGhost;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Ghosting       :: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Resolution Horizontal
if exist('QA Results\QA_ResFull.mat','file')
    F = load('QA Results\QA_ResFull.mat');
    %rel shift error
    RealVec         = F.RealVec;
    EstVec          = F.EstVecH;
    Norm            = F.RealVec;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Resolution hor.:: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Resolution Vertical
if exist('QA Results\QA_ResFull.mat','file')
    F = load('QA Results\QA_ResFull.mat');
    %rel shift error
    RealVec         = F.RealVec;
    EstVec          = F.EstVecV;
    Norm            = F.RealVec;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Resolution ver.:: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Resolution Full
if exist('QA Results\QA_ResFull.mat','file')
    F = load('QA Results\QA_ResFull.mat');
    %rel shift error
    RealVec         = [F.RealVec, F.RealVec];
    EstVec          = [F.EstVecV, F.EstVecH];
    Norm            = [F.RealVec, F.RealVec];
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Resolution full:: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end

%Deformation
if exist('QA Results\QA_SpatialLinearity.mat','file')
    F = load('QA Results\QA_SpatialLinearity.mat');
    %rel shift error
    RealVec         = F.RealDistortion;
    EstVec          = F.EstDistortion;
    Norm            = F.RealDistortion;
    Norm(Norm == 0) = 1;
    RelError    = abs( (EstVec - RealVec)./Norm ) * 100;
    fprintf('Linearity      :: Range: %.1f...%.1f; Error = %.1f ± %.1f; Max = %.1f\n',...
        min(RealVec),max(RealVec),mean(RelError),std(RelError),max(RelError))
end