function [c1out, c1omask] = SPHP_warp(in_name, img_n, H, ref, tar, warp_type, zeroR_ON)

%% prepare images
I = cell(img_n, 1);
imgw = zeros(img_n, 1);
imgh = zeros(img_n, 1);
T = cell(img_n, 1);
for i = 1 : img_n
    tmp_imp = imread(in_name{i});
    imgw(i) = size(tmp_imp, 2);
    imgh(i) = size(tmp_imp, 1);
    T{i} = [1  0 -(imgw(i)+1)/2; ...
            0 -1  (imgh(i)+1)/2; ...
            0  0  1];
end

%% let H0 be the homography from reference to target, extract its parameters for computing our warp
H0 = H{tar, ref};
A = H0(1:2, 1:2);
t = H0(1:2, 3);
h31 = H0(3, 1);
h32 = H0(3, 2);
B = A - t*[h31 h32];
c = sqrt(h31^2+h32^2);
theta = atan2(-h32, -h31); % for compute ub1 and ub2

%% compute ub1 and ub2
% compute cu
cu = zeros(img_n, 1);
for i = 1 : img_n
    [tmpx, tmpy] = apply_transform(0, 0, H{ref, i}); % transform center (0, 0) of ith img to ref img
    [cu(i), ~] = apply_transform(tmpx, tmpy, [cos(theta), sin(theta), 0; ...
                                             -sin(theta), cos(theta), 0; ...
                                                       0,          0, 1]);
end
oriub1 = min(cu);
oriub2 = max(cu);
% ub1 = oriub1; ub2 = oriub2;

