
close all
clc

run('vlfeat-0.9.21/toolbox/vl_setup');

img_n = 2;
in_name = cell(img_n,1);
in_name{1} = 'images/temple_01.jpg';
in_name{2} = 'images/temple_02.jpg';

% Each row represents an image pair to be aligned.
% In this example, there is only one pair (image 1 and image 2).
edge_list = [1,2];

% The index of the reference image.
ref = 2;
% The index of the target image. Our warp is constructed from the homgraphy that maps from ref to tar.
tar = 1;
% 'ours' for our warp. 'hom' for homography warp.
warp_type = 'ours';
% Whether we restrict the similarity warp in our warp to be no rotation (zeroR_ON=1) or not (zeroR_ON=0).
zeroR_ON = 1;

SPHP_stitching(in_name, edge_list, ref, tar, warp_type, zeroR_ON);