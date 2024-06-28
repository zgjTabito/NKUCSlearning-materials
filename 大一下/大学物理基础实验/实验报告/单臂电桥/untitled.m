% 原始的伏安特性数据
voltage = [3314.92 6629.28 10299.06 14087.22 17638.62 20953.26 24384.22]; % 电压数据
current = [0.5 1.0 1.5 2.0 2.5 3.0 3.5]; % 电流数据

% 将数据合并到一个矩阵中
data = [voltage', current'];

% 在数据的开头插入原点 (0, 0)
data_with_origin = [0, 0; data];

% 画出伏安特性曲线（包含原点）
scatter(data_with_origin(:,1), data_with_origin(:,2), 'filled');
xlabel('E/V');
ylabel('S/nA');
title('电桥灵敏度与电源电压的关系');

% 多项式拟合
degree = 1; % 多项式的阶数
coefficients = polyfit(data_with_origin(:,1), data_with_origin(:,2), degree);

% 计算拟合后的电阻值
resistance = 1 / coefficients(1); % 由于 Ohm's Law: V = IR，所以 R = V/I

% 在图中画出拟合曲线
hold on;
fitted_voltage = linspace(0, max(voltage), 100); % 生成用于绘制拟合曲线的电压值
fitted_current = polyval(coefficients, fitted_voltage); % 计算拟合曲线的电流值
plot(fitted_voltage, fitted_current, 'r', 'LineWidth', 2);
% legend('Data Points', 'Fitted Curve');

% 标注数据点坐标
for i = 1:size(data_with_origin, 1)
    text(data_with_origin(i,1), data_with_origin(i,2), ['(', num2str(data_with_origin(i,1)), ', ', num2str(data_with_origin(i,2)), ')']);
end

% 显示电阻值
% disp(['拟合后的电阻值为: ', num2str(resistance), ' Ω']);

num_points = 2;
random_indices = randperm(length(fitted_voltage), num_points);
selected_voltage = fitted_voltage(random_indices);
selected_current = fitted_current(random_indices);

% 显示选取的电压和电流值
disp('选取的电压和电流值:');
for i = 1:num_points
    disp(['点', num2str(i), ':']);
    disp(['  电压值: ', num2str(selected_voltage(i)), ' V']);
    disp(['  电流值: ', num2str(selected_current(i)), ' A']);
end