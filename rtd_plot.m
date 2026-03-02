clear; clc; close all;

opts = detectImportOptions("measurements.csv");
data = readtable("measurements.csv", opts);

RREF = 430.0; 
RNOMINAL1 = 100.0;
RNOMINAL2 = 73.8;

res1 = (data.Value1 / 32768.0) * RREF;
T1 = (res1 - RNOMINAL1) ./ (RNOMINAL1 * 0.00385);

res2 = (data.Value2 / 32768.0) * RREF;
T2 = (res2 - RNOMINAL2) ./ (RNOMINAL2 * 0.00385);

figure(1);
hold on;
grid on;
plot(data.Time, T1, 'r.-', 'DisplayName', 'Commercial RTD');
plot(data.Time, T2, 'b.-', 'DisplayName', 'Custom RTD');
legend show;
xlabel('Time');
ylabel('Temperature (°C)');

deltaT = T2 - T1;

figure(2);
plot(data.Time, deltaT, 'k.-', 'DisplayName', '\DeltaT (Custom - Commercial)');
grid on;
legend show;
xlabel('Time');
ylabel('Temperature Difference (°C)');