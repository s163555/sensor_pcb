clear; clc; close all;

% --- Configuration ---
port1 = "COM4";
port2 = "COM5";
baudRate = 115200;
maxPoints = 100;
csvFile = "measurements.csv";
bufferSize = 50;   % write to disk every N samples (set 1 to write each sample)

% --- Close previous serialport variables if present (closes ports) ---
if exist('s1','var'), clear s1; end
if exist('s2','var'), clear s2; end

try
    s1 = serialport(port1, baudRate);
    s2 = serialport(port2, baudRate);
    configureTerminator(s1, "CR/LF");
    configureTerminator(s2, "CR/LF");
    flush(s1); flush(s2);
catch ME
    error("Error opening ports. Make sure they are not open in another app.\n%s", ME.message);
end

% --- Setup Plot ---
figure('Name', 'Dual Sensor Live Plot', 'NumberTitle', 'off');
hLine1 = plot(nan, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Commercial RTD (COM4)');
hold on;
hLine2 = plot(nan, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Custom RTD (COM5)');
grid on; legend show;
xlabel('Sample Number'); ylabel('Temperature (°C)');
title('Live Temperature Comparison');
hold off;

data1 = [];
data2 = [];
counter = 0;

% Prepare CSV header (written once)
if ~isfile(csvFile)
    logger_csv(csvFile, datetime('now'), [NaN NaN], {'Time','Value1','Value2'}); % writes header then overwrites first row; we will remove header row logic inside function
    % remove the placeholder row: delete the numeric line if added
    % (function below writes only header if file missing, so no need to remove anything)
end

% Buffer for periodic writes
bufferT = datetime.empty(0,1);
bufferVals = [];

disp('Plotting... Press Ctrl+C in Command Window to stop.');

try
    while true
        str1 = readline(s1);
        str2 = readline(s2);
        val1 = str2double(str1);
        val2 = str2double(str2);

        if ~isnan(val1) && ~isnan(val2)
            counter = counter + 1;
            data1(end+1) = val1; %#ok<SAGROW>
            data2(end+1) = val2; %#ok<SAGROW>

            % Buffer the data
            bufferT(end+1,1) = datetime('now'); %#ok<SAGROW>
            bufferVals(end+1,:) = [val1 val2]; %#ok<SAGROW>

            % Flush buffer to CSV periodically
            if size(bufferVals,1) >= bufferSize
                logger_csv(csvFile, bufferT, bufferVals);
                bufferT = datetime.empty(0,1);
                bufferVals = [];
            end

            % Keep rolling window
            if length(data1) > maxPoints
                data1 = data1(end-maxPoints+1:end);
                data2 = data2(end-maxPoints+1:end);
            end

            set(hLine1, 'YData', data1, 'XData', 1:length(data1));
            set(hLine2, 'YData', data2, 'XData', 1:length(data2));
            xlim([1, max(maxPoints, length(data1))]);
            drawnow limitrate;
        end
    end
catch ME
    disp('Stopping...');
    % final flush of any remaining buffered data
    if ~isempty(bufferVals)
        logger_csv(csvFile, bufferT, bufferVals);
    end
    % Clean up serial ports
    if exist('s1','var'), clear s1; end
    if exist('s2','var'), clear s2; end
    rethrow(ME);
end

% ----------------------------
% CSV logger: accepts datetime or numeric time
% ----------------------------
function logger_csv(filename, t, meas, headerNames)
if nargin < 1 || isempty(filename), filename = "measurements.csv"; end
if nargin < 4, headerNames = []; end

% Convert time to numeric or ISO string: prefer ISO to be human readable
if isdatetime(t)
    tcol = string(t);            % will write as text ISO
else
    tcol = num2str(t(:));
end

% Normalize meas
tcount = numel(t);
if size(meas,1) ~= tcount
    error('Number of rows in meas must match length(t).');
end

% If file missing and header provided, write header first
if ~isfile(filename) && ~isempty(headerNames)
    fid = fopen(filename,'w');
    % header
    fprintf(fid, '%s', headerNames{1});
    for k=2:numel(headerNames)
        fprintf(fid, ',%s', headerNames{k});
    end
    fprintf(fid, '\n');
    fclose(fid);
end

% Append rows (fast textual append)
fid = fopen(filename,'a');
if fid == -1
    error('Cannot open %s for appending.', filename);
end

for r = 1:tcount
    if isdatetime(t)
        fprintf(fid, '%s', char(tcol(r)));
    else
        fprintf(fid, '%s', tcol(r,:));
    end
    fprintf(fid, ',%g', meas(r,:));
    fprintf(fid, '\n');
end
fclose(fid);
end
