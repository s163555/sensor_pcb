clear; clc; close all;

opts = detectImportOptions("measurements.csv");
data = readtable("measurements.csv", opts);

RREF = 430.0; 
RNOMINAL1 = 100.0;
RNOMINAL2 = 73.8;

figure(1);
hold on;
grid on;
plot(data.Time, data.Value1, 'r.-', 'DisplayName', 'Commercial RTD');
plot(data.Time, data.Value2, 'b.-', 'DisplayName', 'Custom RTD');
legend show;
xlabel('Time');
ylabel('ADC value (A.U.)');

res1 = (data.Value1 / 32768.0) * RREF;
T1 = (res1 - RNOMINAL1) ./ (RNOMINAL1 * 0.00385);

res2 = (data.Value2 / 32768.0) * RREF;
T2 = (res2 - RNOMINAL2) ./ (RNOMINAL2 * 0.00385);

valid_idx = ~isnan(T1) & ~isnan(res2);
P = polyfit(T1(valid_idx), res2(valid_idx), 1);

RNOMINAL2_opt = P(2);                 % Intercept is the 0°C resistance
alpha2_opt = P(1) / RNOMINAL2_opt;    % Slope is Rnom * alpha

fprintf('Optimized RNOMINAL2: %.3f ohm\n', RNOMINAL2_opt);
fprintf('Optimized alpha2: %.6f\n', alpha2_opt);

T2_opt = (res2 - RNOMINAL2_opt) ./ (RNOMINAL2_opt * alpha2_opt);

figure(2);
hold on;
grid on;
plot(data.Time, T1, 'r.-', 'DisplayName', 'Commercial RTD');
plot(data.Time, T2, 'b.-', 'DisplayName', 'Custom RTD');
legend show;
xlabel('Time');
ylabel('Temperature (°C)');

deltaT = T2 - T1;
deltaT_opt = T2_opt - T1;

figure(3);
plot(data.Time, deltaT, 'k.-', 'DisplayName', '\DeltaT (Custom - Commercial)');
grid on;
legend show;
xlabel('Time');
ylabel('Temperature Difference (°C)');

figure(4);
hold on;
grid on;
plot(data.Time, T1, 'r.-', 'DisplayName', 'Commercial RTD');
plot(data.Time, T2_opt, 'b.-', 'DisplayName', 'Custom RTD');
legend show;
xlabel('Time');
ylabel('Temperature (°C)');

figure(5)
plot(data.Time, deltaT_opt, 'k.-', 'DisplayName', '\DeltaT (Custom - Commercial)');
grid on;
legend show;
xlabel('Time');
ylabel('Temperature Difference (°C)');

figure(6)
hold on
grid on
plot(T1, res1, 'r.-', 'DisplayName', 'Commercial RTD');
plot(T2, res2, 'b.-', 'DisplayName', 'Custom RTD');
legend show;
xlabel('Temperature (°C)');
ylabel('Resistance (\Omega)');