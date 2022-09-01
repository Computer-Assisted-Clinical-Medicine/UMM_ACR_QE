function varargout = OpenPhantomGUI(varargin)

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
    %this is a GUI used for creating datasets that can be evaluated by the
    %automated methods. Read in a number of slices or a dataset from the
    %list at the bottom of the GUI. Run through the slices and set the
    %slices for the quality parameters, and store the dataset once
    %finished.
    %
    %NOTE: the automatic extraction of a save name based on the
    %IMAGEN-specification may not work with other dicom file names. Saving
    %the files should work anyway, but the name should be changed manually
    %after storing the file. The dataset will automatically be stored in "Phantom Datasets"

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OpenPhantomGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @OpenPhantomGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before OpenPhantomGUI is made visible.
function OpenPhantomGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OpenPhantomGUI (see VARARGIN)

% Choose default command line output for OpenPhantomGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OpenPhantomGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%clc

%Create some variables
global CurrentImageIndex
CurrentImageIndex   = 1;

LoadAndSetList(handles)



% --- Outputs from this function are returned to the command line.
function varargout = OpenPhantomGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function ImageSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

SetCurrentImage(handles, round(get(handles.ImageSlider, 'Value')))



% --- Executes during object creation, after setting all properties.
function ImageSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in SetForLocalization.
function SetForLocalization_Callback(hObject, eventdata, handles)
% hObject    handle to SetForLocalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex
global Dataset
Dataset.Index_LOC   = CurrentImageIndex;
set(handles.StatLOC, 'String', num2str(CurrentImageIndex))
set(handles.StatLOC, 'ForegroundColor', [1 0 0])



% --- Executes on button press in SetForResolution.
function SetForResolution_Callback(hObject, eventdata, handles)
% hObject    handle to SetForResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex
global Dataset
Dataset.Index_RES   = CurrentImageIndex;
set(handles.StatRES, 'String', num2str(CurrentImageIndex))
set(handles.StatRES, 'ForegroundColor', [1 0 0])


% --- Executes on button press in SetForSpatialLinearity.
function SetForSpatialLinearity_Callback(hObject, eventdata, handles)
% hObject    handle to SetForSpatialLinearity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex
global Dataset
Dataset.Index_SL   = CurrentImageIndex;
set(handles.StatSL, 'String', num2str(CurrentImageIndex))
set(handles.StatSL, 'ForegroundColor', [1 0 0])


% --- Executes on button press in SetForUniformityAndSNR.
function SetForUniformityAndSNR_Callback(hObject, eventdata, handles)
% hObject    handle to SetForUniformityAndSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex
global Dataset
Dataset.Index_IU   = CurrentImageIndex;
Dataset.Index_SNR  = CurrentImageIndex;
set(handles.StatIUSNR, 'String', num2str(CurrentImageIndex))
set(handles.StatIUSNR, 'ForegroundColor', [1 0 0])


% --- Executes on button press in SetForContrast1.
function SetForContrast1_Callback(hObject, eventdata, handles)
% hObject    handle to SetForContrast1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex
global Dataset
Dataset.Index_CON1   = CurrentImageIndex;
set(handles.StatCON1, 'String', num2str(CurrentImageIndex))
set(handles.StatCON1, 'ForegroundColor', [1 0 0])


% --- Executes on button press in SetForContrast2.
function SetForContrast2_Callback(hObject, eventdata, handles)
% hObject    handle to SetForContrast2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex
global Dataset
Dataset.Index_CON2   = CurrentImageIndex;
set(handles.StatCON2, 'String', num2str(CurrentImageIndex))
set(handles.StatCON2, 'ForegroundColor', [1 0 0])


% --- Executes on button press in SetForContrast3.
function SetForContrast3_Callback(hObject, eventdata, handles)
% hObject    handle to SetForContrast3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex
global Dataset
Dataset.Index_CON3   = CurrentImageIndex;
set(handles.StatCON3, 'String', num2str(CurrentImageIndex))
set(handles.StatCON3, 'ForegroundColor', [1 0 0])


% --- Executes on button press in LastImage.
function LastImage_Callback(hObject, eventdata, handles)
% hObject    handle to LastImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CurrentImageIndex

if CurrentImageIndex >= 2
    CurrentImageIndex = CurrentImageIndex - 1;
    SetCurrentImage(handles, CurrentImageIndex)
end


% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global NumOfImages
global CurrentImageIndex

if CurrentImageIndex < NumOfImages
    CurrentImageIndex = CurrentImageIndex + 1;
    SetCurrentImage(handles, CurrentImageIndex)
end


