
close all
clc
clear

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

% We use a pre-computed homography here.
cachedH = cell(1, 1);
cachedH{1,1} = [0.56965387 -0.04795213  366.57816; ...
               -0.08731978  0.87915248  21.069869; ...
               -0.00057594 -0.00003427  1.0000000];
H = preprocess_matrix(in_name, edge_list, ref, tar, cachedH);
[c1out, c1omask] = SPHP_warp(in_name, 2, H, ref, tar, warp_type, zeroR_ON);

% Writing images to results.
for i = 1 : img_n
    new_name = sprintf('%sresult%s', in_name{i}(1:end-4), in_name{i}(end-3:end));
    imwrite(c1out{i}, new_name);
end