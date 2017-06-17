% make some parameters
params = makeGBVSParams;

% could change params like this
params.contrastwidth = .11;

% calling gbvs() with default params and then displaying result
outW = 1024;

saliency_percent = 85;

% compute saliency maps for some images
  img_min   = imread(sprintf('1_min.jpg'));
  img_max  = imread(sprintf('1_max.jpg'));
  
  tic; 

% this is how you call gbvs
% leaving out params reset them to all default values (from
% algsrc/makeGBVSParams.m)
  out = gbvs( img_min );   
    
  toc;

% show result in a pretty way
  s = outW / size(img_max,2) ; 
  sz = size(img_max); sz = sz(1:2);
  sz = round( sz * s );
  img_max = imresize( img_max , sz , 'bicubic' );  
  saliency_map = imresize( out.master_map , sz , 'bicubic' );
  img_max = double(img_max) / 255;
  img_thresholded = img_max .* repmat( saliency_map >= prctile(saliency_map(:),saliency_percent) , [ 1 1 size(img_max,3) ] );  
  


  imwrite(img_thresholded,'saliency.jpg');
  fprintf(1,'Search saliency map completed!!! \n');


img_maxi = img_thresholded;

  %{
imshow(img_maxi)
figure, imshow(img_min)

% interactively
[sub_img_maxi,rect_img_maxi] = imcrop(img_maxi); % choose the pepper below the img_max
[sub_img_min,rect_img_min] = imcrop(img_min); % choose the whole img_max

% display sub images
figure, imshow(sub_img_maxi)
figure, imshow(sub_img_min)

%tic; 
c = normxcorr2(sub_img_maxi(:,:,1),sub_img_min(:,:,1));
figure, surf(c), shading flat

% offset found by correlation
[max_c, imax] = max(abs(c(:)));
[ypeak, xpeak] = ind2sub(size(c),imax(1));
corr_offset = [(xpeak-size(sub_img_maxi,2))
               (ypeak-size(sub_img_maxi,1))];

% relative offset of position of subimages
rect_offset = [(rect_img_min(1)-rect_img_maxi(1))
               (rect_img_min(2)-rect_img_maxi(2))];

% total offset
offset = corr_offset + rect_offset;
xoffset = offset(1);
yoffset = offset(2);

xbegin = round(xoffset+1);
xend   = round(xoffset+ size(img_maxi,2));
ybegin = round(yoffset+1);
yend   = round(yoffset+size(img_maxi,1));

% extract region from img_min and compare to img_max
extracted_img_maxi = img_min(ybegin:yend,xbegin:xend,:);
if isequal(img_max,extracted_img_maxi)
   disp('img_maxi.png was extracted from img_min.png')
end

recovered_img_maxi = uint8(zeros(size(img_min)));
recovered_img_maxi(ybegin:yend,xbegin:xend,:) = img_maxi;
%}
img_min = double(img_min) / 255;
  
f=wfusimg(img_thresholded,img_min,'bior5.5',1,'max','max');
figure, imshow(f)
imwrite(f,'saliency_fusion.jpg');

f=wfusimg(img_max, img_min,'bior5.5',1,'max','max');
figure, imshow(f)
imwrite(f,'fusion.jpg');


  figure;
  subplot(2,2,1);
  imshow(img_max);
  title('original image');
    
  subplot(2,2,2);
  imshow(saliency_map);
  title('GBVS map');
  
  subplot(2,2,3);
  imshow(img_thresholded);
  title('most salient (75%ile) parts');
  
  subplot(2,2,4);
  imshow(f);
  title('saliency map overlayed');

toc;