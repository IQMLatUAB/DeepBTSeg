function [mask1 predictedLabels] = MR_brain_tumor_seg_function(image_MR2, net_filename)
load(net_filename);


if ~exist('inputPatchSize')
    inputPatchSize = [132 132 132 2];
    outPatchSize = [44 44 44 2];
end

inputPatchSize = [132 132 132 4];
    outPatchSize = [44 44 44 4];
%%
clear vol;
vol{1} = channelWisePreProcess(image_MR2);
vol{1}(image_MR2==0) = 0;
classNames = ["background","NET","edema","enhancingtumor"];
pixelLabelID = [0 1 2 4];
%classNames = ["background","NET","enhancingtumor"];
%pixelLabelID = [0 1 2];
% Use reflection padding for the test image.
% Avoid padding of different modalities.
id = 1;
volSize = size(vol{id},(1:3));
padSizePre  = (inputPatchSize(1:3)-outPatchSize(1:3))/2;
padSizePost = (inputPatchSize(1:3)-outPatchSize(1:3))/2 + (outPatchSize(1:3)-mod(volSize,outPatchSize(1:3)));
volPaddedPre = padarray(vol{id},padSizePre,'symmetric','pre');
volPadded = padarray(volPaddedPre,padSizePost,'symmetric','post');
[heightPad,widthPad,depthPad,~] = size(volPadded);
[height,width,depth,~] = size(vol{id});

tempSeg = categorical(zeros([height,width,depth],'uint8'),[0;1;2;4],classNames);
%tempSeg = categorical(zeros([height,width,depth],'uint8'),[0;1;2],classNames);
% Overlap-tile strategy for segmentation of volumes.
for k = 1:outPatchSize(3):depthPad-inputPatchSize(3)+1
    for j = 1:outPatchSize(2):widthPad-inputPatchSize(2)+1
        for i = 1:outPatchSize(1):heightPad-inputPatchSize(1)+1
            patch = volPadded( i:i+inputPatchSize(1)-1,...
                j:j+inputPatchSize(2)-1,...
                k:k+inputPatchSize(3)-1,:);
            patchSeg = semanticseg(patch,net);
            tempSeg(i:i+outPatchSize(1)-1, ...
                j:j+outPatchSize(2)-1, ...
                k:k+outPatchSize(3)-1) = patchSeg;
        end
    end
end

% Crop out the extra padded region.
tempSeg = tempSeg(1:height,1:width,1:depth);

% Save the predicted volume result.
predictedLabels{id} = tempSeg;

mask1 = double(predictedLabels{1}=='NET') + double(predictedLabels{1}=='edema')*2 + double(predictedLabels{1}=='enhancingtumor')*3;

display('Segmentation successful!');

