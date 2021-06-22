function varargout = Viewer(varargin)
% VIEWER MATLAB code for Viewer.fig
%      VIEWER, by itself, creates a new VIEWER or raises the existing
%      singleton*.
%
%      H = VIEWER returns the handle to a new VIEWER or the handle to
%      the existing singleton*.
%
%      VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER.M with the given input arguments.
%
%      VIEWER('Property','Value',...) creates a new VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Viewer

% Last Modified by GUIDE v2.5 09-Feb-2021 11:04:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @Viewer_OutputFcn, ...
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


% --- Executes just before Viewer is made visible.
function Viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Viewer (see VARARGIN)

% Choose default command line output for Viewer
handles.output = hObject;
%%%%%% You must comment the addpath when matlab compiler
% addpath utils
%%%%%%
handles.btndwn_fcn2        = @(hObject,eventdata)Viewer('axes2_ButtonDownFcn',hObject,eventdata,guidata(hObject));
handles.btndwn_fcn3        = @(hObject,eventdata)Viewer('axes3_ButtonDownFcn',hObject,eventdata,guidata(hObject));
handles.btndwn_fcn1        = @(hObject,eventdata)Viewer('axes1_ButtonDownFcn',hObject,eventdata,guidata(hObject));
iptPointerManager(handles.figure1, 'enable');
% Have the pointer change to a cross when the mouse enters an axes object:
iptSetPointerBehavior(handles.axes2, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
iptSetPointerBehavior(handles.axes3, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
iptSetPointerBehavior(handles.axes1, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
axes(handles.axes1);image([0 0;0 0]);colormap gray;
axis off;
axes(handles.axes2);image([0 0;0 0]);colormap gray;
axis off;
axes(handles.axes3);image([0 0;0 0]);colormap gray;
axis off;
bar = waitbar(0,'Loading image......');
handles.hashkey = varargin{1};
handles.currsoft = varargin{2}; % defult current soft in soft list, 1 means Fangmodel
handles.content_show = varargin{3};

r = jobmgr.recall(@jobmgr.example.solver, handles.hashkey);
waitbar(0.6);
contour = r{1};
if ~isfolder('DeepSeg_files') %make sure files folder exists
    mkdir DeepSeg_files;
end
if handles.currsoft ==1 || handles.currsoft == 3 || handles.currsoft == 4 || handles.currsoft == 5
    fileID = fopen('DeepSeg_files/Seg_results_inverted.nii','w+');
    fwrite(fileID,contour,'*bit8');
    fclose(fileID);
    % gunzip('files\Seg_results_inverted.nii.gz','files\');
    contour = niftiread(append(pwd,'/DeepSeg_files/Seg_results_inverted.nii'));
    
elseif handles.currsoft ==2
    fileID = fopen('DeepSeg_files/DeepSeg_results_inverted.nii','w+');
    fwrite(fileID,contour,'*bit8');
    fclose(fileID);
    contour = niftiread(append(pwd,'/DeepSeg_files/DeepSeg_results_inverted.nii'));
end

% V = niftiread('/mnt/c/temp/Seg_results_inverted.nii.gz');
% V = round(V/1000);
% Vtemp1 = niftiread('/mnt/c/temp/input_T1_original.nii');
% read 4 dicom series in a 4D matrix
handles.image_vol_all(:,:,:,1) = niftiread(append('DeepSeg_nii_dir/', handles.content_show{:,11},'T1.nii'));
image_vol_all(:,:,:,1) = niftiread(append('DeepSeg_nii_dir/', handles.content_show{:,11},'T1post.nii'));
image_vol_all(:,:,:,2) = niftiread(append('DeepSeg_nii_dir/', handles.content_show{:,11},'T2.nii'));
image_vol_all(:,:,:,3) = niftiread(append('DeepSeg_nii_dir/', handles.content_show{:,11},'FLAIR.nii'));
waitbar(0.8);
% trim the padding 200 pixels  
if size(handles.image_vol_all(:,:,:,1),1)>size(handles.image_vol_all(:,:,:,1),2)
    pad_to_size = size(handles.image_vol_all(:,:,:,1),1)+200;
else
    pad_to_size = size(handles.image_vol_all(:,:,:,1),2)+200;
end
row_start = round((pad_to_size-size(handles.image_vol_all(:,:,:,1),1))/2);
col_start = round((pad_to_size-size(handles.image_vol_all(:,:,:,1),2))/2);

for i = 1:3
    V = image_vol_all(:,:,:,i);
    V = V(row_start:(row_start+size(handles.image_vol_all(:,:,:,1),1)-1), col_start:(col_start+size(handles.image_vol_all(:,:,:,1),2)-1),:);
    handles.image_vol_all(:,:,:,i+1) = V;
end
% read contour and contour label
V_seg_results_nifti = contour(row_start:(row_start+size(handles.image_vol_all(:,:,:,1),1)-1), col_start:(col_start+size(handles.image_vol_all(:,:,:,1),2)-1),:);
[x, y, z] = size(V_seg_results_nifti);


for idx_target = 1:5
    if idx_target==1
        mask1 = ((V_seg_results_nifti==1) + (V_seg_results_nifti==3))>0;
        temp = zeros(x, y, z);
        temp(mask1==1) = 4;
        handles.mask_all(:,:,:,4) = temp;
        now_ROI_name = 'NE+E Tumor';
    elseif idx_target==2
        mask1 = (V_seg_results_nifti>=1);
        temp = zeros(x, y, z);
        temp(mask1==1) = 4;
        handles.mask_all(:,:,:,5) = temp;
        now_ROI_name = 'Edema+NE+E Tumor';
    elseif idx_target==3
        mask1 = (V_seg_results_nifti==1);
        temp = zeros(x, y, z);
        temp(mask1==1) = 4;
        handles.mask_all(:,:,:,1) = temp;
        now_ROI_name = 'NE Tumor';
    elseif idx_target==4
        mask1 = (V_seg_results_nifti==3);
        temp = zeros(x, y, z);
        temp(mask1==1) = 4;
        handles.mask_all(:,:,:,3) = temp;
        now_ROI_name = 'E Tumor';
    else        
        mask1 = (V_seg_results_nifti==2);
        temp = zeros(x, y, z);
        temp(mask1==1) = 4;
        handles.mask_all(:,:,:,2) = temp;
        now_ROI_name = 'Edema';
    end
end
show_info = handles.content_show(1:8);
set(handles.img_content,'Units', 'characters', 'Data', show_info); %show image info and processing model name

temp = cell(1,5);
temp{1, 1} = true;
set(handles.contour_table, 'Unit','characters','Data',temp);
handles.image_vol = handles.image_vol_all(:,:,:,1);
handles.now_label = 1;
handles.all_label = [];
handles = update_image_display(hObject, handles);
% Update handles structure
waitbar(1);
close(bar);
guidata(hObject, handles);

% UIWAIT makes Viewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = update_image_display(hObject, handles)
% if (handles.currsoft ==1)
%     now_label_new = handles.label_vec(get(handles.Contourlist, 'Value'));
% elseif(handles.currsoft ==2)
%     now_label_new = get(handles.Contourlist, 'Value')-1;
% end
contour_table = get(handles.contour_table, 'Data');
% now_label_new = get(handles.Contourlist, 'Value');
new_all_label = [];
for idx = 1: size(contour_table,2)
    if cell2mat(contour_table(1,idx)) == 1
        new_all_label = [new_all_label, idx];
    end
end
if isempty(new_all_label) %at least one contour show on image
    warndlg('Must choose at least one contour!.', '!! Warning !!');
    temp = cell(1,5);
    temp{1, handles.all_label(1)} = true;
    set(handles.contour_table, 'Unit','characters','Data',temp);
    return;
end
% if isempty(find(handles.all_label==now_label_new))
%     handles.all_label = [handles.all_label , now_label_new]; % the contour has not shown on the image
handles.all_label = new_all_label;
handles.mask1 = handles.mask_all(:,:,:, new_all_label(1, end));
%     handles.mask1 = handles.mask_all(:,:,:,now_label_new);
if(~isfield(handles, 'outcurrent_slice'))
    tempvec = squeeze(sum(sum(handles.mask1,1),2));
    tempvec = find(tempvec>0);
    handles.outcurrent_slice = tempvec(round(length(tempvec)/2));
    guidata(handles.axes2, handles);
    tempvec = squeeze(sum(sum(handles.mask1,1),3));
    tempvec = find(tempvec>0);
    handles.outcurrent_j = tempvec(round(length(tempvec)/2));
    guidata(handles.axes2, handles);
    tempvec = squeeze(sum(sum(handles.mask1,2),3));
    tempvec = find(tempvec>0);
    handles.outcurrent_i = tempvec(round(length(tempvec)/2));
    guidata(handles.axes2, handles);
    handles = refresh_allout(handles);
    guidata(hObject, handles);
    guidata(handles.axes2, handles);
end
handles = refresh_allout(handles);
guidata(hObject, handles);
guidata(handles.axes2, handles);

return;


function handles = refresh_allout(handles)
% contra = handles.result_img_contra;

ima = imrotate(handles.image_vol(:, :, handles.outcurrent_slice),90);
map1 = colormap('gray');
% ima = ind2rgb(gray2ind(ima/max(ima(:)), 256), map1);

ima = ind2rgb(gray2ind(rescale(ima,'inputmin',min(ima(:)),'inputmax',max(ima(:))), 256), map1);
%ima = imadjust(ima, [contra ; 1-contra]); %contract adjust
for i = 1:length(handles.all_label)
    mask1 = handles.mask_all(:, :, :, handles.all_label(i));
    mask = imrotate(mask1(:, :, handles.outcurrent_slice),90);
    ima = fuse_img(ima, mask, handles.all_label(i)); %overlap the contour and image
end
img_to_show = ima;
handles.Img1 = imagesc(img_to_show, 'Parent', handles.axes1);
set(handles.Img1, 'ButtonDownFcn', handles.btndwn_fcn1);
colormap gray;
set(handles.axes1,'XTick', [], 'YTick', []);

ima = imrotate(squeeze(handles.image_vol(handles.outcurrent_i, :, :)), 90);
map1 = colormap('gray');
% ima = ind2rgb(gray2ind(ima/max(ima(:)), 256), map1);

ima = ind2rgb(gray2ind(rescale(ima,'inputmin',min(ima(:)),'inputmax',max(ima(:))), 256), map1);
%     ima = imadjust(ima, [contra ; 1-contra]); %contract adjust
for i = 1:length(handles.all_label)
    mask1 = handles.mask_all(:, :, :, handles.all_label(i));
    mask = imrotate(squeeze(mask1(handles.outcurrent_i, :, :)),90);
    ima = fuse_img(ima, mask, handles.all_label(i)); %overlap the contour and image
end
img_to_show = ima;
handles.Img2 = imagesc(img_to_show, 'Parent', handles.axes2);
set(handles.Img2, 'ButtonDownFcn', handles.btndwn_fcn2);
colormap gray;
set(handles.axes2,'XTick', [], 'YTick', []);

ima = imrotate(squeeze(handles.image_vol(:, handles.outcurrent_j, :)), 90);
map1 = colormap('gray');
% ima = ind2rgb(gray2ind(ima/max(ima(:)), 256), map1);


ima = ind2rgb(gray2ind(rescale(ima,'inputmin',min(ima(:)),'inputmax',max(ima(:))), 256), map1);
%     ima = imadjust(ima, [contra ; 1-contra]); %contract adjust
for i = 1:length(handles.all_label)
    mask1 = handles.mask_all(:, :, :, handles.all_label(i));
    mask = imrotate(squeeze(mask1(:, handles.outcurrent_j, :)),90);
    ima = fuse_img(ima, mask, handles.all_label(i)); %overlap the contour and image
end
img_to_show = ima;
handles.Img3 = imagesc(img_to_show, 'Parent', handles.axes3);
set(handles.Img3, 'ButtonDownFcn', handles.btndwn_fcn3);
colormap gray;
set(handles.axes3,'XTick', [], 'YTick', []);
return;

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Axial
a = get(handles.axes1,'currentpoint');
handles.outcurrent_i = round(a(1,1));
handles.outcurrent_j = size(handles.image_vol, 2)-round(a(1,2))+1;
handles = refresh_allout(handles);
guidata(handles.axes2, handles);

return;


% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on mouse press over axes background.
%coronal
a = get(handles.axes3,'currentpoint');
handles.outcurrent_slice = size(handles.image_vol, 3) - round(a(1,2))+1;
handles.outcurrent_i = round(a(1,1));
handles = refresh_allout(handles);
guidata(handles.axes2, handles);

return;

function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

%Sagittal
a = get(handles.axes2,'currentpoint');
handles.outcurrent_slice = size(handles.image_vol, 3) - round(a(1,2))+1;
handles.outcurrent_j = round(a(1,1));
handles = refresh_allout(handles);
guidata(handles.axes2, handles);

return;

% --- Outputs from this function are returned to the command line.
function varargout = Viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Contourlist.
function Contourlist_Callback(hObject, eventdata, handles)
% hObject    handle to Contourlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_image_display(hObject, handles);
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns Contourlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Contourlist


% --- Executes during object creation, after setting all properties.
function Contourlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Contourlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in image_pop.
function image_pop_Callback(hObject, eventdata, handles)
% hObject    handle to image_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% name = get(handles.image_pop,'String');
idx = get(handles.image_pop,'Value');
% name = name(idx);
% handles.image_vol = niftiread(append('files/input_',name{1},'.nii'));

handles.image_vol = handles.image_vol_all(:,:,:,idx);
guidata(hObject, handles);
update_image_display(hObject, handles);
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns image_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from image_pop


% --- Executes during object creation, after setting all properties.
function image_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExportDICOM.
function ExportDICOM_Callback(hObject, eventdata, handles)
% hObject    handle to ExportDICOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when entered data in editable cell(s) in contour_table.
function contour_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to contour_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles = update_image_display(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in export_results.
function export_results_Callback(hObject, eventdata, handles)
DICOMRT_conversion_v01152021(handles.content_show{:,11}, handles.content_show{:,12}, handles.content_show{:,10}, handles.content_show{:,9});
