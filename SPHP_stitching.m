function SPHP_stitching(in_name, edge_list, ref, tar, warp_type, zeroR_ON)

img_n = size(in_name, 1);
edge_n = size(edge_list, 1);

% check
for ei = 1 : edge_n
    i = edge_list(ei, 1);
    j = edge_list(ei, 2);
    if i == j, fprintf('Index pair error.\n'); pause; end
end

% load
I = cell(img_n, 1);
for i = 1 : img_n
    I{i} = imread(in_name{i});
end
% preprocessing
% T{i} is the coordinate transform of image i that change from the image
% coordinate (origin at the upper-left corner of the image, x towards right, y towards down) to
% the standard coordinate (origin at the center of the image, x towards
% right, y towards up)
max_size = 1000 * 1000;
imgw = zeros(img_n, 1);
imgh = zeros(img_n, 1);
resized_in_name = cell(img_n, 1);
T = cell(img_n, 1);
for i = 1 : img_n
    if numel(I{i}(:, :, 1)) > max_size % downsample
        I{i} = imresize(I{i}, sqrt(max_size / numel(I{i}(:, :, 1))));
    end
    resized_in_name{i} = sprintf('%s_resized%s', in_name{i}(1:end-4), in_name{i}(end-3:end));
    imwrite(I{i}, resized_in_name{i});
    imgw(i) = size(I{i}, 2);
    imgh(i) = size(I{i}, 1);
    T{i} = [1  0 -(imgw(i)+1)/2; ...
            0 -1  (imgh(i)+1)/2; ...
            0  0  1];
end
for i = 1 : img_n
    I{i} = im2double(I{i});
end

%% compute homography of image pairs
H = cell(img_n, img_n); % H{i,j} is the transformation from I{j} to I{i} (using standard coordinates)
for i = 1 : img_n
    H{i, i} = eye(3);
end
for ei = 1 : edge_n
    i = edge_list(ei, 1);
    j = edge_list(ei, 2);
    tmpH = sift_mosaic(I{i}, I{j}); % tmpH is the transform from I{i} to I{j} (using image coordinates)
    H{j, i} = T{j} * tmpH * inv(T{i}); % change of coord.
    H{i, j} = inv(H{j, i});
end

%% for every image I, compute the homography between I and I_ref, and the homo. between I and I_target
% construct graph
G = sparse([edge_list(:, 1); edge_list(:, 2)], ...
           [edge_list(:, 2); edge_list(:, 1)], ...
           [ones(edge_n, 1); ones(edge_n, 1)], img_n, img_n); % construct a graph represented by a sparse mat
% compute homography between ith img and REFERENCE img
for i = 1 : img_n
    if i == ref, continue; end
    [~, path, ~] = graphshortestpath(G, i, ref); % path from ith img to ref img
    tmpH = eye(3);
    for ppi = 1 : numel(path)-1
        tmpH = H{path(ppi+1), path(ppi)} * tmpH;
    end
    H{ref, i} = tmpH;
    H{i, ref} = inv(H{ref, i});
end
% compute homography between ith img and TARGET img
for i = 1 : img_n
    if i == tar, continue; end
    [~, path, ~] = graphshortestpath(G, i, tar); % path from ith img to tar img
    tmpH = eye(3);
    for ppi = 1 : numel(path)-1
        tmpH = H{path(ppi+1), path(ppi)} * tmpH;
    end
    H{tar, i} = tmpH;
    H{i, tar} = inv(H{tar, i});
end
% normalize all homography s.t. h9 = 1
for hi = 1 : numel(H)
    if H{hi}
        H{hi} = H{hi} / H{hi}(3, 3);
    end
end

% use the found homography to warp the images and delete intermediate results
[c1out, c1omask] = SPHP_warp(resized_in_name, img_n, H, ref, tar, warp_type, zeroR_ON);
for i = 1 : img_n
    eval(['delete ' resized_in_name{i}]);
end

% apply linear blending and write-out result
c1all = linear_blending(c1out, c1omask);
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