return;
% image_MR_vol = vol{1};
% 
% 
% w_analyze(pwd,'Mask_segment.hdr', mask1, 16, size(mask1),StandardVOX);
% matlabbatch{1}.spm.util.defs.ofname = '';
% matlabbatch{1}.spm.util.defs.fnames = {
%     'Mask_segment.img,1'      
%     };
% matlabbatch{1}.spm.util.defs.interp = 1;
% 
% temp1 = {};
% temp1{1} = warp_file;
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = temp1;
% 
% temp1 = {};
% in_file = fullfile(tempdir, 'ResliceFile.img');
% temp1{1} = in_file;
% matlabbatch{1}.spm.util.defs.comp{1}.inv.space = temp1;
% 
% spm_jobman('initcfg')
% spm('defaults', 'FMRI');
% spm_jobman('serial', matlabbatch);
% 
% %[ima, DIM,VOX_S,VolAux.SCALE,VolAux.TYPE,VolAux.OFFSET,VolAux.ORIGIN,VolAux.DESCRIP]=r_analyze('wMask_cortex1.hdr');
% temp1 = load_nii('wMask_segment.hdr');
% %v1 = flip(temp1.img, 1);
% v1 = temp1.img;
% v1(find(isnan(v1)))=0;
% v1(v1>0.7) = 1;
% v1(v1<=0.7) = 0;
% mask_final = v1==1;
% %%
% mask_final = mask1;
% clear vec1;
% for idx =  1:size(mask_final,3)
%     vec1(idx) = sum(sum(mask_final(:,:,idx)));
% end
% [dum max_i] = max(vec1);
% % show the results of overall tumor segmentation
% figure
% for idx = 1:4
%     subplot(2,2,idx)
%     imgtemp = fuse_img(image_MR2(:,:,max_i,idx), mask_final(:,:,max_i));
%     imagesc(imgtemp);axis off;
% end
% %%
% return;
% stop
% %% do the FLAIR hyper-intensity extraction
% mask2 = post_process3(image_MR_vol(:,:,:,4), mask1);
% 
% figure
% for idx = 1:4
%     subplot(2,2,idx)
%     imgtemp = fuse_img(image_MR_vol(:,:,max_i,idx), mask2(:,:,max_i));
%     imagesc(imgtemp);axis off;
% end
% 
% %% From the FLAIR voxels, do T1 post extraction
% mask3 = post_process4(image_MR_vol(:,:,:,2), mask2);
% 
% figure
% for idx = 1:4
%     subplot(2,2,idx)
%     imgtemp = fuse_img(image_MR_vol(:,:,max_i,idx), mask3(:,:,max_i));
%     imagesc(imgtemp);axis off;
% end
% 
% save(['test_sub' num2str(sub_idx) '.mat'],'mask2','mask3','-append');
% 
% stop
% %%
% temp1 = sum(mipdim(mask2,1));
% slices_to_use = find(temp1>0);
% 
% 
% load trained3DUNetValid-23-Jun-2020-15-48-47-Epoch-3;
% clear vol;
% vol{1} = channelWisePreProcess(image_MR2(:,:,slices_to_use,:));
% %vol{1}(image_MR2==0) = 0;
% % Use reflection padding for the test image.
% % Avoid padding of different modalities.
% volSize = size(vol{id},(1:3));
% padSizePre  = (inputPatchSize(1:3)-outPatchSize(1:3))/2;
% padSizePost = (inputPatchSize(1:3)-outPatchSize(1:3))/2 + (outPatchSize(1:3)-mod(volSize,outPatchSize(1:3)));
% volPaddedPre = padarray(vol{id},padSizePre,'symmetric','pre');
% volPadded = padarray(volPaddedPre,padSizePost,'symmetric','post');
% [heightPad,widthPad,depthPad,~] = size(volPadded);
% [height,width,depth,~] = size(vol{id});
% 
% tempSeg = categorical(zeros([height,width,depth],'uint8'),[0;1],classNames);
% 
% % Overlap-tile strategy for segmentation of volumes.
% for k = 1:outPatchSize(3):depthPad-inputPatchSize(3)+1
%     for j = 1:outPatchSize(2):widthPad-inputPatchSize(2)+1
%         for i = 1:outPatchSize(1):heightPad-inputPatchSize(1)+1
%             patch = volPadded( i:i+inputPatchSize(1)-1,...
%                 j:j+inputPatchSize(2)-1,...
%                 k:k+inputPatchSize(3)-1,:);
%             patchSeg = semanticseg(patch,net);
%             tempSeg(i:i+outPatchSize(1)-1, ...
%                 j:j+outPatchSize(2)-1, ...
%                 k:k+outPatchSize(3)-1) = patchSeg;
%         end
%     end
% end
% 
% % Crop out the extra padded region.
% tempSeg = tempSeg(1:height,1:width,1:depth);
% 
% % Save the predicted volume result.
% predictedLabels{id} = tempSeg;
% 
% %end
% figure
% imagesc(predictedLabels{1}(:,:,10)=='tumor');
% 
% mask1 = predictedLabels{1}=='tumor';
% 
% display('Done!');
% 
% %%
% clear vec1;
% for idx =  1:size(mask1,3)
%     vec1(idx) = sum(sum(mask1(:,:,idx)));
% end
% [dum max_i] = max(vec1);
% figure
% for idx = 1:4
%     subplot(2,2,idx)
%     imgtemp = fuse_img(image_MR_vol(:,:,max_i,idx), mask1(:,:,max_i));
%     imagesc(imgtemp);axis off;
% end
% 
% 
% % %%
% % mask2 = post_process3(image_MR_vol(:,:,:,1), mask1);
% % mask4 = post_process(image_MR_vol(:,:,:,3), mask1);
% % 
% % figure
% % for idx = 1:4
% %     subplot(2,2,idx)
% %     imgtemp = fuse_img(image_MR_vol(:,:,max_i,idx), mask4(:,:,max_i));
% %     imagesc(imgtemp);axis off;
% % end
% % %%
% % mask3 = post_process2(image_MR_vol(:,:,:,3), mask2);
% % figure
% % for idx = 1:4
% %     subplot(2,2,idx)
% %     imgtemp = fuse_img(image_MR_vol(:,:,max_i,idx), mask3(:,:,max_i));
% %     imagesc(imgtemp);axis off;
% % end
% 
% %for idx = 5:8
% %     subplot(2,4,idx)
% %     imgtemp = fuse_img(image_MR_vol(:,:,10,idx-4), image_mask_tumor(:,:,10));
% %     imagesc(imgtemp);axis off;
% % end
% % image_mask_tumor;
% 
% stop
% %%
% image_MR_vol = vol{1};
% figure
% for idx = 1:4
%     subplot(2,2,idx)
%     imgtemp = fuse_img(image_MR_vol(:,:,75,idx), mask1(:,:,75));
%     imagesc(imgtemp);axis off;
% end
% stop
% 
% %%
% figure
% for idx = 1:30
%     subplot(5,6,idx)
%     imgtemp = fuse_img(image_MR(:,:,idx,4), mask_final(:,:,idx));
%     imagesc(imgtemp);axis off;
% end
% %%
% figure
% for idx = 101:140
%     subplot(5,8,idx-100)
%     imgtemp = fuse_img(image_MR(:,:,idx,4), mask1(:,:,idx));
%     imagesc(imgtemp);axis off;
% end
% %%
% figure
% for idx = 1:75
%     subplot(5,15,idx)
%     imgtemp = fuse_img(image_MR(:,:,idx,4), mask1(:,:,idx));
%     imagesc(imgtemp);axis off;
% end
% 
% %load C:\Work\MR_Brain\checkpoint\net_checkpoint__8820__2020_07_09__14_20_08 net;
% %net = layerGraph(net);
% %load trained3DUNetValid-09-Jul-2020-16-00-52-Epoch-1;
% % %%
% % volId = 1;
% % vol3d = vol{volId}(:,:,:,1);
% % zID = size(vol3d,3)/2;
% % zSliceGT = labeloverlay(vol3d(:,:,zID),groundTruthLabels{volId}(:,:,zID));
% % zSlicePred = labeloverlay(vol3d(:,:,zID),predictedLabels{volId}(:,:,zID));
% %
% % figure
% % montage({zSliceGT,zSlicePred},'Size',[1 2],'BorderSize',5)
% % title('Labeled Ground Truth (Left) vs. Network Prediction (Right)')
% %
% % %%
% % viewPnlTruth = uipanel(figure,'Title','Ground-Truth Labeled Volume');
% % hTruth = labelvolshow(groundTruthLabels{volId},vol3d,'Parent',viewPnlTruth, ...
% %     'LabelColor',[0 0 0;1 0 0],'VolumeThreshold',0.68);
% % hTruth.LabelVisibility(1) = 0;
% %
% % viewPnlPred = uipanel(figure,'Title','Predicted Labeled Volume');
% % hPred = labelvolshow(predictedLabels{volId},vol3d,'Parent',viewPnlPred, ...
% %     'LabelColor',[0 0 0;1 0 0],'VolumeThreshold',0.68);
% % hPred.LabelVisibility(1) = 0;