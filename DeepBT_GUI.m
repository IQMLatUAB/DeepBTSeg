function varargout = DeepBT_GUI(varargin)
% DEEPBT_GUI MATLAB code for DeepBT_GUI.fig
%      DEEPBT_GUI, by itself, creates a new DEEPBT_GUI or raises the existing
%      singleton*.
%
%      H = DEEPBT_GUI returns the handle to a new DEEPBT_GUI or the handle to
%      the existing singleton*.
%
%      DEEPBT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEEPBT_GUI.M with the given input arguments.
%
%      DEEPBT_GUI('Property','Value',...) creates a new DEEPBT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DeepBT_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DeepBT_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DeepBT_GUI

% Last Modified by GUIDE v2.5 04-Feb-2021 10:33:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DeepBT_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DeepBT_GUI_OutputFcn, ...
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


% --- Executes just before DeepBT_GUI is made visible.
function DeepBT_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DeepBT_GUI (see VARARGIN)

% Choose default command line output for DeepBT_GUI
jobmgr.empty_cache(@jobmgr.example.solver);
handles.output = hObject;
%%%%%You must comment the addpath when matlab compiler
addpath utils
addpath DICOM2Nifti
%%%%%
if isfolder('DeepSeg_nii_dir')
    rmdir('DeepSeg_nii_dir','s');
end
if isfolder('DeepSeg_files')
    rmdir('DeepSeg_files','s');
end

try
    %     websave('DeepBT_softlist.mat','https://drive.google.com/uc?export=download&id=1o7xPhexFo9G_dcBnfywsw_4Ve-GjnEgU'); % load the default argument from google drive
    websave('DeepBTSeg_softlist.csv','https://drive.google.com/uc?export=download&id=1z0gtFeoj8JZiiSZL87RdWdVdlRGOmuWY'); % load the default argument from google drive
catch ME
    if strcmp(ME.message,'Could not access server. https://drive.google.com/uc?export=download&id=1o7xPhexFo9G_dcBnfywsw_4Ve-GjnEgU.')
        %warndlg('Fail to download softlist. Please check Internet connection and restart DeepNI.', '!! Warning !!');
        handles.output = 0;
        return;
    end
end

% choose the version of dicominfo_fastversion.m
if ~isfile('utils/dicominfo_fastversion.m')
    version = ver;
    version = version.Release;
    if strcmp(version, '(R2020a)') || str2double(version(3:6))<2020
        str = which('dicominfo_fastversion_R2020a.m');
        copyfile(str, append(str(1:end-9),'.m'));
    else
        str = which('dicominfo_fastversion_R2020b.m');
        copyfile(str, append(str(1:end-9), '.m'));
    end
end

softlist = readcell('DeepBTSeg_softlist.csv');
[r,c] = size(softlist);
for i =1:r
    for j = 1:c
        if (ismissing(softlist{i,j})) %% replace the missing value with 0x0 double
            softlist{i,j}=[];
        end
    end
end
set(handles.software_list,'string',softlist(1, 2:end));
handles.job_content = cell(1,14);
handles.pre_proctacont = cell(1, 9);
set(handles.pre_process_table, 'Unit','characters','Data',handles.pre_proctacont);
set(handles.job_table, 'Unit','characters','Data',handles.job_content(1:10));
% Update handles structure 
guidata(hObject, handles);
uiwait(handles.figure1);

% UIWAIT makes DeepBT_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DeepBT_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
jobmgr.empty_cache(@jobmgr.example.solver); %delete previous processing result
if isfolder('DeepSeg_nii_dir')
    rmdir('DeepSeg_nii_dir','s'); 
end
if isfolder('DeepSeg_files')
    rmdir('DeepSeg_files','s');
end
delete('DeepBTSeg_softlist.csv');
% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on button press in Load_Dicom.
function Load_Dicom_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Dicom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dicom_path = uigetdir('*.*');
if dicom_path
    [filelist fusion_filelist tempinfo] = parse_directory_for_dicom(dicom_path);
    handles.filelist = filelist;
    handles.dicominfo = tempinfo;
    set(handles.pre_process_table, 'Unit','characters','Data',tempinfo);
end
guidata(hObject, handles);

% --- Executes on button press in Submit_job.
function Submit_job_Callback(hObject, eventdata, handles)
if ~isfield(handles,'filelist')
    msgbox('Please specify data before submitting jobs!');
    return;
