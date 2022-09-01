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
    
    % ===============================================
    
    %Method Description:
    %-------------------
    %
    % this script performs the actual evalution of the phantom datasets
    % contained in the DatasetList-list


%Save Plots and Graphs created during evaluation
DoSaveResults = 1;
DoSavePlots   = 1;
DoPlotVisible = 0;

%Only load Dataset, stop before calculation (only for testing purpose)
BreakAfterLoad  = 0;

%add further entrys here to evaluated
DatasetList = {...
{ 1, 'Skyra - 000000000000 (SIEMENS) 2012-11-14-14_09_00.0 - SessionA - T2.mat', 1  } ;...
};

%if set to one, all Datasets of the corresponding site are being evaluated
%(only if ONLYINDEX is set to nan)
AllBERLIN       = 0;
AllDRESDEN      = 0;
AllDUBLIN       = 0;
AllHAMBURG      = 0;
AllLONDON       = 0;
AllMANNHEIM     = 0;
AllNOTTINGHAM   = 0;
AllPARIS        = 0;
%if ONLYINDEX is ~nan, the dataset with the corresponding index will be
%evaluated
ONLYINDEX       = 1;

%==========================================================================
%====                                                                 =====
%====                     P R E F E R E N C E S                       =====
%====                                                                 =====
%==========================================================================

Perform_AcqParams           = 1;
Perform_ImageUniformity     = 1;
Perform_SignalToNoise       = 1;
Perform_Resolution          = 1;
Perform_SpatialLinearity    = 1;
Perform_ChemicalShift       = 1;

%====================================

SiteBool  = cellfun(@(Line) max([   ~isempty(strfind(Line{2},'BERLIN')) * AllBERLIN ,...
                                    ~isempty(strfind(Line{2},'DRESDEN')) * AllDRESDEN ,...
                                    ~isempty(strfind(Line{2},'DUBLIN')) * AllDUBLIN ,...
                                    ~isempty(strfind(Line{2},'HAMBURG')) * AllHAMBURG ,...
                                    ~isempty(strfind(Line{2},'LONDON')) * AllLONDON ,...
                                    ~isempty(strfind(Line{2},'MANNHEIM')) * AllMANNHEIM ,...
                                    ~isempty(strfind(Line{2},'NOTTINGHAM')) * AllNOTTINGHAM ,...
                                    ~isempty(strfind(Line{2},'PARIS')) * AllPARIS ]), DatasetList) ;

if ~isnan(ONLYINDEX)
   SiteBool(:) = 0;
   SiteBool(ONLYINDEX) = 1;
end

[NumOfDatasets, ~] = size(DatasetList);
FailCounter = 0;
FailCell    = {};

%Warnings
if ~DoSaveResults
    Error('=======================================')
    Error('=== WARNING: Results are not saved! ===')
    Error('=======================================')
end

