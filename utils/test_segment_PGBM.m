clear all; close all;
% tic
% datestr(now) 
% addpath 'D:\Fang_work\Brain_tumor_seg\DICOM2Nifti';
% 
% temp_dir = 'c:\temp';
% temp_dir_linux_ver = '/mnt/c/temp';
% temp_nifti_filename = '';
% %% convert DICOM to Nifti and register all to T1 images
% convert_DICOM_and_register_to_T1_PGBM_special;
% 
% %% move the file to linux folder
% system('bash -c "cp /mnt/c/temp/input_T1.nii /home/yfang/data/test_now_T1.nii"');
% system('bash -c "cp /mnt/c/temp/input_T1post.nii /home/yfang/data/test_now_T1post.nii"');
% system('bash -c "cp /mnt/c/temp/input_T2.nii /home/yfang/data/test_now_T2.nii"');
% system('bash -c "cp /mnt/c/temp/input_FLAIR.nii /home/yfang/data/test_now_FLAIR.nii"');
% system('bash -c "cp /mnt/c/temp/input_mask.nii /home/yfang/data/test_now_mask.nii"');
% 
% 
% %% spatial normalization. flirt is a function in FSL
% system('bash --login -c "flirt -ref /home/yfang/data/spgr_unstrip.nii -in /home/yfang/data/test_now_T1.nii -dof 12       -out /home/yfang/data/flirt_out_T1 -omat /home/yfang/data/flirt_mat.mat"');
% 
% parfor idx = 1:4
%     if idx == 1
%         system('bash --login -c "flirt -ref /home/yfang/data/spgr_unstrip.nii -in /home/yfang/data/test_now_T1post.nii -applyxfm -out /home/yfang/data/flirt_out_T1post -init /home/yfang/data/flirt_mat.mat"');
%     elseif idx == 2
%         system('bash --login -c "flirt -ref /home/yfang/data/spgr_unstrip.nii -in /home/yfang/data/test_now_T2.nii -applyxfm     -out /home/yfang/data/flirt_out_T2 -init /home/yfang/data/flirt_mat.mat"');
%     elseif idx == 3
%         system('bash --login -c "flirt -ref /home/yfang/data/spgr_unstrip.nii -in /home/yfang/data/test_now_FLAIR.nii -applyxfm  -out /home/yfang/data/flirt_out_FLAIR -init /home/yfang/data/flirt_mat.mat"');
%     else
%         system('bash --login -c "flirt -ref /home/yfang/data/spgr_unstrip.nii -in /home/yfang/data/test_now_mask.nii -applyxfm  -out /home/yfang/data/flirt_out_mask -init /home/yfang/data/flirt_mat.mat"');
%     end
% end
% 
% toc
% %%
% system('bash -c "cp /home/yfang/data/flirt_out_T1.nii.gz /mnt/c/temp/"');
% 
% system('bash -c "cp /home/yfang/data/flirt_out_T1post.nii.gz /mnt/c/temp/"');
% system('bash -c "cp /home/yfang/data/flirt_out_T2.nii.gz     /mnt/c/temp/"');
% system('bash -c "cp /home/yfang/data/flirt_out_FLAIR.nii.gz /mnt/c/temp/"');
% system('bash -c "cp /home/yfang/data/flirt_out_mask.nii.gz /mnt/c/temp/"');
% 
% %% Brain extraction. bet is also a function in FSL
% system('bash --login -c "/usr/local/fsl/bin/bet /home/yfang/data/flirt_out_T1.nii.gz /home/yfang/data/bet_out -f 0.5 -g 0 -s -R"');
% system('bash -c "cp /home/yfang/data/bet_out.nii.gz /mnt/c/temp/"');
% gunzip('bet_out.nii.gz');
% 
% bet_out_T1=niftiread('bet_out.nii');
% ref_img=niftiread('spgr.nii');
% mask1 = (bet_out_T1>0).*(ref_img>0); mask1 = imfill(mask1, 'holes');
% 
% img_MR(:,:,:,1) = bet_out_T1.*mask1;
% 
% 
% %%
% V = niftiread('flirt_out_T1post.nii.gz');img_MR(:,:,:,2) = V.*mask1;
% V = niftiread('flirt_out_T2.nii.gz');img_MR(:,:,:,3) = V.*mask1;
% V = niftiread('flirt_out_FLAIR.nii.gz');img_MR(:,:,:,4) = V.*mask1;

% T1_mask = niftiread('C:\temp\flirt_out_mask.nii.gz'); T1_mask = T1_mask>max(T1_mask(:))*0.7;
load img_MR
%% do the segmentation now
[out1 labeled] = MR_brain_tumor_seg_function(img_MR, 'trained3DUNetValid-18-Jan-2021-17-15-47-Epoch-1');%