end
img_dir{2}{1} = handles.filelist{1,1};
img_dir{2}{2} = handles.filelist{2,1};
img_dir{2}{3} = handles.filelist{3,1};
img_dir{2}{4} = handles.filelist{4,1};
sub_idx = 2;
%%
%check Internet connection to server and reactivate the connection if the
%socket timeout(10 minutes)
conbar = waitbar(0.5,'Check the Internet connection....');
try
    [job_msg, job_result] = jobmgr.server.control('check_server_connection');
catch ME
    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
        fprintf('Attemp to reconnect.....');
    end
end
close(conbar);

bar = waitbar(0,'Submitting a job to server....'); 
for seq_idx = 1:4%length(img_dir{sub_idx})
    clear img_all;clear vec1;clear vec2;
    %file_info = list_all_files(img_dir{sub_idx}{seq_idx}, {}, '');
    waitbar(0.05*seq_idx);
    % Read the DICOM images of a series
    valid_dicom_list = {};
    for idx = 1:length(img_dir{sub_idx}{seq_idx})
        if ~isdicom(img_dir{sub_idx}{seq_idx}{idx})
            continue;
        end
        valid_dicom_list{end+1} = img_dir{sub_idx}{seq_idx}{idx};
        temp1 = double(dicomread(img_dir{sub_idx}{seq_idx}{idx}));
        temp2 = dicominfo(img_dir{sub_idx}{seq_idx}{idx});
        vec1(idx) = temp2.ImagePositionPatient(3);
    end
    if seq_idx ==1
        UID = temp2.SOPInstanceUID; %get UID to rename copyfile input_T1.nii 
    end
    [sorted_x sorted_idx] = sort(vec1,'descend');
    img_dir{sub_idx}{seq_idx} = valid_dicom_list(sorted_idx);
    
    for idx = 1:length(img_dir{sub_idx}{seq_idx})
        if ~isdicom(img_dir{sub_idx}{seq_idx}{idx})
            continue;
        end
        temp1 = double(dicomread(img_dir{sub_idx}{seq_idx}{idx}));
        temp2 = dicominfo(img_dir{sub_idx}{seq_idx}{idx});
        if ~isfield(temp2, 'RescaleSlope')
            temp2.RescaleSlope = 1;
        end
        if ~isfield(temp2, 'RescaleIntercept')
            temp2.RescaleIntercept = 0;
        end        
        
        img_all(:,:,idx) = (double(temp1)*double(temp2.RescaleSlope)+double(temp2.RescaleIntercept));
        
    end
    % decide which series is which
    if seq_idx == 1
        hdr_T1 = temp2;
        img_T1 = img_all;
        ori_T1_fileinfo = img_dir{sub_idx}{seq_idx};
    elseif seq_idx == 2        
        img_T1post_ori = img_all;
        hdr_T1post = temp2;
        elseif seq_idx == 3        
        img_T2_ori = img_all;
        hdr_T2 = temp2;
        elseif seq_idx == 4
        img_FLAIR_ori = img_all;
        hdr_FLAIR = temp2;
    end
end

%% transform all series to the pre-contrast T1 coordinates/size
[M,Rot] = GetTransformMatrix(hdr_T1post,hdr_T1);
M = M';
tform = affine3d(M);
[img_T1post,~] = imwarp(img_T1post_ori,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img_T1)));

[M,Rot] = GetTransformMatrix(hdr_T2,hdr_T1);
M = M';
tform = affine3d(M);
[img_T2,~] = imwarp(img_T2_ori,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img_T1)));

[M,Rot] = GetTransformMatrix(hdr_FLAIR,hdr_T1);
M = M';
tform = affine3d(M);
[img_FLAIR,~] = imwarp(img_FLAIR_ori,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img_T1)));

