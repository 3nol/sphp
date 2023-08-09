function [c1out, c1omask] = SPHP_stereo_warp(in_name1, in_name2, H0, zeroR_ON)

% Number images, 2 in the stereo case.
img_n = 2;

% Cell of all input image names.
in_name = cell(img_n, 1);
in_name{1} = in_name1;
in_name{2} = in_name2;

% Each row represents an image pair to be aligned.
% In this example, there is only one pair (image 1 and image 2).
edge_list = [2,1];

% The index of the reference image.
ref = 1;
% The index of the target image. Our warp is constructed from the homgraphy that maps from ref to tar.
tar = 2;
% 'ours' for our warp. 'hom' for homography warp.
warp_type = 'ours';

cachedH = cell(1, 1);
cachedH{1,1} = reshape(double(H0), 3, 3);
H = preprocess_matrix(in_name, edge_list, ref, tar, cachedH);

[c1out, c1omask] = SPHP_warp(in_name, img_n, H, ref, tar, warp_type, zeroR_ON);

% Writing first image and mask.
imwrite(c1out{1}, sprintf('%s_warped%s', in_name1(1:end-4), in_name1(end-3:end)));
imwrite(c1omask{1}, sprintf('%s_mask%s', in_name1(1:end-4), in_name1(end-3:end)));

% Writing second image and mask.
imwrite(c1out{2}, sprintf('%s_warped%s', in_name2(1:end-4), in_name2(end-3:end)));
imwrite(c1omask{2}, sprintf('%s_mask%s', in_name2(1:end-4), in_name2(end-3:end)));