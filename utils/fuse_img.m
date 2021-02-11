function imgtemp = fuse_img(img1, img2, contouridx)
mask = edge(img2);
p = bwpack(mask);% bold the contour
mask_dilated = imdilate(p,ones(3,3),'ispacked');
mask = bwunpack(mask_dilated, size(mask,1));
mask(mask>0.5) = 1;
%map1 = colormap('gray');
%imgtemp = ind2rgb(gray2ind(img1/max(img1(:)), 256), map1);
%imgtemp1 = imgtemp(:,:,2);
%imgtemp1(mask) = 1;
if contouridx ==1
    x = 1;y = 0.5;z=1;
elseif contouridx ==2
    x = 0;y = 0;z=1;
elseif contouridx ==3
    x = 1;y = 1;z=0;
elseif contouridx ==4
    x = 1;y = 0;z=0;
elseif contouridx ==5
    x = 1;y = 0;z=1;
end
imgtemp1 = img1(:,:,1); %green
imgtemp1(mask) = x;
img1(:,:,1) = imgtemp1;
imgtemp1 = img1(:,:,2); %red
imgtemp1(mask) = y;
img1(:,:,2) = imgtemp1; 
imgtemp1 = img1(:,:,3); %blue
imgtemp1(mask) = z;
img1(:,:,3) = imgtemp1;

%imgtemp(:,:,2) = imgtemp1;
%imgtemp1 = imgtemp(:,:,1);
%imgtemp1(mask) = 0;
% imgtemp1 = img1(:,:,3); %blue
% imgtemp1(mask) = 0;
% img1(:,:,3) = imgtemp1;
imgtemp = img1;
%imgtemp(:,:,1) = imgtemp1;
%imgtemp1 = imgtemp(:,:,3);
%imgtemp1(mask) = 0;
%imgtemp(:,:,3) = imgtemp1;
return;