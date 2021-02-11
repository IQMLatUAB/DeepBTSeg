function out = channelWisePreProcess(in)
rangeMin = -5;
rangeMax = 5;
% 
% out(out > rangeMax) = rangeMax;
% out(out < rangeMin) = rangeMin;
% 
% % Rescale the data to the range [0, 1].
% out = (out - rangeMin) / (rangeMax - rangeMin);
out = in;
for idx1 = 1:size(out,4)
    temp1 = out(:,:,:,idx1);
    mask1 = temp1>0;
    temp_mean = mean(temp1(find(mask1==1)));
    temp_sd = std(temp1(find(mask1==1)));
    temp1 = (temp1-temp_mean)/temp_sd;
    temp1(temp1 > rangeMax) = rangeMax;
    temp1(temp1 < rangeMin) = rangeMin;
    temp_min = min(temp1(find(mask1==1)));
    temp_max = max(temp1(find(mask1==1)));
    temp1 = (temp1-temp_min)/(temp_max-temp_min)*0.95+0.05;
    %temp1 = (temp1-temp_min)/(temp_max-temp_min)*0.9+0.1;
    temp1(find(mask1~=1)) = 0;
    out(:,:,:,idx1) = temp1;
end

% % As input has 4 channels (modalities), remove the mean and divide by the
% % standard deviation of each modality independently.
% chn_Mean = mean(in,[1 2 3]);
% chn_Std = std(in,0,[1 2 3]);
% out = (in - chn_Mean)./chn_Std;
% 
% rangeMin = -5;
% rangeMax = 4;
% 
% out(out > rangeMax) = rangeMax;
% out(out < rangeMin) = rangeMin;
% 
% %rangeMax = max(out(:))*0.95;
% % Rescale the data to the range [0, 1].
% out = (out - rangeMin) / (rangeMax - rangeMin);
% %out = (out - min(out(:))) / (max(out(:)) - min(out(:)));
end