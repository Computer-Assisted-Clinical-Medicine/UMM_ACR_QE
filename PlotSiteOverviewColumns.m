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
    %simple script to iterate over all results/datsets and plot the
    %corresponding quality parameters, sorted by the corresponding site

Marker          = 'X';
MarkerSize      = 2;
Color           = 'red';
PlotSTD         = 1;
PLotGlobalMean  = 1;
SavePlot        = 1;
PlotMeanLines   = 1;
ValidRangeColor = [0.92 0.92 0.92];


SiteLimit = '';
ManuLimit = '';
PlotList     = { ...
{ 1, 1,  'Result_AP',  'PhantomDiameter',           'Mean Measured Phantom Diameter',                   'Site', 'Mean Diameter $[mm]$',                     [188, 192]}; ...
{ 1, 2,  'Result_IU',  'IntegralUniformity',        'Integral Image Uniformity',                        'Site', 'Integral Uniformity $[w.E.]$',             [0.9, 1.0 ]}; ...
{ 1, 3,  'Result_SNR', 'SNR',                       'Signal-to-Noise (uncorrected)',                    'Site', 'Signal-to-Noise $[a.U.]$',                 []}; ...
{ 1, 4,  'Result_SNR', 'SNRCorr',                   'Signal-to-Noise, corrected for Parallel Imaging',  'Site', 'Signal-to-Noise $[a.U.]$',                 []}; ...
{ 1, 5,  'Result_SNR', 'GhostingRatio',             'Ghosting Ratio',                                   'Site', 'Ghosting Ratio $[w.E.]$',                  [0.0, 0.025]}; ...
{ 1, 6,  'Result_RES', 'MinResolveableDetailSizeH', 'Spatial Resolution \textit{horizontal}',           'Site', 'Smallest Resolvable Detail Size $[mm]$',   [0.0, 1.0]}; ...
{ 1, 7,  'Result_RES', 'MinResolveableDetailSizeV', 'Spatial Resolution \textit{vertical}',             'Site', 'Smallest Resolvable Detail Size $[mm]$',   [0.0, 1.0]}; ...
{ 1, 8,  'Result_SL',  'MaxError',                  'Spatial Linearity',                                'Site', 'Maximal Error Shift $[mm]$',                       [0.0, 2.0]}; ...
{ 1, 9,  'Result_SL',  'MeanError',                 'Spatial Linearity',                                'Site', 'Mean Shift $[mm]$',                       [0.0, 2.0]}; ...
{ 1, 10, 'Result_CS',  'MillimeterChemicalShiftX',  'Chemical Shift in $x$',                            'Site', 'Chemical Shift $[mm]$',                    []}; ...
{ 1, 11, 'Result_CS',  'MillimeterChemicalShiftY',  'Chemical Shift in $y$',                            'Site', 'Chemical Shift $[mm]$',                    []}; ...
{ 1, 12, 'Result_CS',  'Bandwidth',                 'Receiving Bandwidth',                              'Site', 'Receiving Bandwidth $[Hz]$',               []}; ...
{ 1, 13, 'Result_CS',  'RelAbsBandwidth',           'Ratio "Meas. Bandwidth/ Calc. Bandwidth"',         'Site', 'Relative Bandwidth $[w.E.]$',              []} };

AllAP       = 1;
AllIU       = 1;
AllSNR      = 1;
AllRES      = 1;
AllSL       = 1;
AllCS       = 1;
ONLYINDEX   = nan; %12 failed @ RES: 30, 35

%====================================

ItemBool  = cellfun(@(Line) max([   ~isempty(strfind(Line{3},'AP')) * AllAP ,...
                                    ~isempty(strfind(Line{3},'IU')) * AllIU ,...
                                    ~isempty(strfind(Line{3},'SNR')) * AllSNR ,...
                                    ~isempty(strfind(Line{3},'RES')) * AllRES ,...
                                    ~isempty(strfind(Line{3},'SL')) * AllSL ,...
                                    ~isempty(strfind(Line{3},'CS')) * AllCS ]), PlotList) .* cellfun(@(x) x{1}, PlotList);