img_T1 = flip(img_T1,3);
img_T1post = flip(img_T1post,3);
img_T2 = flip(img_T2,3);
img_FLAIR = flip(img_FLAIR,3);
waitbar(0.3);
%%
% temp2  = dicm2nii_DeanMod(img_dir{sub_idx}{1}, fullfile(tempdir, temp_nifti_filename), 'nii', 'input_T1');
% temp2  = dicm2nii_DeanMod(img_dir{sub_idx}{1}, append(ctfroot,'\nii_dir'), 'nii', 'input_T1'); %for Matlab compiler
% V = niftiread(append(ctfroot,'\nii_dir\input_T1.nii'));
% copyfile(append(ctfroot,'\nii_dir\input_T1.nii'),append(ctfroot,'\nii_dir\', UID,'T1.nii')); % will be used later
% info = niftiinfo(append(ctfroot,'\nii_dir\input_T1.nii'));

temp2  = dicm2nii_DeanMod(img_dir{sub_idx}{1}, append(pwd,'\DeepSeg_nii_dir'), 'nii', 'input_T1'); %for Matlab
V = niftiread(append(pwd,'\DeepSeg_nii_dir\input_T1.nii'));
copyfile(append(pwd,'\DeepSeg_nii_dir\input_T1.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'T1.nii')); % will be used later
info = niftiinfo(append(pwd,'\DeepSeg_nii_dir\input_T1.nii'));

%temp2  = dicm2nii_DeanMod(img_dir{sub_idx}{5}, fullfile(temp_dir, temp_nifti_filename), 'nii', 'input_mask');
%% note to myself: You shall consider adding motion correction here!!!!!!!!!!!!!!!!!!!!!!!

%%
% pad the images by 200 pixels more
if size(V,1)>size(V,2)
    pad_to_size = size(V,1)+200;
else
    pad_to_size = size(V,2)+200;
end

V2 = zeros(pad_to_size, pad_to_size, size(V,3));
row_start = round((pad_to_size-size(V,1))/2);
col_start = round((pad_to_size-size(V,2))/2);

V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V;
scale_factor = (2^15-1)/max(V2(:)); info.MultiplicativeScaling = 1/scale_factor;
V2 = int16(V2 * scale_factor);
info.ImageSize = [pad_to_size pad_to_size size(V,3)];%info.ImageSize([2 1 3]);
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_T1.nii'), info); 


%
V1 = permute(flip(img_T1post,1), [2 1 3]);
scale_factor = (2^15-1)/max(V1(:)); info.MultiplicativeScaling = 1/scale_factor;
V1 = int16(V1 * scale_factor);
V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V1;
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_T1post.nii'), info); 


V1 = permute(flip(img_T2,1), [2 1 3]);
scale_factor = (2^15-1)/max(V1(:)); info.MultiplicativeScaling = 1/scale_factor;
V1 = int16(V1 * scale_factor);
V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V1;
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_T2'), info); 


V1 = permute(flip(img_FLAIR,1), [2 1 3]);
scale_factor = (2^15-1)/max(V1(:)); info.MultiplicativeScaling = 1/scale_factor;
V1 = int16(V1 * scale_factor);
V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V1;
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_FLAIR'), info); 


guidata(hObject, handles);

copyfile(append(pwd,'\DeepSeg_nii_dir\input_T1post.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'T1post.nii')); % will be used later
copyfile(append(pwd,'\DeepSeg_nii_dir\input_T2.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'T2.nii')); % will be used later
copyfile(append(pwd,'\DeepSeg_nii_dir\input_FLAIR.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'FLAIR.nii')); % will be used later

%%%for matlab compiler
% copyfile(append(ctfroot,'\nii_dir\input_T1post.nii'),append(ctfroot,'\nii_dir\', UID,'T1post.nii')); % will be used later
% copyfile(append(ctfroot,'\nii_dir\input_T2.nii'),append(ctfroot,'\nii_dir\', UID,'T2.nii')); % will be used later
% copyfile(append(ctfroot,'\nii_dir\input_FLAIR.nii'),append(ctfroot,'\nii_dir\', UID,'FLAIR.nii')); % will be used later
%V2 = niftiread('C:\Users\ZWENG\AppData\Local\Temp\input_FLAIR.nii');
waitbar(0.4);
%%
%use jobmgr toolbox to send files to remote server
%for matlab
config = struct();
config.solver = @jobmgr.example.solver;
clientdata = config;
fileID = fopen('DeepSeg_nii_dir/input_T1.nii', 'r');
clientdata.input{1} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
fileID = fopen('DeepSeg_nii_dir/input_T1post.nii', 'r');
clientdata.input{2} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
fileID = fopen('DeepSeg_nii_dir/input_T2.nii', 'r');
clientdata.input{3} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
fileID = fopen('DeepSeg_nii_dir/input_FLAIR.nii', 'r');
clientdata.input{4} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
 

waitbar(0.6);


clientdata.softnum = get(handles.software_list, 'Value');
configs = {clientdata};
run_opts = struct();
run_opts.execution_method = 'job_server';
run_opts.run_names = {'clientdata'};
waitbar(0.8);


try
    r = jobmgr.run(configs, run_opts);
catch ME
    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
        warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
        close(bar);
    end
    return;
end


waitbar(1);
close(bar);
sofidx = get(handles.software_list,'value');
sofstr = get(handles.software_list,'string');
currsof = sofstr{sofidx}; % the name of software user choose
if isempty(r{1})
    temp2 = {'Action' 'Submitted'};
    temp2{3} = currsof;
    temp2(:, 4:10) = handles.dicominfo(1, 2:end);
    temp2{:,11} = sofidx;
    temp2{:,12} = jobmgr.struct_hash(clientdata); %find the key of this job in the hash map
    temp2{:,13} = UID; %store input_T1.nii filename in order to registor contour result
    temp2(:,14) = handles.filelist(1,1);
    if isempty(handles.job_content{3})
        handles.job_content = temp2;
    else
        handles.job_content(end+1,:) = temp2;
    end
    job_show = handles.job_content(:,1:10);
    set(handles.job_table, 'Unit','characters','Data',job_show);
    [job_msg, job_result] = jobmgr.server.control('check_job',handles.job_content{end,12});
    msgbox(job_msg);
end
guidata(hObject,handles);




% --- Executes on selection change in software_list.
function software_list_Callback(hObject, eventdata, handles)
% hObject    handle to software_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns software_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from software_list


% --- Executes during object creation, after setting all properties.
function software_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to software_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Server_setting.
function Server_setting_Callback(hObject, eventdata, handles)
% hObject    handle to Server_setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
blank = server_addr_GUI();
clear all;
return;

% --- Executes when entered data in editable cell(s) in job_table.
function job_table_CellEditCallback(hObject, eventdata, handles)
idx = eventdata.Indices;
table_info = get(handles.job_table,'Data');
job_selected = handles.job_content(idx(1), :);
act = table_info{idx(1),1};

%check Internet connection to server and reactivate the connection if the
%socket timeout(10 minutes)
conbar = waitbar(0.5,'Check the Internet connection....');
try
    [job_msg, job_result] = jobmgr.server.control('check_server_connection');
catch ME
    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
        fprintf('Attemp to reconnect.....');
    end
end
close(conbar);

if table_info{idx(1),4}
    switch act
        case 'Check job'
            if strcmp(handles.job_content(idx(1),2), 'Submitted')
                try
                    [job_msg, job_result] = jobmgr.server.control('check_job',cell2mat(handles.job_content(idx(1), 12)));
                catch ME
                    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
                        warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
                        close(bar);
                    end
                    return;
                end
                
                if ~isempty(job_result)
                    jobmgr.store(@jobmgr.example.solver, cell2mat(handles.job_content(idx(1), 12)), job_result); %store the result in cache
                    
                    handles.job_content{idx(1), 2} = 'Completed';
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                    fprintf('receive jobs from server!\n');
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                    
                    guidata(hObject, handles);
                else
                    msgbox(job_msg);
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                end
            end
            handles.job_content{idx(1),1} = 'Action';
            job_show = handles.job_content(:,1:10);
            set(handles.job_table, 'Unit','characters','Data',job_show);
        
        case 'Cancel job'
            hash = handles.job_content{idx(1), 12};
            try
                [response_msg, ~] = jobmgr.server.control('cancel_job',hash);
            catch ME
                if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
                    warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
                    close(bar);
                end
                return;
            end
            r = jobmgr.recall(@jobmgr.example.solver, hash);
            if isempty(r)
                if strcmp(response_msg,'OK')
                    handles.job_content(idx(1),:) = [];
                    if isempty(handles.job_content)
                        handles.job_content = cell(1,14);
                    end
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                    msgbox('This job has been canceled in server.');
                end
            else
                waitfor(msgbox('Cannot cancel a job which is being processing in server.'));
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
            end
            
        case 'View results'
            if ~strcmp(handles.job_content(idx(1), 2), 'Submitted')
                hashkey = handles.job_content{idx(1), 12};
                sof = handles.job_content{idx(1),11};
                show_content = handles.job_content(idx(1), 3:14);
                Viewer(hashkey, sof, show_content);
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
            else
                waitfor(msgbox('There is no result for this job. Please choose "check job".'));
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
                
            end
        case 'Export results'
            if ~strcmp(handles.job_content(idx(1), 2), 'Submitted') 
                DICOMRT_conversion_v01152021(handles.job_content{idx(1), 13}, handles.job_content{idx(1), 14}, handles.job_content{idx(1), 12}, handles.job_content{idx(1), 11});
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
            else
                msgbox('There is no result for this job. Please choose "check job".');
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
                
            end
    end
end


% --- Executes on button press in Update_all_jobs.
function Update_all_jobs_Callback(hObject, eventdata, handles)
% hObject    handle to Update_all_jobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.non_compl = [];
bar = waitbar(0, 'Updating all jobs......');
[idx,~] = size(handles.job_content);
for i=1:idx %find all non-completed jobs
    if ~strcmp(handles.job_content{i, 2}, 'Completed') && ~isempty(handles.job_content{i, 2})
        handles.non_compl = [handles.non_compl, i];
    end
end
if isempty(handles.non_compl)
    guidata(hObject, handles);
    waitbar(1);
    close(bar);
    return;
end

%check Internet connection to server and reactivate the connection if the
%socket timeout(10 minutes)
conbar = waitbar(0.5,'Check the Internet connection....');
try
    [job_msg, job_result] = jobmgr.server.control('check_server_connection');
catch ME
    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
        fprintf('Attemp to reconnect.....');
    end
end
close(conbar);


steps = length(handles.non_compl);

for i = 1:length(handles.non_compl)
    waitbar(0.2+0.8*(i/steps));
    try
        [job_msg, job_result] = jobmgr.server.control('check_job',cell2mat(handles.job_content(handles.non_compl(i), 12)));
        
    catch ME
        if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
            warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
            close(bar);
        end
        return;
    end
 
    if ~isempty(job_result)
        jobmgr.store(@jobmgr.example.solver, cell2mat(handles.job_content(handles.non_compl(i), 12)), job_result); %store the result in cache
        
        handles.job_content{handles.non_compl(i), 2} = 'Completed';
        job_show = handles.job_content(:,1:10);
        set(handles.job_table, 'Unit','characters','Data',job_show);
        fprintf('receive jobs from server!\n');
        guidata(hObject, handles);
    end
end
close(bar);
guidata(hObject, handles);

% --- Executes on button press in Clear_exported.
function Clear_exported_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_exported (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[idx,~] = size(handles.job_content);
to_del = [];
if idx
    for i = 1:idx
        if strcmp(handles.job_content(i, 2), 'Exported')
           to_del = [to_del, i]; 
        end
    end
    for i = i:length(to_del)
        handles.job_content(to_del(i)) = [];
    end
end
guidata(hObject, handles);

% --- Executes on button press in Cancel_all_jobs.
function Cancel_all_jobs_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_all_jobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.job_content = cell(1,14);
set(handles.job_table, 'Unit','characters','Data',handles.job_content(1:10));
jobmgr.empty_cache(@jobmgr.example.solver); %empty previous processing result
guidata(hObject, handles);


% --- Executes on button press in Submit_all_model.
function Submit_all_model_Callback(hObject, eventdata, handles)
if ~isfield(handles,'filelist')
    msgbox('Please specify data before submitting jobs!');
    return;
end

img_dir{2}{1} = handles.filelist{1,1};
img_dir{2}{2} = handles.filelist{2,1};
img_dir{2}{3} = handles.filelist{3,1};
img_dir{2}{4} = handles.filelist{4,1};
sub_idx = 2;
sofstr = get(handles.software_list,'string');
[sofnum,~ ]= size(sofstr);
%%

bar = waitbar(0,'Submitting all jobs to server....');

for seq_idx = 1:4%length(img_dir{sub_idx})
    clear img_all;clear vec1;clear vec2;
    %file_info = list_all_files(img_dir{sub_idx}{seq_idx}, {}, '');
    waitbar(0.05*seq_idx);
    % Read the DICOM images of a series
    valid_dicom_list = {};
    for idx = 1:length(img_dir{sub_idx}{seq_idx})
        if ~isdicom(img_dir{sub_idx}{seq_idx}{idx})
            continue;
        end
        valid_dicom_list{end+1} = img_dir{sub_idx}{seq_idx}{idx};
        temp1 = double(dicomread(img_dir{sub_idx}{seq_idx}{idx}));
        temp2 = dicominfo(img_dir{sub_idx}{seq_idx}{idx});
        vec1(idx) = temp2.ImagePositionPatient(3);
    end
    if seq_idx ==1
        UID = temp2.SOPInstanceUID; %get UID to rename copyfile input_T1.nii
    end
    [sorted_x sorted_idx] = sort(vec1,'descend');
    img_dir{sub_idx}{seq_idx} = valid_dicom_list(sorted_idx);
    
    for idx = 1:length(img_dir{sub_idx}{seq_idx})
        if ~isdicom(img_dir{sub_idx}{seq_idx}{idx})
            continue;
        end
        temp1 = double(dicomread(img_dir{sub_idx}{seq_idx}{idx}));
        temp2 = dicominfo(img_dir{sub_idx}{seq_idx}{idx});
        if ~isfield(temp2, 'RescaleSlope')
            temp2.RescaleSlope = 1;
        end
        if ~isfield(temp2, 'RescaleIntercept')
            temp2.RescaleIntercept = 0;
        end
        
        img_all(:,:,idx) = (double(temp1)*double(temp2.RescaleSlope)+double(temp2.RescaleIntercept));
        
    end
    % decide which series is which
    if seq_idx == 1
        hdr_T1 = temp2;
        img_T1 = img_all;
        ori_T1_fileinfo = img_dir{sub_idx}{seq_idx};
    elseif seq_idx == 2
        img_T1post_ori = img_all;
        hdr_T1post = temp2;
    elseif seq_idx == 3
        img_T2_ori = img_all;
        hdr_T2 = temp2;
    elseif seq_idx == 4
        img_FLAIR_ori = img_all;
        hdr_FLAIR = temp2;
    end
end

%% transform all series to the pre-contrast T1 coordinates/size
[M,Rot] = GetTransformMatrix(hdr_T1post,hdr_T1);
M = M';
tform = affine3d(M);
[img_T1post,~] = imwarp(img_T1post_ori,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img_T1)));

[M,Rot] = GetTransformMatrix(hdr_T2,hdr_T1);
M = M';
tform = affine3d(M);
[img_T2,~] = imwarp(img_T2_ori,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img_T1)));

[M,Rot] = GetTransformMatrix(hdr_FLAIR,hdr_T1);
M = M';
tform = affine3d(M);
[img_FLAIR,~] = imwarp(img_FLAIR_ori,tform,'Interp','cubic','FillValues',0,'OutputView',imref3d(size(img_T1)));

img_T1 = flip(img_T1,3);
img_T1post = flip(img_T1post,3);
img_T2 = flip(img_T2,3);
img_FLAIR = flip(img_FLAIR,3);
waitbar(0.3);
%%
% temp2  = dicm2nii_DeanMod(img_dir{sub_idx}{1}, fullfile(tempdir, temp_nifti_filename), 'nii', 'input_T1');
temp2  = dicm2nii_DeanMod(img_dir{sub_idx}{1}, append(pwd,'\DeepSeg_nii_dir'), 'nii', 'input_T1');
V = niftiread(append(pwd,'\DeepSeg_nii_dir\input_T1.nii'));
copyfile(append(pwd,'\DeepSeg_nii_dir\input_T1.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'T1.nii')); % will be used later
info = niftiinfo(append(pwd,'\DeepSeg_nii_dir\input_T1.nii'));

%temp2  = dicm2nii_DeanMod(img_dir{sub_idx}{5}, fullfile(temp_dir, temp_nifti_filename), 'nii', 'input_mask');
%% note to myself: You shall consider adding motion correction here!!!!!!!!!!!!!!!!!!!!!!!

%%
% pad the images by 200 pixels more
if size(V,1)>size(V,2)
    pad_to_size = size(V,1)+200;
else
    pad_to_size = size(V,2)+200;
end

V2 = zeros(pad_to_size, pad_to_size, size(V,3));
row_start = round((pad_to_size-size(V,1))/2);
col_start = round((pad_to_size-size(V,2))/2);

V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V;
scale_factor = (2^15-1)/max(V2(:)); info.MultiplicativeScaling = 1/scale_factor;
V2 = int16(V2 * scale_factor);
info.ImageSize = [pad_to_size pad_to_size size(V,3)];%info.ImageSize([2 1 3]);
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_T1.nii'), info);

%
V1 = permute(flip(img_T1post,1), [2 1 3]);
scale_factor = (2^15-1)/max(V1(:)); info.MultiplicativeScaling = 1/scale_factor;
V1 = int16(V1 * scale_factor);
V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V1;
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_T1post.nii'), info);

V1 = permute(flip(img_T2,1), [2 1 3]);
scale_factor = (2^15-1)/max(V1(:)); info.MultiplicativeScaling = 1/scale_factor;
V1 = int16(V1 * scale_factor);
V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V1;
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_T2'), info);

V1 = permute(flip(img_FLAIR,1), [2 1 3]);
scale_factor = (2^15-1)/max(V1(:)); info.MultiplicativeScaling = 1/scale_factor;
V1 = int16(V1 * scale_factor);
V2(row_start:(row_start+size(V,1)-1), col_start:(col_start+size(V,2)-1), :) = V1;
niftiwrite(V2, append(pwd,'\DeepSeg_nii_dir\input_FLAIR'), info);
guidata(hObject, handles);

copyfile(append(pwd,'\DeepSeg_nii_dir\input_T1post.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'T1post.nii')); % will be used later
copyfile(append(pwd,'\DeepSeg_nii_dir\input_T2.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'T2.nii')); % will be used later
copyfile(append(pwd,'\DeepSeg_nii_dir\input_FLAIR.nii'),append(pwd,'\DeepSeg_nii_dir\', UID,'FLAIR.nii')); % will be used later
%V2 = niftiread('C:\Users\ZWENG\AppData\Local\Temp\input_FLAIR.nii');
waitbar(0.4);
%%
%use jobmgr toolbox to send files to remote server

config = struct();
config.solver = @jobmgr.example.solver;
clientdata = config;
fileID = fopen('DeepSeg_nii_dir/input_T1.nii', 'r');
clientdata.input{1} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
fileID = fopen('DeepSeg_nii_dir/input_T1post.nii', 'r');
clientdata.input{2} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
fileID = fopen('DeepSeg_nii_dir/input_T2.nii', 'r');
clientdata.input{3} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
fileID = fopen('DeepSeg_nii_dir/input_FLAIR.nii', 'r');
clientdata.input{4} = fread(fileID,'*bit8'); %% read the file
fclose(fileID);

waitbar(0.5);
for sof = 1:sofnum
    clientdata.softnum = sof;
    configs = {clientdata};
    run_opts = struct();
    run_opts.execution_method = 'job_server';
    run_opts.run_names = {'clientdata'};
%     t = 0.5+((0.5/sofnum)*sof);
    waitbar(0.5+((0.5/sofnum)*sof));
    try
        r = jobmgr.run(configs, run_opts);
    catch ME
        if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
            warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
            close(bar);
        end
        return;
    end
    
    
    %     sofidx = get(handles.software_list,'value');
    %     sofstr = get(handles.software_list,'string');
    currsof = sofstr{sof}; % the name of software user choose
    if isempty(r{1})
        temp2 = {'Action' 'Submitted'};
        temp2{3} = currsof;
        temp2(:, 4:10) = handles.dicominfo(1, 2:end);
        temp2{:,11} = sof;
        temp2{:,12} = jobmgr.struct_hash(clientdata); %find the key of this job in the hash map
        temp2{:,13} = UID; %store input_T1.nii filename in order to registor contour result
        temp2{:,14} = handles.filelist(1,1);
        if isempty(handles.job_content{3})
            handles.job_content = temp2;
        else
            handles.job_content(end+1,:) = temp2;
        end
        job_show = handles.job_content(:,1:10);
        set(handles.job_table, 'Unit','characters','Data',job_show);
        [job_msg, job_result] = jobmgr.server.control('check_job',handles.job_content{end,12});
        msgbox(job_msg);
    end
    guidata(hObject,handles);
end
close(bar);