% --- Executes on button press in OpenPhantom.
function OpenPhantom_Callback(hObject, eventdata, handles)
% hObject    handle to OpenPhantom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open Dialog
[FileName, PathName]     = uigetfile('*.IMA;*.DCM','Select DICOM-Files of the Phantom','G:\IMAGen\IMAGen_Phantom','Multiselect','on');
if ~isscalar(FileName) && ~isscalar(PathName)
    LoadImages(FileName, PathName, handles)
end


% --- Executes on button press in SavePhantom.
function SavePhantom_Callback(hObject, eventdata, handles)
% hObject    handle to SavePhantom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
FileName    = [Dataset.Site,' - ',Dataset.SiteCode,' (',Dataset.Manufacturer,') - ',Dataset.Acquisition, ' - ',Dataset.Session,' - ',Dataset.Type,'.mat'];
if  isempty(Dataset.Site) || ...
    isempty(Dataset.SiteCode) || ...
    isempty(Dataset.Manufacturer) || ...
    isempty(Dataset.Acquisition) || ...
    isempty(Dataset.Session) || ...
    isempty(Dataset.Type)
    
    DateString  = datestr(clock);
    DateString  = strrep(DateString,':','-');
    FileName    = ['Unknown dataset (',DateString,')'];

    warning(['Could not generate automatic file name; dataset will be saved as ',FileName])
end
    