for DatasetIndex = 1 : NumOfDatasets
if SiteBool(DatasetIndex) == 1    

    close all
    
    %Load Dataset, check, if all Slices are valid, remove invalid slices
    Dataset     = load(['Phantom Datasets/',DatasetList{DatasetIndex}{2}]);
    Dataset     = Dataset.Dataset;
    Dataset     = CheckDataset( Dataset );
    
    %imshowSc(Dataset.Image{abs(Dataset.Index_RES)})

    %==========================================================================
    %====                                                                 =====
    %====                      P A R A M E T E R S                        =====
    %====                                                                 =====
    %==========================================================================

    % General
    Parameter.GEN.SaveFolder            = DatasetList{DatasetIndex}{2}(1 : end - 4);
    Parameter.GEN.CommandCell           = {'CommandOutput File for:',['>>> ',Parameter.GEN.SaveFolder],''};
    Parameter.GEN.SavePath              = ['Phantom Results/', DatasetList{DatasetIndex}{2}(1 : end - 4) ];
    Parameter.GEN.Threshold             = 1000;         %DEFAULT, will be changed
    Parameter.GEN.Angle                 = 0;            %DEFAULT, will be changed
    
    switch DoPlotVisible
        case 1
            Parameter.GEN.PlotVisible   = 'on';
        case 0
            Parameter.GEN.PlotVisible   = 'off';
    end
    
    %Start Values for Center
    Parameter.GEN.CenterX               = nan;
    Parameter.GEN.CenterY               = nan;
    Parameter.GEN.Radius                = nan;

    % =================================
    % ========= Localization ==========
    % =================================
    %greatest tilt angle allowed in all three dimensions, warning is thrown
    %if exceeded
    Parameter.LOC.MaxTiltAngle          = 1;
    
    % =================================
    % ======== Signal-To-Noise ========
    % =================================
    %Relative size of SNR-ROI for Mean Calculation (based on Radius)
    Parameter.SNR.RelInnerROIRadius     = 0.8;
    %if set to one, all four STD-ROIs are set to have equal size
    Parameter.SNR.EqualSTDAreas         = 1;
    %if set to one, STD-ROIs are set to be positioned in the corners of the
    %image, otherwise the are right next to the phantoms border
    Parameter.SNR.BorderROIinCorner     = 0;
    %relative space between edge of Phantom and Ghost-ROIs based on Radius
    Parameter.SNR.BorderROIMargin       = 0.025;
    %Relative Minimum Margin Size at each Edge based on Phantom Radius
    Parameter.SNR.MinEdgeMargin         = 0.06;
    Parameter.SNR.MaxEdgeMargin         = 0.1;
    %Relative Size of ROI based on real MinEdgeMargin of Dataset 
    %(Size perpendicular to circle)
    Parameter.SNR.ROISizePerp           = 0.9;
    %Relative Size of ROI based on Diameter (!!!) of Phantom 
    %(Size tangential to circle)
    Parameter.SNR.ROISizeTang           = 0.75;

    % Image Uniformity
    Parameter.IU.RadialSection          = 0.8;
    % =================================
    % ======= Spatial Linearity =======
    % =================================
    % Range of valid areas based
    Parameter.SL.AreaRange              = [0.5, 1.5];
    Parameter.SL.RelExpObjectSize       = 0.14;
    Parameter.SL.BiSinFit               = 0;
    
    if Dataset.Info{2}.PixelSpacing(1) == Dataset.Info{2}.PixelSpacing(2)
        Parameter.SL.PixelSpacing   = Dataset.Info{2}.PixelSpacing(1);
        Parameter.RES.PixelSpacing  = Dataset.Info{2}.PixelSpacing(1);
    else
        Error('WARNING: Inconsistent Pixel-Spacing in x and y!')
    end

    %Resolution
    Parameter.RES.AdjustPeak                    = 2;
    %   = 0:    none
    %   = 1:    by max
    %   = 2:    by fit
    Parameter.RES.RemoveGrayValueGradient       = 1;
    Parameter.RES.RelRegionSizeRadius           = 0.1314;
    Parameter.RES.RelGradientAreaRadius         = 0.0395;
    Parameter.RES.RelProfileRegionRadius        = 0.0075;
    Parameter.RES.PeakFitArea                   = [0.0074, 0.0056, 0.0037];
    Parameter.RES.GrayvalueVisibilityThreshold  = 200;

    %==========================================================================
    %====                                                                 =====
    %====              R E F E R E N C E    V A L U E S                   =====
    %====                                                                 =====
    %==========================================================================

    % Performance Criteria:
    %   Phantom Diameter: 190 +- 2mm
    %   Integral Uniformity > 0.82
    %   Ghosting Ratio < 0.025
    %   SNR ???  
    %   Spatial Linearty ???
    %   Resolution ???
    %
    % Cross Check Parameter
    %   Resolution Grid, Sizes of 1.1, 1.0 and 0.9 mm
    %
    % Imaging Protocols
    %
    %   Saggital Localizer: TR = 200 ms, TE = 20 ms, 256x256 matrix, 25 cm
    %                       FOV, 10 mm slice thickness, NSA=1, single 
    %                       saggital slice (52 seconds). Landmark on the 
    %                       center reference line.
    %   T1 Weighted Multislice Study: 
    %                       TR = 500 ms, TE = 20 ms, 256x256 matrix, 
    %                       25 cm FOV, 12 slices, 5 mm slice thickness 
    %                       with 5 mm gap in between, NSA=1(2.2 minutes). 
    %                       Begin at center of front set of wedges
    %                       as seen in localizer.
    %   T2 Weighted Multislice Multiecho Study: 
    %                       TR = 2000 ms, TE1 = 20 ms, TE2 = 80 ms, 
    %                       256x256 matrix, 25 cm FOV, 12 slices, 5 mm 
    %                       slice thickness with 5 mm gap in between, 
    %                       NSA=1(8.5 minutes). Begin at center of front 
    %                       set of wedges as seen in localizer.
    % Localizer

    %% Set pass criteria, if desired
    % Image Uniformity
    Reference.Result_IU.Smax                    = [];
    Reference.Result_IU.Smin                    = [];
    Reference.Result_IU.Span                    = [];
    Reference.Result_IU.Midrange                = [];
    Reference.Result_IU.IntegralUniformity      = [0.82, 1];

    % Signal-To-Noise
    Reference.Result_SNR.InnerMean              = [];
    Reference.Result_SNR.BorderSTD              = [];
    Reference.Result_SNR.SNR                    = [];
    Reference.Result_SNR.SNRCorr                = [];
    Reference.Result_SNR.GhostingRatio      	= [0, 0.025];

    % Spatial Linearity
    Reference.Result_SL.MaxError                = [0,3];
    Reference.Result_SL.MinError                = [];
    Reference.Result_SL.MeanError               = [0,1];
    Reference.Result_SL.STDError                = [];
    
    % Resolution
    Reference.Result_RES.MinResolveableDetailSizeH 	= [0, 1];
    Reference.Result_RES.MinResolveableDetailSizeV 	= [0, 1];    
    
    % Chemical Shift
    Reference.Result_CS.PixelChemicalShiftX         = [];
    Reference.Result_CS.PixelChemicalShiftY         = [];    
    Reference.Result_CS.MillimeterChemicalShiftX 	= [];
    Reference.Result_CS.MillimeterChemicalShiftY 	= [];

 	%==========================================================================
    %====                                                                 =====
    %====             R E S U L T   P R E P A R A T I O N                 =====
    %====                                                                 =====
    %==========================================================================   
    
    if exist([Parameter.GEN.SavePath,'\',Parameter.GEN.SaveFolder,'.mat'],'file')
        load([Parameter.GEN.SavePath,'\',Parameter.GEN.SaveFolder,'.mat']);
        disp('Old Result-file will be used as basis!')
    else
        Result      = [];
        disp('Empty Result-file will be used!')
    end

    %==========================================================================
    %====                                                                 =====
    %====               C  A  L  C  U  L  A  T  I  O  N                   =====
    %====                                                                 =====
    %==========================================================================

    %Create Folder for Results
    if ~exist(Parameter.GEN.SavePath,'dir')
       mkdir('Phantom Results',Parameter.GEN.SaveFolder) 
    end
    
    %Create Folders for saving
    PrepareSaveFolders()

    %First of all, estimate the Threshold
    Parameter = DetermineThreshold( Dataset.Image{abs(Dataset.Index_IU)}, Parameter ); %.GEN.Threshold

    %All position parameters such as center, radius and angle are determined
    %using the start values from the "raw" data given by the
    %DetermineThreshold-function; afterwards these startvalues will be replaced
    %by the accurate results which will be further used as startvalues

    %FigureHandle -- 1 --
    [CenterX, CenterY, Radius, Angle, ~] = GetPhantomCenter( Dataset.Image{abs(Dataset.Index_LOC)}, Parameter, 1, 0, 1 );
    if DoSavePlots
        SavePlot( Parameter, 'LOC', 1 )
    end

    %Save the position paramters to be used as start values for upcoming
    %calculations, if needed
    Parameter.GEN.CenterX   = CenterX;
    Parameter.GEN.CenterY   = CenterY;
    Parameter.GEN.Radius    = Radius;
    Parameter.GEN.Angle     = Angle;
    
    %% Acqusition Parameters
    if Perform_AcqParams == 1
        Result.Result_AP = [];
        try
            Parameter = WriteTitleToCommand( 'Now Doing: Acquisitions Parameters', Parameter);
            [Result_AP, Parameter] = MeasureAcquisitionParameters( Dataset, Parameter );
        
            %Parameter = WriteResultsToCommand(Result_IU, Reference.Result_IU, Parameter);
        catch exception
            FailCounter = FailCounter + 1;
            warning('WarnTests:convertTest','AcqParams failed!')
            Result_AP   = [];
            FailCell    = [FailCell; {Parameter.GEN.SaveFolder, 'AcqParams', exception}];
        end
        Result.Result_AP = Result_AP;
    end

    if BreakAfterLoad
        Error('WARNING: stopped without calculation!')
        break;
    end
    
    %First of all, the SNR & IU-Calculations are being performed, the get the
    %Threshold for all the other calculations
    %% Image Uniformity
    if Perform_ImageUniformity == 1
        Result.Result_IU = [];
        try
            %FigureHandle -- 20... --
            Parameter = WriteTitleToCommand( 'Now Doing: Image Uniformity', Parameter);
            [Result_IU, Parameter] = MeasureImageUniformity( Dataset.Image{abs(Dataset.Index_IU)}, Parameter );
            
            if DoSavePlots == 1
                SavePlot( Parameter, 'IU', 20 )
            end

            Parameter = WriteResultsToCommand(Result_IU, Reference.Result_IU, Parameter);
        catch exception
            FailCounter = FailCounter + 1;
            warning('WarnTests:convertTest','ImageUniformity failed!')
            Result_IU   = [];
            FailCell    = [FailCell; {Parameter.GEN.SaveFolder, 'ImageUniformity', exception}];
        end
        Result.Result_IU = Result_IU;
    end

    %% SignalToNoise Ratio
    if Perform_SignalToNoise == 1
        Result.Result_SNR = [];
        try
            %FigureHandle -- 30... --
            Parameter = WriteTitleToCommand( 'Now Doing: Signal-To-Noise-Ratio', Parameter);
            [Result_SNR, Parameter] = MeasureSNR( Dataset.Image{abs(Dataset.Index_SNR)}, Parameter );
            
            if DoSavePlots == 1
                SavePlot( Parameter, 'SNR', 30 )
            end
            
            Parameter = WriteResultsToCommand(Result_SNR, Reference.Result_SNR, Parameter);
        catch exception
            FailCounter = FailCounter + 1;
            warning('WarnTests:convertTest','SignalToNoise failed!')
            Result_SNR   = [];
            FailCell    = [FailCell; {Parameter.GEN.SaveFolder, 'SignalToNoise', exception}];
        end
        Result.Result_SNR = Result_SNR;
    end

    %write SNR parameter to be used in the resolution analysis to calculate
    %the FWHM amplitude
    Parameter.RES.GrayvalueVisibilityThreshold  = 0.05 * Result.Result_SNR.InnerMean;
    
    %% Image Resolution
    if Perform_Resolution == 1
        Result.Result_RES = [];
        try
            %FigureHandle -- 40... --
            Parameter = WriteTitleToCommand( 'Now Doing: Resolution', Parameter);
            [Result_RES, Parameter] = MeasureResolution( Dataset.Image{abs(Dataset.Index_RES)}, Parameter );
        
            if DoSavePlots == 1
                SavePlot( Parameter, 'RESLOC', 41 )
                SavePlot( Parameter, 'RES1', 42 )
                SavePlot( Parameter, 'RES2', 43 )
                SavePlot( Parameter, 'RES3', 44 )
                SavePlot( Parameter, 'RESSUM', 45 )
            end
                
            Parameter = WriteResultsToCommand(Result_RES, Reference.Result_RES, Parameter);
        catch exception
            FailCounter = FailCounter + 1;
            warning('WarnTests:convertTest','Resolution failed!')
            Result_RES   = [];
            FailCell    = [FailCell; {Parameter.GEN.SaveFolder, 'Resolution', exception}];
        end    
        Result.Result_RES = Result_RES;
    end

    %% Spatial Linearity
    if Perform_SpatialLinearity == 1
        Result.Result_SL = [];
        try
            %FigureHandle -- 50... --
            Parameter = WriteTitleToCommand( 'Now Doing: Spatial Linearity', Parameter);
            [Result_SL, Parameter] = MeasureSpatialLinearity( Dataset.Image{abs(Dataset.Index_SL)}, Parameter );
            
            if DoSavePlots == 1
                SavePlot( Parameter, 'SL',    50 )
                SavePlot( Parameter, 'SLMAP', 52 )
            end

            Parameter = WriteResultsToCommand(Result_SL, Reference.Result_SL, Parameter);
        catch exception
            FailCounter = FailCounter + 1;
            warning('WarnTests:convertTest','SpatialLinearity failed!')
            Result_SL   = [];
            FailCell    = [FailCell; {Parameter.GEN.SaveFolder, 'SpatialLinearity', exception}];
        end       
        Result.Result_SL = Result_SL;
    end

    %% Chemical Shift and Image Bandwidth
    if Perform_ChemicalShift == 1
        Result.Result_CS = [];
        try
            %FigureHandle -- 50... --
            Parameter = WriteTitleToCommand( 'Now Doing: Chemical Shift', Parameter);
            [Result_CS, Parameter] = MeasureChemicalShift( Dataset.Image{abs(Dataset.Index_RES)}, Parameter, Result_AP );
            
            if DoSavePlots == 1
                SavePlot( Parameter, 'CS',  61 )
                SavePlot( Parameter, 'CSG', 62 )
            end

            Parameter = WriteResultsToCommand(Result_CS, Reference.Result_CS, Parameter);
        catch exception
            FailCounter = FailCounter + 1;
            warning('WarnTests:convertTest','Chemical Shift failed!')
            Result_CS   = [];
            FailCell    = [FailCell; {Parameter.GEN.SaveFolder, 'Chemical Shift', exception}];
        end       
        Result.Result_CS = Result_CS;
    end
    
    %% Saving
    SaveCommandText( Parameter )
    
    %Save Results
    Result.Parameter = Parameter;
    Dataset.Image    = [];
    Result.Dataset   = Dataset;

    if DoSaveResults
        save([Parameter.GEN.SavePath,'\',Parameter.GEN.SaveFolder,'.mat'], 'Result')
    end
    close all
    
end
end

if FailCounter > 0
	disp(FailCell)
    error('Error occured during calculation:')
end