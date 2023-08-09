
close all
clc
clear

run('vlfeat-0.9.21/toolbox/vl_setup');

img_n = 2;
in_name = cell(img_n,1);
in_name{1} = 'images/temple_01.jpg';
in_name{2} = 'images/temple_02.jpg';

% Each row represents an image pair to be aligned.
% In this example, there is only one pair (image 1 and image 2).
edge_list = [2,1];

% The index of the reference image.
ref = 1;
% The index of the target image. Our warp is constructed from the homgraphy that maps from ref to tar.
tar = 2;
% 'ours' for our warp. 'hom' for homography warp.
warp_type = 'ours';
% Whether we restrict the similarity warp in our warp to be no rotation (zeroR_ON=1) or not (zeroR_ON=0).
zeroR_ON = 1;

% Preprocessing: downscaling images if needed.
max_size = 1000 * 1000;
needs_resizing = cell(img_n, 1);
for i = 1 : img_n
    I = imread(in_name{i});
    needs_resizing{i} = numel(I(:, :, 1)) > max_size;
    if needs_resizing{i}  % downsample
        in_name{i} = sprintf('%s_resized%s', in_name{i}(1:end-4), in_name{i}(end-3:end));
        imwrite(imresize(I, sqrt(max_size / numel(I(:, :, 1)))), in_name{i});
    end
end

% Perfom the actual SPHP stitching.
SPHP_stitching(in_name, edge_list, ref, tar, warp_type, zeroR_ON);

% Cleanup downscaled images.
for i = 1 : img_n
    if needs_resizing{i}
        eval(['delete ' in_name{i}]);
    end
end