if ~isnan(ONLYINDEX)
   ItemBool(:) = 0;
   ItemBool(ONLYINDEX) = 1;
end


ResultFolders       = dir('Phantom Results/');
ResultFolders(1:2)  = [];

if ~exist('ResultCell','var')
    
    ResultCell          = {};

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
                    ResultCell = [ResultCell; {Result}];
                    disp(['Added: ',FileNames{MATIndex}])
                end
            end
        end
    end

end

%Now plot all results
NumOfPoints   = numel(ResultCell);
FigureCounter = 1;
for ItemIndex = 1 : numel(ItemBool)
   if ItemBool(ItemIndex) == 1 
       
       MeanCell = { 'MANNHEIM',   [] ; ...
                    };
       
       %Set correct items to be plottet
       ValueName    = {PlotList{ItemIndex}{3}, PlotList{ItemIndex}{4}};
       switch ItemIndex
           case 95
               STDName = {PlotList{ItemIndex}{3}, 'STDError'};
           otherwise
               STDName = [];
       end
               
       %Open New figure
       figure(FigureCounter)
       hold on
       FigureCounter = FigureCounter + 1;

       for SiteIndex = 1 : numel(ResultCell)
           if ~isempty(ResultCell{SiteIndex}.(ValueName{1}))
               if ~isempty(STDName)
                    title([ValueName{1},' : ',ValueName{2},' ± ',STDName{2}],'Interpreter','None','Fontweight','bold');
                    ylabel([ValueName{2},' ± ',STDName{2}],'Interpreter','None')
               else
                    title([ValueName{1},' : ',ValueName{2}],'Interpreter','None','Fontweight','bold');
                    ylabel([ValueName{2}],'Interpreter','None')
               end

               %Plot all values
               Value = ResultCell{SiteIndex}.(ValueName{1}).(ValueName{2});
               if ~isempty(STDName) && PlotSTD == 1
                    STD = ResultCell{SiteIndex}.(STDName{1}).(STDName{2});
               else
                    STD = nan;
               end
               
               %Store Value for Mean-Calculation
               SiteMeanIndex = find(strcmp(MeanCell(:,1),ResultCell{SiteIndex}.Dataset.Site));
               if isempty(SiteMeanIndex)
                  error(['WARNING: New Site Identifier found: ',ResultCell{SiteIndex}.Dataset.Site]) 
               end
               MeanCell{SiteMeanIndex,2}    = [ MeanCell{SiteMeanIndex,2}; SiteIndex, Value, STD ];
               
           else
               MeanCell{SiteMeanIndex,2}    = [ MeanCell{SiteMeanIndex,2}; SiteIndex, nan, nan ];
               Error('WARNING: Item failed during caluclation!')
               Error(['>>> ',GetSaveFileName(ResultCell{SiteIndex}.Dataset)])
           end
           
       end

       [NumOfSites, ~]  = size(MeanCell);
       MeanVector       = nan(NumOfSites, 1);
       STDVector        = nan(NumOfSites, 1);
       
       %Plot Valid Range as gray Rectangle behind the actual plot (only if the entry is set int the struct)
       ValidRange = PlotList{ItemIndex}{8};
       if ~isempty(ValidRange)
           if numel(ValidRange) == 2
                %Plot the Range
                ht = rectangle('Position',[0.5, ValidRange(1), NumOfSites, ValidRange(2) - ValidRange(1)], 'Facecolor', ValidRangeColor);  
                H5 = plot(nan,nan,'s','markeredgecolor',get(ht,'edgecolor'),...
                'markerfacecolor',get(ht,'facecolor'));
           else
                %Plot the line
                %line([0.5, NumOfSites + 0.5], [ValidRange ValidRange], 'Color', [0.3 0.3 0.3],'Linewidth',3); 
                %H5 = plot(nan,nan,'s','markeredgecolor',get(ht,'edgecolor'),...
                %'markerfacecolor',get(ht,'facecolor'));
           end
       end
       
       TickNames = {};
       for Index = 1 : NumOfSites
           A                        = MeanCell{Index,2};
           [NumOfDatasets,~]        = size(A);
           A(isnan(A(:,2)),:)       = [];
           [NumOfValidDatasets,~]   = size(A);
           SingleValues             = A(:,2);
           Mean              = mean(SingleValues);
           STD               = std(SingleValues);
           MeanVector(Index) = Mean;
           STDVector(Index)  = STD;

           %plot std
           STDColor     = [0.5 0.5 0.5];
           STDWidth     = 1.5;
           line([Index - 0.2, Index + 0.2],[Mean + STD, Mean + STD],'Color',STDColor,'Linewidth',STDWidth);
           line([Index - 0.2, Index + 0.2],[Mean - STD, Mean - STD],'Color',STDColor,'Linewidth',STDWidth);
           Handle2  = line([Index, Index],[Mean - STD, Mean + STD],'Color',STDColor,'Linewidth',STDWidth);
           
           %plot single values
           for ValueIndex = 1 : numel(SingleValues)
                HandleSingle = plot(Index, SingleValues(ValueIndex),'X','Linewidth',1.5,'Markersize',10);
           end
           
           %plot mean
           Handle1  = plot(Index,Mean,'O','Linewidth',3,'Color','red');
           
           
           if NumOfDatasets == NumOfValidDatasets
               TickNames         = [TickNames, {[MeanCell{Index,1}(1:2),' (',num2str(NumOfDatasets),')']}];
           else
               TickNames         = [TickNames, {[MeanCell{Index,1}(1:2),' (',num2str(NumOfDatasets),')']}];
               %TickNames         = [TickNames, {[MeanCell{Index,1}(1:2),' (',num2str(NumOfValidDatasets),', ',num2str(NumOfDatasets - NumOfValidDatasets),' invalid)']}];
           end
       end
       
       if numel(ValidRange) > 1
            %set legend including handle for valid range
            lhandle = legend([HandleSingle Handle1 Handle2 H5],'Single Datasets','Site Mean', 'Site Standard Deviation', 'Valid Range'); 
       else
            %set legend without handle for valid range
            lhandle = legend([HandleSingle Handle1 Handle2],'Single Datasets','Site Mean', 'Site Standard Deviation');
       end
       
       GlobalMean = mean(MeanVector);
       %get a vector containing the number of measurements for each
       %site
       nVector    = cell2mat(cellfun(@(x) size(x,1), MeanCell(:,2),'UniformOutput',0));
       GlobalSTD  = GetPooledSTD( nVector, STDVector );
       
       title([PlotList{ItemIndex}{5},' (Global: $',sprintf('%.3f',GlobalMean),'\pm',sprintf('%.3f',GlobalSTD),'$)'],'Interpreter','latex')
       ylabel(PlotList{ItemIndex}{7},'Interpreter','latex')
       
       xlim([0.5, numel(TickNames) + 0.5])
       set(gca,'Xtick',1 : numel(TickNames),'XTickLabel',TickNames)
       rotateticklabel(gca);
       set(gca,'Fontweight','bold')

       %Set sizes
       set(gcf,'Position',      [ 77           5        1272         910]   )
       set(gcf,'OuterPosition', [ 69          -3        1288        1002]  )
       set(gca,'Position',      [0.0586    0.1602    0.9054    0.6691])
       set(gca,'OuterPosition', [ -0.0933    0.0699    1.1683    0.8210])
       
       grid on
       
       %adjust legend position
       % % reduce the lenght of the X-axis (by 10%)
       % pos = get(gca,'Position');
       % pos(4)=.9*pos(4);
       % set(gca,'Position',pos);

        % move the location of the legend by 115%
        %pos = get(lhandle,'Position');
        %pos(2) = 1.14*pos(2);
        set(lhandle,'Position',[0.7884    0.8426    0.1643    0.0872]);
       
       %save plot
       if SavePlot == 1
            
           	set(gcf,'PaperOrientation','landscape');
            set(gcf,'PaperPosition', [1 1 28 19]);
            print(gcf,'-dpdf',['Site Overviews\',[(ValueName{1}),'.',(ValueName{2})],'.pdf'])
            print(gcf,'-dpng',['Site Overviews\',[(ValueName{1}),'.',(ValueName{2})],'.png'])
       
       end
       
   end
   
end



