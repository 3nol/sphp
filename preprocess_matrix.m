function [H] = preprocess_matrix(in_name, edge_list, ref, tar, cachedH)

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
imgw = zeros(img_n, 1);
imgh = zeros(img_n, 1);
T = cell(img_n, 1);
for i = 1 : img_n
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
     % tmpH is the transform from I{i} to I{j} (using image coordinates)
    if ~exist('cachedH','var') || isempty(cachedH)
        tmpH = sift_mosaic(im2double(I{i}), im2double(I{j}));
    else
        tmpH = cachedH{ei};
    end
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
    path = shortestpath(digraph(G), i, ref); % path from ith img to ref img
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
    path = shortestpath(digraph(G), i, tar); % path from ith img to tar img
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