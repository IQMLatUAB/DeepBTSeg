function varargout = DICOM_selection_GUI(varargin)
% DICOM_SELECTION_GUI MATLAB code for DICOM_selection_GUI.fig
%      DICOM_SELECTION_GUI, by itself, creates a new DICOM_SELECTION_GUI or raises the existing
%      singleton*.
%
%      H = DICOM_SELECTION_GUI returns the handle to a new DICOM_SELECTION_GUI or the handle to
%      the existing singleton*.
%
%      DICOM_SELECTION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DICOM_SELECTION_GUI.M with the given input arguments.
%
%      DICOM_SELECTION_GUI('Property','Value',...) creates a new DICOM_SELECTION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DICOM_selection_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DICOM_selection_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DICOM_selection_GUI

% Last Modified by GUIDE v2.5 14-Jan-2021 09:47:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DICOM_selection_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DICOM_selection_GUI_OutputFcn, ...
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


% --- Executes just before DICOM_selection_GUI is made visible.
function DICOM_selection_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DICOM_selection_GUI (see VARARGIN)

% Choose default command line output for DICOM_selection_GUI  
handles.output = hObject;
axes(handles.axes1);
axis off;

datatable = varargin{1};
table_content = varargin{2};
fileinfo = varargin{3};
study_ID = varargin{4};
study_description = varargin{5};
table_content(:,1)=cell(1,1);
set(handles.property_table, 'Units', 'characters', 'Data', table_content);%, 'ColumnName', columnname, 'ColumnFormat', columnformat, 'ColumnEditable', columneditable);

% figure;
handles.datatable = datatable;
handles.fileinfo = fileinfo;
handles.study_ID = study_ID;
handles.study_description = study_description;
handles.table_content = cell(1,8);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DICOM_selection_GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = DICOM_selection_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles, 'output')
    varargout{1} = handles.output;
    if isfield(handles, 'fusion_filelist')
        varargout{2} = handles.fusion_filelist;
    else
        varargout{2} = '';
    end    
end
varargout{3} = handles.table_content; %table_content of the dicom file which being selected by user
try
    delete(handles.figure1);
    drawnow;
catch EM
end
return;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabledata = get(handles.property_table, 'Data');
value2 = handles.datatable(:,2);
% 
% for idx = 1: size(value1,1)
%     if cell2mat(value1(idx,1)) == 1
%         handles.table_content = value1(idx, 1:8);
%         handles.table_content{end,1} = 0;
%         Date = value1{idx,5};
%         Time = value2{idx};
%     end
% end
% if sum(cell2mat(value1(:,1))) == 0
%     if sum(cell2mat(value1(:,2))) == 0
%         warndlg('None of the studies were selected. Select at least one study.', '!! Warning !!');
%         return;
%     end
%     
% elseif sum(cell2mat(value1(:,1))) >1
%     warndlg('More than one study was selected. Select only one study.', '!! Warning !!');
%     return;
% end
check = zeros(1,4);
for idx = 1:size(tabledata,1)
    if strcmp(tabledata(idx,1),'T1 pre')
        check(1) = check(1)+1;
        handles.table_content(1,:) = tabledata(idx, 1:8);
    elseif strcmp(tabledata(idx,1),'T1 post')
        check(2) = check(2)+1;
        handles.table_content(2,:) = tabledata(idx, 1:8);
    elseif strcmp(tabledata(idx,1),'T2')
        check(3) = check(3)+1;
        handles.table_content(3,:) = tabledata(idx, 1:8);
    elseif strcmp(tabledata(idx,1),'FLAIR')
        check(4) = check(4)+1;
        handles.table_content(4,:) = tabledata(idx, 1:8);
    end