%Remove 
FileName    = strrep(FileName, '/', '');
FileName    = strrep(FileName, '\', '');
FileName    = strrep(FileName, ':', '');
FileName    = strrep(FileName, '*', '');
FileName    = strrep(FileName, '?', '');
FileName    = strrep(FileName, '"', '');
FileName    = strrep(FileName, '<', '');
FileName    = strrep(FileName, '>', '');
FileName    = strrep(FileName, '|', '');

set(handles.SavePhantom, 'String', 'Saving...')
set(handles.SavePhantom, 'FontWeight', 'bold')
set(handles.SavePhantom, 'ForegroundColor', [1 0 0])
pause(0.1)

%Save File
save(['Phantom Datasets/',FileName], 'Dataset')

set(handles.SavePhantom, 'String', 'Save')
set(handles.SavePhantom, 'FontWeight', 'normal')
set(handles.SavePhantom, 'ForegroundColor', [0 0 0])









function InstitutionText_Callback(hObject, eventdata, handles)
% hObject    handle to InstitutionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InstitutionText as text
%        str2double(get(hObject,'String')) returns contents of InstitutionText as a double


% --- Executes during object creation, after setting all properties.
function InstitutionText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InstitutionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ManufacturerText_Callback(hObject, eventdata, handles)
% hObject    handle to ManufacturerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ManufacturerText as text
%        str2double(get(hObject,'String')) returns contents of ManufacturerText as a double


% --- Executes during object creation, after setting all properties.
function ManufacturerText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ManufacturerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AcquisitionText_Callback(hObject, eventdata, handles)
% hObject    handle to AcquisitionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AcquisitionText as text
%        str2double(get(hObject,'String')) returns contents of AcquisitionText as a double


% --- Executes during object creation, after setting all properties.
function AcquisitionText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AcquisitionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WidthText_Callback(hObject, eventdata, handles)
% hObject    handle to WidthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WidthText as text
%        str2double(get(hObject,'String')) returns contents of WidthText as a double


% --- Executes during object creation, after setting all properties.
function WidthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BitDepthText_Callback(hObject, eventdata, handles)
% hObject    handle to BitDepthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BitDepthText as text
%        str2double(get(hObject,'String')) returns contents of BitDepthText as a double


% --- Executes during object creation, after setting all properties.
function BitDepthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BitDepthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeightText_Callback(hObject, eventdata, handles)
% hObject    handle to HeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeightText as text
%        str2double(get(hObject,'String')) returns contents of HeightText as a double


% --- Executes during object creation, after setting all properties.
function HeightText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ResetAll(handles)

%Reset Slider
global CurrentImageIndex
CurrentImageIndex = 1;
set(handles.ImageSlider, 'value', 1)

%Set Stats
set(handles.StatLOC,'String','-')
set(handles.StatRES,'String','-')
set(handles.StatSL,'String','-')
set(handles.StatIUSNR,'String','-')
set(handles.StatCON1,'String','-')
set(handles.StatCON2,'String','-')
set(handles.StatCON3,'String','-')

set(handles.StatLOC,'ForegroundColor',[0 0 0])
set(handles.StatRES,'ForegroundColor',[0 0 0])
set(handles.StatSL,'ForegroundColor',[0 0 0])
set(handles.StatIUSNR,'ForegroundColor',[0 0 0])
set(handles.StatCON1,'ForegroundColor',[0 0 0])
set(handles.StatCON2,'ForegroundColor',[0 0 0])
set(handles.StatCON3,'ForegroundColor',[0 0 0])

set(handles.SetImageQualityLOC,'BackgroundColor',[0 1 0])
set(handles.SetImageQualityRES,'BackgroundColor',[0 1 0])
set(handles.SetImageQualitySL,'BackgroundColor',[0 1 0])
set(handles.SetImageQualityIUSNR,'BackgroundColor',[0 1 0])
set(handles.SetImageQualityCON1,'BackgroundColor',[0 1 0])
set(handles.SetImageQualityCON2,'BackgroundColor',[0 1 0])
set(handles.SetImageQualityCON3,'BackgroundColor',[0 1 0])

set(handles.SetImageQualityLOC,'String','+')
set(handles.SetImageQualityRES,'String','+')
set(handles.SetImageQualitySL,'String','+')
set(handles.SetImageQualityIUSNR,'String','+')
set(handles.SetImageQualityCON1,'String','+')
set(handles.SetImageQualityCON2,'String','+')
set(handles.SetImageQualityCON3,'String','+')

set(handles.SiteText,'String','')
set(handles.SiteCodeText,'String','')
set(handles.InstitutionText,'String','')
set(handles.ManufacturerText,'String','')
set(handles.AcquisitionText,'String','')
set(handles.WidthText,'String','')
set(handles.HeightText,'String','')
set(handles.BitDepthText,'String','')
%set(handles.PatientIDText,'String','')

set(handles.ArtifactDescription,'String','')
set(handles.DatasetName,'String','')
set(handles.DatasetNameWarning,'Visible','off')

set(handles.Table,'Data',{})

function SetCurrentImage(handles, ImageIndex)

global Dataset
global CurrentImageIndex
global NumOfImages
%global TableCell

CurrentImageIndex = ImageIndex;
imshow(Dataset.Image{ImageIndex},'Parent',handles.Axes,'DisplayRange',[min(min(Dataset.Image{ImageIndex})) max(max(Dataset.Image{ImageIndex}))])

[~, Data]       = cprintf(Dataset.Info{ImageIndex});

set(handles.Table, 'Data', Data)
if NumOfImages > 1
    set(handles.ImageSlider, 'Value', ImageIndex)
end
set(handles.ImageIndexText, 'String', num2str(ImageIndex))




function UnlockAll(handles)

set(handles.SavePhantom, 'Enable', 'on')
set(handles.LastImage, 'Enable', 'on')
set(handles.NextImage, 'Enable', 'on')
set(handles.SetForLocalization, 'Enable', 'on')
set(handles.SetForResolution, 'Enable', 'on')
set(handles.SetForSpatialLinearity, 'Enable', 'on')
set(handles.SetForUniformityAndSNR, 'Enable', 'on')
set(handles.SetForLocalization, 'Enable', 'on')
set(handles.SetForContrast1, 'Enable', 'on')
set(handles.SetForContrast2, 'Enable', 'on')
set(handles.SetForContrast3, 'Enable', 'on')

function CreateNewDataset(NumOfImages)

global Dataset
Dataset = [];

%Create Dataset
Dataset.Image      = cell(NumOfImages, 1);
Dataset.Info       = cell(NumOfImages, 1);
Dataset.Path       = cell(NumOfImages, 1);

%Indices
Dataset.Index_LOC   = [];
Dataset.Index_RES   = [];
Dataset.Index_SL    = [];
Dataset.Index_IU    = [];
Dataset.Index_SNR   = [];
Dataset.Index_CON1  = [];
Dataset.Index_CON2  = [];
Dataset.Index_CON3  = [];

%Parameter
Dataset.Site            = [];
Dataset.SiteCode        = [];
Dataset.Institution     = [];
Dataset.Manufacturer    = [];
Dataset.Acquisition     = [];
Dataset.Type            = [];
Dataset.Session         = [];
Dataset.Width           = [];
Dataset.Height          = [];
Dataset.BitDepth        = [];
%Dataset.PatientID      = [];
Dataset.Artifact        = [];


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SetCurrentImage(handles, 1)

% --- Executes on button press in CheckFolder.
function CheckFolder_Callback(hObject, eventdata, handles)
% hObject    handle to CheckFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SubPlotIndices
global FileNamesFolder
global PathFolder
global GroupID
global FileList
global IMANames

global CorrespondingFileNames
global SubName

%Get Folder
PathFolder  = uigetdir('G:\IMAGen\IMAGen_Phantom');
if ~isscalar(PathFolder)
    
    FileList        = dir(PathFolder);
    FileList(1:2)   = [];
    %Create Cell of FileNames
    FileNamesFolder = {FileList(:).name};
    %Get List of ReportFiles
    IMANames        = FileNamesFolder(cellfun(@(x) strcmpi(x(end - 2 : end),'IMA'),FileNamesFolder));
    
    Counter         = 1;
    NumOfFiles      = numel(IMANames);
    GroupID         = {};
    while Counter <= NumOfFiles
        CurrentName             = IMANames{Counter};
        PointIndices            = strfind(CurrentName,'.');
        SubName                 = CurrentName(1 : PointIndices(4) - 1);
        CorrespondingFileNames  = FileNamesFolder(cellfun(@(x) strcmpi(x(1 : numel(SubName)), SubName), FileNamesFolder));
        GroupID                 = [GroupID; {SubName, CorrespondingFileNames{round(numel(CorrespondingFileNames)/2)}, numel(CorrespondingFileNames) }];
        Counter                 = Counter + numel(CorrespondingFileNames);
    end
    
    [NumOfGroups,~] = size(GroupID);

    %Example
    %REPORT_062000000006.SR.IMAGEN_IMAGEN_20080725.99.6.2010.04.06.14.10.00.634814.48795065
    %for
    %       062000000006.MR.IMAGEN_IMAGEN_20080725.6.1.2010.04.06.14.10.00.634814.18595771
    figure('WindowButtonDownFcn', {@SelectionFigureCallback, handles} )
    
    title('Please click on the Plot corresponding to Phantom...')
    SubPlotIndices = nan(NumOfGroups, 1);
    
    for Index = 1 : NumOfGroups
        %Get the corresponding index that needs to be shown
        SubPlotIndices(Index)   = subplot(ceil(sqrt(NumOfGroups)), ceil(sqrt(NumOfGroups)), Index);
        Image                   = double(dicomread([PathFolder, '\', GroupID{Index,2}]));
        imshow(Image,'DisplayRange',[min(min(Image)) max(max(Image))])
        set(gca,'XTick',[],'YTick',[])
        title([num2str(GroupID{Index,3}),' Images'])
    end
end 

% --- Executes on button press in CheckFolder.
function CheckFolder2_Callback(hObject, eventdata, handles)
% hObject    handle to CheckFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SubPlotIndices
global FileNamesFolder
global PathFolder
global IDcell
global FileList

%Get Folder
PathFolder  = uigetdir();
if ~isscalar(PathFolder)
    
    FileList        = dir(PathFolder);
    FileList(1:2)   = [];
    %Create Cell of FileNames
    FileNamesFolder       = {FileList(:).name};
    %Get List of ReportFiles
    ReportIndices   = find(cellfun(@(IDX) ~isempty(IDX), strfind(FileNamesFolder, 'SR')));
    ReportNames     = {FileNamesFolder(ReportIndices)};
    %disp(' *** Report Names ***')
    %disp(ReportNames)
    NumOfReports    = numel(ReportNames{1});
    %disp(' *** NumOfReports ***')
    %NumOfReports
    
    %Example
    %REPORT_062000000006.SR.IMAGEN_IMAGEN_20080725.99.6.2010.04.06.14.10.00.634814.48795065
    %for
    %       062000000006.MR.IMAGEN_IMAGEN_20080725.6.1.2010.04.06.14.10.00.634814.18595771
    figure('WindowButtonDownFcn', {@SelectionFigureCallback, handles} )
    
    title('Please click on the Plot corresponding to Phantom...')
    SubPlotIndices = nan(NumOfReports, 1);
    IDcell         = cell(NumOfReports, 1);
    
    SubplotCounter = 1;
    for Index = 1 : NumOfReports
        %Get the corresponding index that needs to be shown
        IDcell{Index}   = [ReportNames{1}{Index}(8:20),'MR',ReportNames{1}{Index}(23:45),ReportNames{1}{Index}(49:51)];
        IDImages        = find(cellfun(@(IDX) ~isempty(IDX), strfind(FileNamesFolder, IDcell{Index})));
        if ~isempty(IDImages)
            IDCenterIndex   = floor(mean(IDImages));
            SubPlotIndices(Index) = subplot(ceil(sqrt(NumOfReports)), ceil(sqrt(NumOfReports)), SubplotCounter);
            Image           = double(dicomread([PathFolder, '\', FileNamesFolder{IDCenterIndex}]));
            imshow(Image,'DisplayRange',[min(min(Image)) max(max(Image))])
            set(gca,'XTick',[],'YTick',[])
            SubplotCounter  = SubplotCounter + 1;
        else
            fprintf(2,'WARNING: Report-Files and DICOM-Files are inconsistent!');
            fprintf(2,'         Manual import might be necessary!');
            
        end
    end
end 

%%%%% OLD STUFF


function LoadImages(FileName, PathName, handles)

    global Dataset
    global NumOfImages

    if ~iscell(FileName)
        FileName = {FileName};
        set(handles.ImageSlider, 'Enable', 'off')
    end
    %Resets all Parameter
    ResetAll(handles);
    
    FileName = SortFileList( FileName );
    
    NumOfImages     = numel(FileName);
    CreateNewDataset(NumOfImages)
    for Index = 1 : NumOfImages
        disp([PathName,FileName{Index}])
        Dataset.Path{Index}    = [PathName,FileName{Index}];
        Dataset.Image{Index}   = double(dicomread([PathName,FileName{Index}]));
        Dataset.Info{Index}    = dicominfo([PathName,FileName{Index}]);
    end
    SetCurrentImage(handles, 1)
    if NumOfImages > 1
        set(handles.ImageSlider, 'Min', 1)
        set(handles.ImageSlider, 'Max', NumOfImages)
        set(handles.ImageSlider, 'Enable', 'on')
    end
    set(handles.NumOfImagesString, 'String', ['/ ',num2str(NumOfImages)])
    
    try
    %Set some Preferences
    %Set Site
    SiteIndex = strfind(PathName,'QC\') + 3;
    SubString = PathName(SiteIndex : end);
    BackSlash = strfind(SubString,'\');
    Dataset.Site = SubString(1 : BackSlash(1) - 1);

    %Set SiteCode
    SubString = SubString(BackSlash(1) + 1 : end);
    Space     = strfind(SubString,'_');
    Dataset.SiteCode = SubString(1 : Space(1) - 1);
    
    %Set Date
    SubString = SubString(Space(1) + 1 : end);
    BackSlash = strfind(SubString,'\');
    Dataset.Acquisition = SubString(1 : BackSlash(1) - 1);
    
    %Set Type
    BackSlash = strfind(PathName,'\');
    Dataset.Type = PathName(BackSlash(end - 1) + 1 : BackSlash(end) - 1);
    
    %Set Session
    Dataset.Session = PathName(BackSlash(end - 2) + 1 : BackSlash(end - 1) - 1);
    
    if isfield(Dataset.Info{1},'Institution')
        Dataset.Institution     =   Dataset.Info{1}.InstitutionAddress;
    else
        Dataset.Institution     =   'n.a.';
    end
        
    if isfield(Dataset.Info{1},'InstitutionAddress')
        Dataset.Institution     =   Dataset.Info{1}.InstitutionAddress;
    else
        Dataset.Institution     =   'n.a.';
    end
    
    if isfield(Dataset.Info{1},'Manufacturer')
        Dataset.Manufacturer     =   Dataset.Info{1}.Manufacturer;
    else
        Dataset.Manufacturer     =   'n.a.';
    end
    
    if isfield(Dataset.Info{1},'Width')
        Dataset.Width     =   Dataset.Info{1}.Width;
    else
        Dataset.Width     =   'n.a.';
    end
    
    if isfield(Dataset.Info{1},'Height')
        Dataset.Height     =   Dataset.Info{1}.Height;
    else
        Dataset.Height     =   'n.a.';
    end
    
    if isfield(Dataset.Info{1},'BitDepth')
        Dataset.BitDepth     =   Dataset.Info{1}.BitDepth;
    else
        Dataset.BitDepth     =   'n.a.';
    end
    
    set( handles.SiteText,          'String', Dataset.Site )
    set( handles.SiteCodeText,      'String', Dataset.SiteCode )       
    set( handles.InstitutionText,   'String', Dataset.Institution )
    set( handles.ManufacturerText,  'String', Dataset.Manufacturer )
    set( handles.AcquisitionText,   'String',Dataset.Acquisition )
    set( handles.WidthText,         'String', num2str( Dataset.Width ))
    set( handles.HeightText,        'String', num2str( Dataset.Height ))
    set( handles.BitDepthText,      'String', Dataset.BitDepth )
    catch exception
       disp('WARNGING: wrong Dataset Format!') 
    end
    
    UnlockAll(handles)
    
    CheckRedundance(handles)

function SelectionFigureCallback(src,eventdata, handles)

global SubPlotIndices
global FileNamesFolder
global PathFolder
global GroupID

%Retrieve correct images, Find Index of Figure, that has just been clicked
FileNameIndices     = cellfun(@(IDX) ~isempty(IDX), strfind(FileNamesFolder, GroupID{SubPlotIndices == gca,1}));

%Close figure
close(1)

FileNames           = FileNamesFolder(FileNameIndices);
CreateNewDataset(numel(FileNameIndices))

LoadImages(FileNames, [PathFolder,'\'], handles)


% --- Executes on button press in VisibleArtifacts.
function VisibleArtifacts_Callback(hObject, eventdata, handles)
% hObject    handle to VisibleArtifacts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VisibleArtifacts

global Dataset
Status = get(hObject,'Value');
if Status == 1
    Dataset.Artifact = get(handles.ArtifactDescription,'String');
else
    Dataset.Artifact = [];
end


function ArtifactDescription_Callback(hObject, eventdata, handles)
% hObject    handle to ArtifactDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ArtifactDescription as text
%        str2double(get(hObject,'String')) returns contents of ArtifactDescription as a double

global Dataset
String = get(handles.ArtifactDescription,'String');
if strcmp(String,'')
    Dataset.Artifact = [];
    set(handles.VisibleArtifacts,'Value',0);
else
    Dataset.Artifact = String;
    set(handles.VisibleArtifacts,'Value',1);
end



% --- Executes during object creation, after setting all properties.
function ArtifactDescription_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ArtifactDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SetImageQualityLOC.

% hObject    handle to SetImageQualityLOC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SetImageQualityRES.
function SetImageQualityRES_Callback(hObject, eventdata, handles)
% hObject    handle to SetImageQualityRES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
if ~isempty(Dataset.Index_RES)
    Status = get(handles.SetImageQualityRES, 'String');
    switch Status
        case '+'
            %disp('plus')
            %Quality is currently positive
            Dataset.Index_RES = -abs(Dataset.Index_RES);
            set(handles.SetImageQualityRES, 'BackgroundColor', [1 0 0]);
            set(handles.SetImageQualityRES, 'String', '-');
        case '-'
            %disp('minus')
            %Quality is currently positive
            Dataset.Index_RES = +abs(Dataset.Index_RES);
            set(handles.SetImageQualityRES, 'BackgroundColor', [0 1 0]);
            set(handles.SetImageQualityRES, 'String', '+');
    end
end

% --- Executes on button press in SetImageQualitySL.
function SetImageQualitySL_Callback(hObject, eventdata, handles)
% hObject    handle to SetImageQualitySL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
if ~isempty(Dataset.Index_SL)
    Status = get(handles.SetImageQualitySL, 'String');
    switch Status
        case '+'
            %disp('plus')
            %Quality is currently positive
            Dataset.Index_SL = -abs(Dataset.Index_SL);
            set(handles.SetImageQualitySL, 'BackgroundColor', [1 0 0]);
            set(handles.SetImageQualitySL, 'String', '-');
        case '-'
            %disp('minus')
            %Quality is currently positive
            Dataset.Index_SL = +abs(Dataset.Index_SL);
            set(handles.SetImageQualitySL, 'BackgroundColor', [0 1 0]);
            set(handles.SetImageQualitySL, 'String', '+');
    end
end


% --- Executes on button press in SetImageQualityIUSNR.
function SetImageQualityIUSNR_Callback(hObject, eventdata, handles)
% hObject    handle to SetImageQualityIUSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
if ~isempty(Dataset.Index_SNR) && ~isempty(Dataset.Index_IU)
    Status = get(handles.SetImageQualityIUSNR, 'String');
    switch Status
        case '+'
            %disp('plus')
            %Quality is currently positive
            Dataset.Index_IU  = -abs(Dataset.Index_IU);
            Dataset.Index_SNR = -abs(Dataset.Index_SNR);
            set(handles.SetImageQualityIUSNR, 'BackgroundColor', [1 0 0]);
            set(handles.SetImageQualityIUSNR, 'String', '-');
        case '-'
            %disp('minus')
            %Quality is currently positive
            Dataset.Index_IU  = +abs(Dataset.Index_IU);
            Dataset.Index_SNR = +abs(Dataset.Index_SNR);
            set(handles.SetImageQualityIUSNR, 'BackgroundColor', [0 1 0]);
            set(handles.SetImageQualityIUSNR, 'String', '+');
    end
end

% --- Executes on button press in SetImageQualityCON1.
function SetImageQualityCON1_Callback(hObject, eventdata, handles)
% hObject    handle to SetImageQualityCON1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
if ~isempty(Dataset.Index_CON1)
    Status = get(handles.SetImageQualityCON1, 'String');
    switch Status
        case '+'
            %disp('plus')
            %Quality is currently positive
            Dataset.Index_CON1 = -abs(Dataset.Index_CON1);
            set(handles.SetImageQualityCON1, 'BackgroundColor', [1 0 0]);
            set(handles.SetImageQualityCON1, 'String', '-');
        case '-'
            %disp('minus')
            %Quality is currently positive
            Dataset.Index_CON1 = +abs(Dataset.Index_CON1);
            set(handles.SetImageQualityCON1, 'BackgroundColor', [0 1 0]);
            set(handles.SetImageQualityCON1, 'String', '+');
    end
end


% --- Executes on button press in SetImageQualityCON2.
function SetImageQualityCON2_Callback(hObject, eventdata, handles)
% hObject    handle to SetImageQualityCON2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
if ~isempty(Dataset.Index_CON2)
    Status = get(handles.SetImageQualityCON2, 'String');
    switch Status
        case '+'
            %disp('plus')
            %Quality is currently positive
            Dataset.Index_CON2 = -abs(Dataset.Index_CON2);
            set(handles.SetImageQualityCON2, 'BackgroundColor', [1 0 0]);
            set(handles.SetImageQualityCON2, 'String', '-');
        case '-'
            %disp('minus')
            %Quality is currently positive
            Dataset.Index_CON2 = +abs(Dataset.Index_CON2);
            set(handles.SetImageQualityCON2, 'BackgroundColor', [0 1 0]);
            set(handles.SetImageQualityCON2, 'String', '+');
    end
end


% --- Executes on button press in SetImageQualityCON3.
function SetImageQualityCON3_Callback(hObject, eventdata, handles)
% hObject    handle to SetImageQualityCON3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
if ~isempty(Dataset.Index_CON3)
    Status = get(handles.SetImageQualityCON3, 'String');
    switch Status
        case '+'
            %disp('plus')
            %Quality is currently positive
            Dataset.Index_CON3 = -abs(Dataset.Index_CON3);
            set(handles.SetImageQualityCON3, 'BackgroundColor', [1 0 0]);
            set(handles.SetImageQualityCON3, 'String', '-');
        case '-'
            %disp('minus')
            %Quality is currently positive
            Dataset.Index_CON3 = +abs(Dataset.Index_CON3);
            set(handles.SetImageQualityCON3, 'BackgroundColor', [0 1 0]);
            set(handles.SetImageQualityCON3, 'String', '+');
    end
end


% --- Executes on button press in SetImageQualityLOC.
function SetImageQualityLOC_Callback(hObject, eventdata, handles)
% hObject    handle to SetImageQualityLOC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
if ~isempty(Dataset.Index_LOC)
    Status = get(handles.SetImageQualityLOC, 'String');
    switch Status
        case '+'
            %disp('plus')
            %Quality is currently positive
            Dataset.Index_LOC = -abs(Dataset.Index_LOC);
            set(handles.SetImageQualityLOC, 'BackgroundColor', [1 0 0]);
            set(handles.SetImageQualityLOC, 'String', '-');
        case '-'
            %disp('minus')
            %Quality is currently positive
            Dataset.Index_LOC = +abs(Dataset.Index_LOC);
            set(handles.SetImageQualityLOC, 'BackgroundColor', [0 1 0]);
            set(handles.SetImageQualityLOC, 'String', '+');
    end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StatLOC.
function StatLOC_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StatLOC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
Dataset.Index_LOC = [];
set(handles.StatLOC, 'String', '-')
set(handles.StatLOC, 'ForegroundColor', [0 0 0])
set(handles.SetImageQualityLOC, 'String', '+')
set(handles.SetImageQualityLOC, 'BackgroundColor', [0 1 0])


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StatRES.
function StatRES_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StatRES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
Dataset.Index_RES = [];
set(handles.StatRES, 'String', '-')
set(handles.StatRES, 'ForegroundColor', [0 0 0])
set(handles.SetImageQualityRES, 'String', '+')
set(handles.SetImageQualityRES, 'BackgroundColor', [0 1 0])


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StatSL.
function StatSL_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StatSL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
Dataset.Index_SL = [];
set(handles.StatSL, 'String', '-')
set(handles.StatSL, 'ForegroundColor', [0 0 0])
set(handles.SetImageQualitySL, 'String', '+')
set(handles.SetImageQualitySL, 'BackgroundColor', [0 1 0])

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StatIUSNR.
function StatIUSNR_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StatIUSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
Dataset.Index_IU  = [];
Dataset.Index_SNR = [];
set(handles.StatIUSNR, 'String', '-')
set(handles.StatIUSNR, 'ForegroundColor', [0 0 0])
set(handles.SetImageQualityIUSNR, 'String', '+')
set(handles.SetImageQualityIUSNR, 'BackgroundColor', [0 1 0])

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StatCON1.
function StatCON1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StatCON1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
Dataset.Index_CON1 = [];
set(handles.StatCON1, 'String', '-')
set(handles.StatCON1, 'ForegroundColor', [0 0 0])
set(handles.SetImageQualityCON1, 'String', '+')
set(handles.SetImageQualityCON1, 'BackgroundColor', [0 1 0])

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StatCON2.
function StatCON2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StatCON2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
Dataset.Index_CON2 = [];
set(handles.StatCON2, 'String', '-')
set(handles.StatCON2, 'ForegroundColor', [0 0 0])
set(handles.SetImageQualityCON2, 'String', '+')
set(handles.SetImageQualityCON2, 'BackgroundColor', [0 1 0])

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StatCON3.
function StatCON3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StatCON3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Dataset
Dataset.Index_CON3 = [];
set(handles.StatCON3, 'String', '-')
set(handles.StatCON3, 'ForegroundColor', [0 0 0])
set(handles.SetImageQualityCON3, 'String', '+')
set(handles.SetImageQualityCON3, 'BackgroundColor', [0 1 0])

function CheckRedundance(handles)

global Dataset
FileName    = [Dataset.Site,' - ',Dataset.SiteCode,' (',Dataset.Manufacturer,') - ',Dataset.Acquisition, ' - ',Dataset.Acquisition,' - ',Dataset.Session,' - ',Dataset.Type,'.mat'];
%Remove 
FileName    = strrep(FileName, '/', '');
FileName    = strrep(FileName, '\', '');
FileName    = strrep(FileName, ':', '');
FileName    = strrep(FileName, '*', '');
FileName    = strrep(FileName, '?', '');
FileName    = strrep(FileName, '"', '');
FileName    = strrep(FileName, '<', '');
FileName    = strrep(FileName, '>', '');
FileName    = strrep(FileName, '|', '');

set(handles.DatasetName, 'String', FileName);
if exist(['Phantom Datasets/',FileName], 'file')
    set(handles.DatasetNameWarning, 'Visible','on') 
else
    set(handles.DatasetNameWarning, 'Visible','off') 
end



function DatasetName_Callback(hObject, eventdata, handles)
% hObject    handle to DatasetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DatasetName as text
%        str2double(get(hObject,'String')) returns contents of DatasetName as a double


% --- Executes during object creation, after setting all properties.
function DatasetName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DatasetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PhantomList.
function PhantomList_Callback(hObject, eventdata, handles)
% hObject    handle to PhantomList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PhantomList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PhantomList

set(handles.ListIndex,'String',num2str(get(handles.PhantomList,'Value')));


% --- Executes during object creation, after setting all properties.
function PhantomList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PhantomList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadFromList.
function LoadFromList_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFromList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global PhantomList
String  = get(handles.ListIndex,'String');
Index   = round(str2double(String));
[NumOfFolders,~] = size(PhantomList);
if ~isnan(Index) && Index >= 1 && Index <= NumOfFolders 
    FileName = PhantomList{Index,3};
    PathName = [PhantomList{Index,1},'\'];
    LoadImages(FileName, PathName, handles)
    
end


function LoadAndSetList(handles)

    global PhantomList
    PhantomList = load('FolderList.mat');
    %PhantomList = {};
    PhantomList = PhantomList.TestDataset;
    %Remove non-phantom entrys
    PhantomList(find(~cell2mat(PhantomList(:,2))),:) = [];
    
    Paths               = PhantomList(:,1);
    set(handles.PhantomList, 'String', Paths)



function ListIndex_Callback(hObject, eventdata, handles)
% hObject    handle to ListIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListIndex as text
%        str2double(get(hObject,'String')) returns contents of ListIndex as a double

global PhantomList

String = get(handles.ListIndex,'String');
Index  = str2double(String);
if ~isnan(Index) && Index >= 1 && Index <= length(PhantomList)
    set(handles.PhantomList,'Value',max(1,abs(round(Index))))
    set(handles.ListIndex,'String',num2str(abs(round(Index))))
else
    set(handles.ListIndex,'String','1')
end
    

% --- Executes during object creation, after setting all properties.
function ListIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SiteText_Callback(hObject, eventdata, handles)
% hObject    handle to SiteText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SiteText as text
%        str2double(get(hObject,'String')) returns contents of SiteText as a double


% --- Executes during object creation, after setting all properties.
function SiteText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SiteText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SiteCodeText_Callback(hObject, eventdata, handles)
% hObject    handle to SiteCodeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SiteCodeText as text
%        str2double(get(hObject,'String')) returns contents of SiteCodeText as a double


% --- Executes during object creation, after setting all properties.
function SiteCodeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SiteCodeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
