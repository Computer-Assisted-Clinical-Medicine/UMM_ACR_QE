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
%This function creates an excel overview in the MATLAB-folder. The file
%is already existing and must not be opened during function call.

    %this cell should contain all existing Strings of Sites
    %e.g. Sites       = {'BERLINa','BERLINb','DRESDEN','DUBLIN','HAMBURG','LONDON','MANNHEIM','NOTTINGHAM','PARIS'};
    Sites   = {'Skyra'};
    
    SiteLimit = '';
    ManuLimit = '';
    %specify parameters that shall be printed
    PlotList     = { ...
    { 1, 1,  'Result_AP', 'PhantomDiameter' }; ...
    { 1, 2,  'Result_AP', 'PixelSpacingX' }; ...
    { 1, 3,  'Result_AP', 'PixelSpacingY' }; ...
    { 1, 4,  'Result_AP', 'PixelBandwidth' }; ...
    { 1, 5,  'Result_AP', 'FOVX' }; ...
    { 1, 6,  'Result_AP', 'FOVY' }; ...
    { 1, 7,  'Result_AP', 'Width' }; ...
    { 1, 8,  'Result_AP', 'Height' }; ...
    { 1, 9,  'Result_AP', 'BitDepth' }; ...
    { 1, 10,  'Result_AP', 'Weighting' }; ...
    { 1, 11, 'Result_AP', 'Sequence' }; ...
    { 1, 12, 'Result_AP', 'NumberOfSlices' }; ...
    { 1, 13, 'Result_AP', 'SliceThickness' }; ...
    { 1, 14, 'Result_AP', 'SpacingBetweenSlices' }; ...
    { 1, 15, 'Result_AP', 'TE' }; ...
    { 1, 16, 'Result_AP', 'TR' } };

    ResultFolders       = dir('Phantom Results/');
    ResultFolders(1:2)  = [];

    if ~exist('ResultCell','var')
        SiteCounter = zeros(numel(Sites),1);
        ResultCell.BERLINa       = {};
        ResultCell.BERLINb       = {};
        ResultCell.DRESDEN       = {};
        ResultCell.DUBLIN        = {};
        ResultCell.HAMBURG       = {};
        ResultCell.LONDON        = {};
        ResultCell.MANNHEIM      = {};
        ResultCell.NOTTINGHAM    = {};
        ResultCell.PARIS         = {};

        %First of all read all Result-Structs
        for ResultIndex = 1 : numel(ResultFolders)
            if ResultFolders(ResultIndex).isdir == 1
                Files       = dir(['Phantom Results/',ResultFolders(ResultIndex).name]);
                Files(1:2)  = [];
                FileNames   = {Files(:).name};
                cellfun(@(x) strcmpi('.mat',x(end - 3 : end)), FileNames(:), 'UniformOutput',0);
                MATIndex    = find(cell2mat(cellfun(@(x) strcmpi('.mat',x(end - 3 : end)), FileNames(:), 'UniformOutput',0)));
                if numel(MATIndex) ~= 1 
                    MATIndex = nan;
                    Error(['WARNING: Multiple .mats in ',ResultFolders(ResultIndex).name])
                else
                    Result = load(['Phantom Results/',ResultFolders(ResultIndex).name,'/',FileNames{MATIndex}]);
                    Result = Result.Result;
                    if (strcmpi(Result.Dataset.Manufacturer,ManuLimit) || strcmpi('',ManuLimit)) ...
                     && strcmpi(Result.Dataset.Site,SiteLimit) || strcmpi('',SiteLimit)
                        ResultCell.(Result.Dataset.Site) = [ResultCell.(Result.Dataset.Site); {Result}];
                        disp(['Added: ',FileNames{MATIndex}])
                    end

                    %Adjust SiteCounter
                    SiteID              = Result.Dataset.Site;
                    SiteCounterIndex    = find(cellfun(@(x) strcmpi(x,SiteID),Sites) == 1,1,'first');
                    SiteCounter(SiteCounterIndex) = SiteCounter(SiteCounterIndex) + 1;
                end
            end
        end

    end

    NumOfParams = numel(PlotList);
    ExcelCell   = cell(3 + sum(SiteCounter) + 3 * numel(SiteCounter),3 + NumOfParams);

    ExcelCell{1,1} = 'Site';
    ExcelCell{1,2} = 'Dataset';

    %Set Header
    CurrentCounter = 1;
    for ParamIndex = 1 : NumOfParams
         ExcelCell{1,3 + ParamIndex} = PlotList{ParamIndex}{3};
         ExcelCell{2,3 + ParamIndex} = PlotList{ParamIndex}{4};
    end

    %First, iterate of all SiteCells in the ResultCell-Struct
    CurrentAverageRow = 4; 
    for SiteIndex = 1 : numel(Sites)
        if SiteCounter(find(cellfun(@(x) strcmpi(x,SiteID),Sites) == 1,1,'first')) > 0
            SiteResults                     = ResultCell.(Sites{SiteIndex});
            ExcelCell{CurrentAverageRow,1}  = SiteResults{1}.Dataset.Site;

            %Set Dataset Names
            for SingleResultIndex = 1 : numel(SiteResults)
                ExcelCell{CurrentAverageRow + 2 + SingleResultIndex, 2} = SiteResults{SingleResultIndex}.Parameter.GEN.SaveFolder;
            end        

            %Now iterate over all parameters, that are about to be plottet
            ParamCounter = 1;
            for ParamIndex = 1 : NumOfParams

                Elements = nan(numel(SiteResults),1);

                    %Set correct items to be plottet
                    ValueName    = {PlotList{ParamIndex}{3}, PlotList{ParamIndex}{4}};


                    %Now, iterate over all Datasets per Site and plot the
                    %single values of the Parameters, store them, and at the
                    %end write the Average to the Average-Line
                    for SingleResultIndex = 1 : numel(SiteResults)
                        
                        SingleResult    = SiteResults{SingleResultIndex};
                        Value           = SingleResult.(ValueName{1}).(ValueName{2});
                        if ~isempty(SingleResult.(ValueName{1}))
                            if isnumeric(Value)
                                String = sprintf('%.2f',Value);
                            else
                                String = Value;
                            end
                        else
                            String = 'failed...';
                        end
                        ExcelCell{CurrentAverageRow + 2 + SingleResultIndex, 3 + ParamCounter} = String;
                    end
                    ParamCounter = ParamCounter + 1;
             end
            
        end

        %Adjust CurrentAverageRow
        CurrentAverageRow = CurrentAverageRow + 4 + numel(SiteResults);
    end

    xlswrite('AcqParams.xls', ExcelCell);

%end