% 定义你的数据点
x = [0,10,20,30,40,50,60,70,80,90,100,110,120,150,180,210,240]; % 替换为你的x数据
y = [36.0,32.8,29.4,26.0,22.9,21.8,21.0,20.5,20.3,20.1,20.0,20.0,20.1,20.1,20.1,20.2,20.2]; % 替换为你的y数据



% 生成更多的x值用于插值
xq = linspace(min(x), max(x), 1000); % 生成1000个点

% 使用'spline'方法进行插值
yq = interp1(x, y, xq, 'spline');

% 找到曲线与直线y=25.3的交点
y_intercept = 25.3;
x_intercepts = xq(abs(yq - y_intercept) < 0.01); % 找到yq值接近25.3的xq值
y_intercepts = y_intercept * ones(size(x_intercepts)); % y值都为25.3

% 绘制原始数据点和插值曲线
figure;
plot(x, y, 'o', 'MarkerSize', 8); % 绘制原始数据点
hold on;
plot(xq, yq, '-', 'LineWidth', 2); % 绘制平滑曲线

% 添加y=25.3的水平线
yline(y_intercept, '--r', 'LineWidth', 1.5); % 使用红色虚线并设置线宽

% 找到曲线上最接近y=25.3的点的索引
[~, idx_253] = min(abs(yq - y_intercept));

% 获取曲线上最接近y=25.3的点的坐标
x_253 = xq(idx_253);
y_253 = yq(idx_253);

% 在曲线上标注最接近y=25.3的点的坐标
% text(x_253, y_253, sprintf('(%.1f, %.1f)', x_253, y_253), ...
%     'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 8);
% 在图上绘制垂直于x轴的线
line([x_253, x_253], [0, y_253], 'Color', 'red', 'LineStyle', '--');

% 在图上绘制垂直于y轴的线
line([0, x_253], [y_253, y_253], 'Color', 'blue', 'LineStyle', '--');

% 找到曲线上最低点的索引
[~, idx_min] = min(yq);

% 获取曲线上最低点的坐标
x_min = xq(idx_min);
y_min = yq(idx_min);

% 在曲线上标注最低点的坐标
% text(x_min, y_min, sprintf('(%.1f, %.1f)', x_min, y_min), ...
%     'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 8);

% 在图上绘制垂直于x轴的线
line([x_min, x_min], [0, y_min], 'Color', 'red', 'LineStyle', '--');

% 在图上绘制垂直于y轴的线
line([0, x_min], [y_min, y_min], 'Color', 'blue', 'LineStyle', '--');

% 添加图例和标题
xlabel('t/s');
ylabel('θ/℃');
grid on;