end
%check T1 T1post FLAIR T2 series loss and repetition
for i = 1:size(check,2)
    if check(i) ==0
        if i ==1
            warndlg('Selection error! Lost T1 image!', '!! Warning !!');
            return;
        elseif i==2
            warndlg('Selection error! Lost T1 post image!', '!! Warning !!');
            return;
        elseif i==3
            warndlg('Selection error! Lost T2 image!', '!! Warning !!');
            return;
        elseif i==4
            warndlg('Selection error! Lost FLAIR image!', '!! Warning !!');
            return;
        end
    elseif check(i) >1
        if i ==1
            warndlg('Selection error! More than one T1 image!', '!! Warning !!');
            return;
        elseif i==2
            warndlg('Selection error! More than one T1 post image!', '!! Warning !!');
            return;
        elseif i==3
            warndlg('Selection error! More than one T2 image!', '!! Warning !!');
            return;
        elseif i==4
            warndlg('Selection error! More than one FLAIR image!', '!! Warning !!');
            return;
        end
    end
end

handles.output = cell(4,1);
counter = 0;
for i = 1:size(tabledata, 1)
    if strcmp(tabledata{i,1},'T1 pre') %the data being selected by user for dicom2nifti
        handles.output{1} = handles.datatable{i,1}; %get the dir of the file being selected by user
%         for j = 1:size(ctfiles, 2)
%             counter = counter+1;            
%             handles.output{counter} = ctfiles{1,j}; % save the dir of the file beinbg selected by user to output
%         end
    elseif strcmp(tabledata{i,1},'T1 post')
        handles.output{2} = handles.datatable{i,1};
    elseif strcmp(tabledata{i,1},'T2')
        handles.output{3} = handles.datatable{i,1};
    elseif strcmp(tabledata{i,1},'FLAIR')
        handles.output{4} = handles.datatable{i,1};
    end
end
handles.output = handles.output(1:4,:);
guidata(hObject, handles);
uiresume;
return;


handles.fusion_filelist = cell(1000,1);
counter = 0;
for i = 1:size(tabledata, 1)
    if cell2mat(tabledata(i,2)) == 1
        ctfiles = handles.datatable{i,1};
        for j = 1:size(ctfiles, 2)
            counter = counter+1;            
            handles.fusion_filelist{counter} = ctfiles{1,j};
        end
    end
end
if counter == 0;
    handles.fusion_filelist = [];
else
    handles.fusion_filelist = handles.fusion_filelist(1:counter);
end
guidata(hObject, handles);
uiresume;

return;

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = {};
guidata(hObject, handles);
uiresume;


% --- Executes during object creation, after setting all properties.
function property_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to property_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function property_table_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to property_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when selected cell(s) is changed in property_table.
function property_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to property_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

 % --- Executes when entered data in editable cell(s) in property_table.
function property_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to property_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

 
value = get(hObject,'Data');
table_info = get(handles.property_table,'Data');
[r c] = size(value);
if eventdata.Indices(2) == c
    if sum(cell2mat(value(:,end))) >= 2
        for idx1 = 1:size(value,1)
            value{idx1,eventdata.Indices(2)} = false;
        end
        value{eventdata.Indices(1), eventdata.Indices(2)} = true;
    end
    axes(handles.axes1);
    img_idx = ceil(value{eventdata.Indices(1), eventdata.Indices(2)-1}/2);
    ctfiles = handles.datatable{eventdata.Indices(1),1};
    img = dicomread(ctfiles{1,img_idx});
    if length(size(img))>2
        img = img(:,:, ceil(size(img,3)/2));       
    end
     imagesc(img); axis off;
elseif eventdata.Indices(2) ==1 && strcmp(table_info{eventdata.Indices(1), eventdata.Indices(2)},'Cancel')
    table_info{eventdata.Indices(1), eventdata.Indices(2)} = [];
    value = table_info;
end

set(hObject, 'Data', value);

%  if sum(cell2mat(value(:,1))) >= 2
%      errordlg('Please tick one checkbox once only !!');
% end
guidata(hObject, handles);
