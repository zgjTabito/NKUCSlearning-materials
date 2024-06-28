% 生成示例数据
x = [0,50, 100, 150, 200, 250];
y = [54.545, 54.56119, 54.57741, 54.59379, 54.61004,54.62635];

% 绘制原始数据
figure;
plot(x, y, 'o', 'MarkerSize', 8, 'LineWidth', 2);
% title('原始数据');
xlabel('n');
ylabel('d');
grid on;

% 使用最小二乘法计算斜率
n = length(x);
sum_x = sum(x);
sum_y = sum(y);
sum_x_squared = sum(x.^2);
sum_xy = sum(x.*y);

% 计算斜率和截距
slope = (n*sum_xy - sum_x*sum_y) / (n*sum_x_squared - sum_x^2);
intercept = (sum_y - slope*sum_x) / n;
% 在显示屏中输出斜率
disp(['斜率为: ', num2str(slope)]);

% 计算拟合线的 y 值
y_fit = slope*x + intercept;

% 绘制拟合线
hold on;
plot(x, y_fit, 'r-', 'LineWidth', 2);
% legend('原始数据', '拟合线', 'Location', 'best');

hold off;