s_itv = 20; % sample interval
[offset_table1, offset_table2] = meshgrid(-300:10:600, -300:10:200);
totalcost_table = zeros(size(offset_table1));
for oi = 1 : size(offset_table1, 1)
for oj = 1 : size(offset_table1, 2)
    ub1 = oriub1 + offset_table1(oi, oj);
    ub2 = oriub2 + offset_table2(oi, oj);
    if ub2 - ub1 < 120
        totalcost_table(oi, oj) = nan;
        continue;
    end
    c1para = compute_c1_warp_coeff(H0, t, c, theta, ub1, ub2, zeroR_ON);
    
    % Jacobian of each image
    invR = [cos(theta), sin(theta), 0; ...
           -sin(theta), cos(theta), 0; ...
                     0,          0, 1];
    cost_list = zeros(1, img_n);
    for i = 1 : img_n
        x = linspace(1, imgw(i), ceil(imgw(i)/s_itv));
        y = linspace(1, imgh(i), ceil(imgh(i)/s_itv));
        [x, y] = meshgrid(x, y);
        [x, y] = apply_transform(x, y, T{i}); % coord change
        tmpH = invR * H{ref, i}; % tmpH maps (x,y) in ith img to (u,v) in ref img
        [u, v] = apply_transform(x, y, tmpH);
        reg1_mask = u < ub1;
        reg2_mask = u > ub1 & u < ub2;
        reg3_mask = u > ub2;

        J11_map = zeros(size(x));
        J12_map = zeros(size(x));
        J21_map = zeros(size(x));
        J22_map = zeros(size(x));
        for reg = 1 : 3 % for each region
            if reg == 1,        reg_mask = u < ub1;
            elseif reg == 3,    reg_mask = u > ub2;
            else                reg_mask = ~(u < ub1 | u > ub2);
            end
            if nnz(reg_mask) == 0, continue; end
            x1 = x(reg_mask);
            y1 = y(reg_mask);
            u1 = u(reg_mask);
            v1 = v(reg_mask);

            if reg == 1 % region 1
                A = c1para.H * H{ref, i};
            elseif reg == 2 % region 2
                A = tmpH; % as described above
            elseif reg == 3 % region 3
                A = c1para.S * H{ref, i};
            end
            A = A / A(3, 3);
            h1 = A(1, 1); h2 = A(1, 2); h3 = A(1, 3); h4 = A(2, 1); h5 = A(2, 2); h6 = A(2, 3); h7 = A(3, 1); h8 = A(3, 2);

            J11 = h1./(h7*x1 + h8*y1 + 1) - (h7*(h3 + h1*x1 + h2*y1))./(h7*x1 + h8*y1 + 1).^2;  J12 = h2./(h7*x1 + h8*y1 + 1) - (h8*(h3 + h1*x1 + h2*y1))./(h7*x1 + h8*y1 + 1).^2;
            J21 = h4./(h7*x1 + h8*y1 + 1) - (h7*(h6 + h4*x1 + h5*y1))./(h7*x1 + h8*y1 + 1).^2;  J22 = h5./(h7*x1 + h8*y1 + 1) - (h8*(h6 + h4*x1 + h5*y1))./(h7*x1 + h8*y1 + 1).^2;
            if reg == 2
                if c1para.zeroR_ON == 0
                    JT11 = (2*c1para.a(1)*u1 + c1para.a(2)) .* v1 + (2*c1para.b(1)*u1 + c1para.b(2));
                    JT12 = c1para.a(1)*u1.^2 + c1para.a(2)*u1 + c1para.a(3);
                    JT21 = (2*c1para.e(1)*u1 + c1para.e(2)) .* v1 + (2*c1para.f(1)*u1 + c1para.f(2));
                    JT22 = c1para.e(1)*u1.^2 + c1para.e(2)*u1 + c1para.e(3);
                else
                    JT11 = (3*c1para.a(1)*u1.^2 + 2*c1para.a(2)*u1 + c1para.a(3)) .* v1 + (2*c1para.b(1)*u1 + c1para.b(2));
                    JT12 = c1para.a(1)*u1.^3 + c1para.a(2)*u1.^2 + c1para.a(3)*u1 + c1para.a(4);
                    JT21 = (3*c1para.e(1)*u1.^2 + 2*c1para.e(2)*u1 + c1para.e(3)) .* v1 + (2*c1para.f(1)*u1 + c1para.f(2));
                    JT22 = c1para.e(1)*u1.^3 + c1para.e(2)*u1.^2 + c1para.e(3)*u1 + c1para.e(4);
                end
                tmp11 = JT11.*J11 + JT12.*J21;
                tmp12 = JT11.*J12 + JT12.*J22;
                tmp21 = JT21.*J11 + JT22.*J21;
                tmp22 = JT21.*J12 + JT22.*J22;
                J11 = tmp11; J12 = tmp12; J21 = tmp21; J22 = tmp22;
            end
            J11_map(reg_mask) = J11;
            J12_map(reg_mask) = J12;
            J21_map(reg_mask) = J21;
            J22_map(reg_mask) = J22;
        end
        % As-GlobalSimilar-As-Possible cost
        avg_alpha = (sum(J11_map(:)) + sum(J22_map(:))) / (numel(x)*2);
        avg_beta = (sum(J21_map(:)) + (-sum(J12_map(:)))) / (numel(x)*2);
        cost = sum( (J11_map(:)-avg_alpha).^2 + (J12_map(:)-(-avg_beta)).^2 + ...
                    (J21_map(:)-avg_beta).^2  + (J22_map(:)-avg_alpha).^2 );
        % done
        cost_list(i) = cost;
    end
    totalcost = sum(cost_list);
    totalcost_table(oi, oj) = totalcost;
end
end
[idx1,idx2] = find(totalcost_table==min(totalcost_table(:)));
ub1 = oriub1 + offset_table1(idx1, idx2);
ub2 = oriub2 + offset_table2(idx1, idx2);

%% compute parameters/coefficients of our warp
c1para = compute_c1_warp_coeff(H0, t, c, theta, ub1, ub2, zeroR_ON);

%% c1 warp for each image
img_grid_size = 10; % for warping
mdltpara = [];
[c1out, c1omask, ~] = texture_mapping(in_name, imgw, imgh, img_grid_size, T, warp_type, H, ref, tar, c1para, mdltpara, 0, 'white');