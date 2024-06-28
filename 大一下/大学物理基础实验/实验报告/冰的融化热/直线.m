% 示例数据
x = [0,1,2,3];
y = [36.7,36.5,36.3,36.0];

% 使用 polyfit 函数拟合直线
p = polyfit(x, y, 1);

% 计算拟合直线的 y 值
y_fit = polyval(p, x);

% 绘制原始数据点
figure;
plot(x, y, 'o', 'DisplayName', 'Data Points');
hold on;

% 绘制拟合直线
plot(x, y_fit, '-', 'DisplayName', 'Fitted Line');

% 添加图例和标签
xlabel('t/s');
ylabel('θ/℃');

% 显示拟合直线的方程
disp(['Fitted line equation: y = ' num2str(p(1)) 'x + ' num2str(p(2))]);

% 关闭 hold
hold off;
