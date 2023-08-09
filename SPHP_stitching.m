function SPHP_stitching(in_name, edge_list, ref, tar, warp_type, zeroR_ON)

img_n = size(in_name, 1);
H = preprocess_matrix(in_name, edge_list, ref, tar, []);
% use the found homography to warp the images and delete intermediate results
[c1out, c1omask] = SPHP_warp(in_name, img_n, H, ref, tar, warp_type, zeroR_ON);

% apply linear blending and write-out result
c1all = linear_blending(c1out, c1omask, img_n);
denom = zeros(size(c1out{1}));
for i = 1 : img_n
    denom = denom + c1omask{i};
end
bgcolor = 'white'; % background color
if strcmp(bgcolor, 'white')
    c1all(denom==0) = 1;
else
    c1all(denom==0) = 0;
end
rename = sprintf('%sresult%s', in_name{1}(1:end-4), in_name{1}(end-3:end));
imwrite(c1all, rename);