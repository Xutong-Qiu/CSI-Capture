close all;
% clear;


%% read csv file exported from wireshark

% first column: Time, etc
% Table = readtable('webbrowsingmissdata/TxJCAS3_Rxwebbrowsing_SnifferAC1_ch36bw80_1_WiresharkGT.csv', 'VariableNamingRule', 'preserve');
% 
% time_epoch_wireshark = double(Table{:, 'Epoch Time'});
% framecontrol_wireshark = int32(Table{:, 'Frame Control Field'});
% framecontrol_char = dec2hex(int32(Table{:, 'Frame Control Field'}),4);
% timestamps_wireshark = time_epoch_wireshark - time_epoch_wireshark(1);

%% read pcap file captured using Nexmon
% BW = 80;
% filepath = '../outputs/sniffer1.pcap';
% [time_epoch_nexmon, framecontrol_nexmon, csis_nexmon] = readNexmonpcap(BW, filepath);
% 
% % some subcarriers are incorrect or should be null/0s
% % should be removed for DNN applications
% if BW == 80
%     csis_nexmon(:,126:132) = 0;
%     csis_nexmon(:,1:3) = 0;
% elseif BW == 20
%     % csis_nexmon(:,1) = 0;
%     csis_nexmon(:,29:36) = 0;
%     % 1, 29-36,
% end
% 
% % only keep 20MHz
% if BW == 80
%     BW = 20;
%     csis_nexmon = csis_nexmon(:,128:193);
% end
% 
% ts1 = time_epoch_nexmon - time_epoch_nexmon(1);
% 
% ts1(end)


%% read csis from 6 sniffers

N_sniffers = 6;
timestamps = cell(1, N_sniffers);
time_epochs = cell(1, N_sniffers);
CSIs = cell(1, N_sniffers);
CSIs_diff = cell(1, N_sniffers);
framecontrols = cell(1, N_sniffers);

% figure
for i = 1:N_sniffers
    BW = 80;
    % sniffer 2 and 5 monitoring 20MHz
    if i == 2 || i == 5
        BW = 20;
    end
    filepath = sprintf('../outputs/walking_youtube_Tx1_5G_20MHz/sniffer%d.pcap', i);
    [time_epoch_nexmon, framecontrol_nexmon, csis_nexmon] = readNexmonpcap(BW, filepath);
    framecontrols{i} = framecontrol_nexmon;
    time_epochs{i} = time_epoch_nexmon;
    timestamps{i} = time_epoch_nexmon - time_epoch_nexmon(1);
    %remove invalid subcarriers
    if BW == 80
        csis_nexmon(:,126:132) = 0;
        csis_nexmon(:,1:3) = 0;
    elseif BW == 20
        csis_nexmon(:,1) = 0;
        csis_nexmon(:,29:36) = 0;
        % 1, 29-36,
    end
%     % only 20MHz valid data for most cases
%     if BW == 80
%         BW = 20;
%         csis_nexmon = csis_nexmon(:,128:191);
%     end
    
    CSIs{i} = csis_nexmon;
    CSIs_diff{i} = csis_nexmon - csis_nexmon(1,:);
    fprintf('---Sniffer:%d; Total frame number: %d ---\n\n', i, length(csis_nexmon));
end


figure
for i = 1:N_sniffers
    BW = 80;
    if i == 2 || i == 5
        BW = 20;
    end
%     % only 20MHz valid data for most cases
%     if BW == 80
%         BW = 20;
%         csis_nexmon = csis_nexmon(:,128:191);
%     end
    % only 20MHz valid data for most cases
    if i == 1 || i == 4
        BW = 20;
        CSIs{i} = CSIs{i}(:,128:191);
    end
    subplot(2,3,i)
    plot_csidata_1sniffer('CSIs', CSIs{i}, 'BW', BW, 'normalize', true);
    ylabel('Subcarriers')
    xlabel('Packet number')
    title('Sniffer ' + string(i))
end

figure
for i = 1:N_sniffers
    subplot(2,3,i)
    plot_framerates_frametypes_1sniffer(timestamps{i}, framecontrols{i})
    xlabel('Time (S)');
    ylabel('Frame rates (FPS)');
    title('Sniffer ' + string(i))
end


% 
% 
% firstValues = cellfun(@(c) c(1), time_epochs);
% fprintf('Max diff of the starting times: %d\n', max(firstValues)-min(firstValues));
% 
% lastValues = cellfun(@(c) c(end), time_epochs);
% fprintf('Max diff of the end times: %d\n', max(lastValues)-min(lastValues));



%% choose which data to process

% timestamps = ts1;
% framecontrol = framecontrol_nexmon;

% timestamps = timestamps_wireshark;
% framecontrol = framecontrol_wireshark;

% fprintf('\nTotal frame number: %d \n', length(timestamps));


%% plot 6 sniffers

% figure
% % subplot(2,3,1)
% plot_csidata_1sniffer('CSIs', CSIs{1}, 'BW', BW, 'normalize', true);


%% plot rates/timing (simple)

% plot the rates 
% plotFrameRates(timestamps);

% timings
% plotTimings(timestamps, 0, 10);


%% rates and timestamps of different frame types
%%% Some common frame types %%%
% Frame Type 0 (management)
%   Frame Type 5000 (Probe response)
%   Frame Type 8000 (Beacon)
% Frame Type 1 (control)
%   Frame Type 5400 (VHT/HE NDP Announcement)
%   Frame Type 9400 (Block Ack)
%   Frame Type B400 (Request-to-send)
%   Frame Type C400 (Clear-to-send)
% Frame Type 2 (data)
%   Frame Type 0842 (Data)
%   Frame Type 0862 (Data, More Data: Data is buffered for STA at AP)
%   Frame Type 8842 (QoS Data)
%   Frame Type 884A (QoS Data, retransmitted)
%   Frame Type C802 (QoS Null function (No data))
%
% check the 802.11 standard or this link for more details: 
% https://howiwifi.com/2020/07/13/802-11-frame-types-and-formats/


% get the numbers of each frame type
% frametypes_stats(framecontrol);

% plot the fps of all frame types
% plotFrameRates(timestamps);

% plot the fps of each frame type
% plot_framerates_frametypes(timestamps, framecontrol)

% plot the timestamps of all frame types
% plot_timerange_allframetype(timestamps, 0, 1000, framecontrol)

% plot the timestamps of each frame type
% plot_time_frametype(timestamps, framecontrol)

% % analyze the repeated csis
% sameadjacentRowIndex = int32(adjacent_row_same(csis_nexmon));
% timestamps_diff =  diff(timestamps);
% sameadjacentRow_timestamps = timestamps(sameadjacentRowIndex);
% 
% repeated_info_table = table();
% repeated_info_table.firstcsirowindex = sameadjacentRowIndex;
% repeated_info_table.firstcsiFrametype = dec2hex(framecontrol_nexmon(sameadjacentRowIndex),4);
% repeated_info_table.repeatedcsirowIndex = sameadjacentRowIndex+1;
% repeated_info_table.repeatedcsiFrametype = dec2hex(framecontrol_nexmon(sameadjacentRowIndex+1),4);
% % disp('Repeated row index: ');
% sameadjacentRowIndex

% plot_timerange_allframetype_sameadjacentrows(timestamps, 0, 1000, framecontrol, sameadjacentRow_timestamps)

% plot csis from all frames
framecontrol_hex = dec2hex(framecontrol_nexmon/256,2);
framecontrol_string = string(dec2hex(framecontrol_nexmon/256,2));
% plot_allcsidata_withwaitbuttons('CSIs', csis_nexmon, 'BW', BW, 'normalize', true, 'frametype', framecontrol_hex);


% plot csis captured by nexmon
% showeveryframe = true;
% plot_CSIsbyType(framecontrol_nexmon, csis_nexmon, BW, showeveryframe)



% figure
% subplot(2,3,1)
% plot_csidata_1sniffer('CSIs', csis_nexmon, 'BW', BW, 'normalize', true, 'frametype', framecontrol_hex);


%% functions
function swapped_matrix = swapHighLow8bit(int16matrix)
    high_bits = bitand(int16matrix, int16(0xFF00));
    low_bits = bitand(int16matrix, int16(0x00FF));
    
    shifted_high = bitshift(high_bits, -8);
    shifted_low = bitshift(low_bits, 8);
    
    swapped_matrix = bitor(shifted_high, shifted_low);
end

function [timestamps_valid, frametypes_valid_swap_typecast, csi_valid] = readNexmonpcap(BW, filepath)
    %% configuration
    CHIP = '43455c0';          % wifi chip (possible values 4339, 4358, 43455c0, 4366c0) https://github.com/seemoo-lab/nexmon_csi
%     BW = 80;                % bandwidth
%     NPKTS_MAX = 100000;       % max number of UDPs to process
    
    
    
    %% read file
    HOFFSET = 16;           % header offset
    NFFT = BW*3.2;          % fft size/ num of subcarriers
%     p = readpcap();
    p = readpcap();
    p.open(filepath);
    n = length(p.all());
    p.from_start();
    rowsToRemove = []; % incorrect size
    k = 1;
    
    csi_buff = complex(zeros(n,NFFT),0);
    frametypes = zeros(n,1);
    timestamps = double(zeros(n,1));
    
%     disp('...Reading CSIs...');
    % read CSIs from each frame
    while (k <= n)
        f = p.next();
        if isempty(f)
            disp('no more frames');
            break;
        end
        if f.header.orig_len-(HOFFSET-1)*4 ~= NFFT*4 % wrong when capturing
            disp(['    skip frame ', num2str(k), ' with wrong size when capturing']); 
            rowsToRemove = [rowsToRemove,k];
            k = k + 1;
            continue;
        end


    
    %     payload = f.payload_CSIs; % UDP payload/frame
    %     if f.header.orig_len ~= length(payload)*4 % wrong when storing/livestreaming
    %         disp(['skip frame ', num2str(k), ' with wrong size when storing']); 
    %         rowsToRemove = [rowsToRemove,k];
    %         continue;
    %     end
    
        rawCSIs = f.payload_CSIs; % UDP payload/frame
        if NFFT ~= length(rawCSIs) % wrong when storing/livestreaming
            disp(['    skip frame ', num2str(k), ' with wrong size when storing']); 
            rowsToRemove = [rowsToRemove,k];
            k = k + 1;
            continue;
        end
    
    
        % upcak the int number to floating/complex number
        if (strcmp(CHIP,'4339') || strcmp(CHIP,'43455c0'))
            Hout = typecast(rawCSIs, 'int16');
        elseif (strcmp(CHIP,'4358'))
            Hout = unpack_float(int32(0), int32(NFFT), rawCSIs);
        elseif (strcmp(CHIP,'4366c0'))
            Hout = unpack_float(int32(1), int32(NFFT), rawCSIs);
        else
            disp('invalid CHIP');
            break;
        end
        Hout = reshape(Hout,2,[]).';
        cmplx = double(Hout(1:NFFT,1))+1j*double(Hout(1:NFFT,2));
        csi_buff(k,:) = cmplx.';
    
        frametypes(k) = f.payload_info.frametype;
        timestamps(k) = double(f.header.ts_sec) + double(f.header.ts_usec) / 1e6;
        k = k + 1;
    end
    
    %% process
%     disp('...Processing CSIs...');
    logicalIndex = true(size(csi_buff, 1), 1);
    logicalIndex(rowsToRemove) = false;
    
    csi_valid = csi_buff(logicalIndex, :);
    timestamps_valid = timestamps(logicalIndex, :);
    frametypes_valid = frametypes(logicalIndex, :);

    frametypes_valid = int16(frametypes_valid);
    frametypes_valid_swap = swapHighLow8bit((frametypes_valid));
    frametypes_valid_swap_typecast = typecast(frametypes_valid_swap, 'uint16');

end


function plotFrameRates(timestamps)
    floor_timestamps_seconds = floor(timestamps);
    [counts, ] = histcounts(floor_timestamps_seconds, 'BinMethod', 'integers');
    
    figure
    plot(counts,'b')
    xlabel('Time (S)');
    ylabel('Frame rates (FPS)');
end

function plotTimings(timestamps, start_time, end_time)
    indices_between_times = find(timestamps >= start_time & timestamps <= end_time);

    figure
%     scatter(timestamps(indices_between_times),ones(length(indices_between_times)),'b') % slow
%     scatter(timestamps(indices_between_times),repmat(1, size(indices_between_times)),'b')
%     plot(timestamps(indices_between_times), ones(length(indices_between_times)), 'o', 'Color', 'b' ); % slow
    plot(timestamps(indices_between_times), repmat(1, size(indices_between_times)), 'o', 'Color', 'b' );

    xlabel('Time in seconds');
    title('Frame Timings');
end

function indicesByType = separateIndicesByType(Types)
    uniqueTypes = unique(Types);
    indicesByType = cell(1, numel(uniqueTypes));

    for i = 1:numel(uniqueTypes)
        currentType = uniqueTypes(i);
        indicesForCurrentType = find(Types == currentType);
        indicesByType{i} = indicesForCurrentType;
    end
end

function frametypes_stats(frametypes)
    
    % three coarse types: management-0, control-1, data-3
    frametypes_names = ["Management", "Control", "Data"];

    % the 3rd position of the frame control field relates to the frmae type
    % 0x8[0]00 -> 0; 0x9[4]00 -> 1; 0x8[8]42 -> 2    
%     frametypes_threecoarsetypes = rem(int32(frametypes)/256,16)/4;
    frametypes_threecoarsetypes = rem(int32(frametypes)/256,16)/4;
    indices_frames_threetypes = separateIndicesByType(frametypes_threecoarsetypes);
    uniqueTypes_frametypes_threetypes = unique(frametypes_threecoarsetypes);
    
    for i = 1:numel(indices_frames_threetypes)
        if uniqueTypes_frametypes_threetypes(i)+1 > 3
            fprintf('Unknown Frame Type 0x%s: %d packets \n', dec2hex(1,4), length(indices_frames_threetypes{i}));
%             continue
        else
        fprintf(' Frame Type %d: %d packets (%s)\n', uniqueTypes_frametypes_threetypes(i), length(indices_frames_threetypes{i}), frametypes_names(uniqueTypes_frametypes_threetypes(i)+1));

        end
%         fprintf('Coarse Frame Type %d: %d packets (%s)\n', uniqueTypes_frametypes_threetypes(i), length(indices_frames_threetypes{i}), frametypes_names(uniqueTypes_frametypes_threetypes(i)+1));
        
        % specific frame contro field
        indicesSeparated_finerframetype = separateIndicesByType(frametypes(indices_frames_threetypes{i}));
        uniqueTypes_finerframetype = unique(frametypes(indices_frames_threetypes{i}));
        
        for j = 1:numel(indicesSeparated_finerframetype)
%             fprintf('   Frame Control Field 0x%s: %d packets \n', dec2hex(uniqueTypes_finerframetype(j),4), length(indicesSeparated_finerframetype{j}));
            fprintf('   Frame Control Field 0x%s: %d packets \n', dec2hex(uniqueTypes_finerframetype(j)/256,2), length(indicesSeparated_finerframetype{j}));
    
        end
    end
    fprintf('\n');

end

function plot_framerates_frametypes(timestamps, frametypes)

    uniqueTypes = unique(frametypes);

    colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];  % Add more colors if needed
%     markers = {'o', 's', 'd', '^', 'v', '>', '<'};  % Add more markers if needed
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.'};  % Add more markers if needed


    figure;

    
    % Loop through each unique data type
    for i = 1:length(uniqueTypes)
        typeIndices = (frametypes == uniqueTypes(i));
        typeTimestamps = timestamps(typeIndices);

        color = colors(mod(i-1, length(colors)) + 1);
        marker = markers{mod(i-1, length(markers)) + 1};
        
        hold on;
        floor_timestamps_seconds = floor(typeTimestamps);
        [counts, edges] = histcounts(floor_timestamps_seconds, 'BinMethod', 'integers');
        centers = (edges(1:end-1) + edges(2:end)) / 2;
        plot(centers, counts, strcat('-', marker), 'Color', color, 'DisplayName', dec2hex(int32(uniqueTypes(i))/256, 2));

%         plot(uniquetimestamps,counts, strcat('-', marker), 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
%         plot(typeTimestamps, repmat(i, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
%         plot(typeTimestamps, repmat(0, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
    end
    
    legend;


%     floor_timestamps_seconds = floor(timestamps);
%     [counts, ] = histcounts(floor_timestamps_seconds, 'BinMethod', 'integers');
%     
%     figure
%     plot(counts,'b')
    xlabel('Time (S)');
    ylabel('Frame rates (FPS)');
    title('Frame Rates of Different Frame Types');

end


function plot_framerates_frametypes_1sniffer(timestamps, frametypes)

    uniqueTypes = unique(frametypes);

    colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];  % Add more colors if needed
%     markers = {'o', 's', 'd', '^', 'v', '>', '<'};  % Add more markers if needed
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.'};  % Add more markers if needed


%     figure;

    
    % Loop through each unique data type
    for i = 1:length(uniqueTypes)
        typeIndices = (frametypes == uniqueTypes(i));
        typeTimestamps = timestamps(typeIndices);

        color = colors(mod(i-1, length(colors)) + 1);
        marker = markers{mod(i-1, length(markers)) + 1};
        
        hold on;
        floor_timestamps_seconds = floor(typeTimestamps);
        [counts, edges] = histcounts(floor_timestamps_seconds, 'BinMethod', 'integers');
        centers = (edges(1:end-1) + edges(2:end)) / 2;
        plot(centers, counts, strcat('-', marker), 'Color', color, 'DisplayName', dec2hex(int32(uniqueTypes(i))/256, 2));

%         plot(uniquetimestamps,counts, strcat('-', marker), 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
%         plot(typeTimestamps, repmat(i, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
%         plot(typeTimestamps, repmat(0, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
    end
    
    legend;


%     floor_timestamps_seconds = floor(timestamps);
%     [counts, ] = histcounts(floor_timestamps_seconds, 'BinMethod', 'integers');
%     
%     figure
%     plot(counts,'b')
%     xlabel('Time (S)');
%     ylabel('Frame rates (FPS)');
%     title('Frame Rates of Different Frame Types');

end


function plot_time_frametype(timestamps, frametypes)
    
    % Get the unique data types
    uniqueTypes = unique(frametypes);

    colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];  % Add more colors if needed
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.'};  % Add more markers if needed

    figure;

    
    % Loop through each unique data type
    for i = 1:length(uniqueTypes)
        typeIndices = (frametypes == uniqueTypes(i));
        typeTimestamps = timestamps(typeIndices);

        color = colors(mod(i-1, length(colors)) + 1);
        marker = markers{mod(i-1, length(markers)) + 1};
        
        hold on;
        plot(typeTimestamps, repmat(i, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)/256),2)) );
%         plot(typeTimestamps, repmat(0, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
    end
    
    legend;
    xlabel('Timestamps');
    ylabel('Frame Types');
    title('Timestamps by Frame Type');


end


function plot_timerange_allframetype(timestamps, start_time, end_time, frametypes)

    indices_between_times = find(timestamps >= start_time & timestamps <= end_time);
    frametypes= frametypes(indices_between_times);
    timestamps= timestamps(indices_between_times);
    
    % Get the unique data types
    uniqueTypes = unique(frametypes);

    colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];  % Add more colors if needed
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.'};  % Add more markers if needed

    figure;

    
    % Loop through each unique data type
    for i = 1:length(uniqueTypes)
        typeIndices = (frametypes == uniqueTypes(i));
        
        typeTimestamps = timestamps(typeIndices);

        color = colors(mod(i-1, length(colors)) + 1);
        marker = markers{mod(i-1, length(markers)) + 1};
        
        hold on;
%         plot(typeTimestamps, repmat(i, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
        plot(typeTimestamps, repmat(1, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i))/256,2)) );
    end
    
    legend;
    xlabel('Timestamps');
    ylabel('Data Types');
    title('Timestamps by Frame Type');

end

function plot_timerange_allframetype_sameadjacentrows(timestamps, start_time, end_time, frametypes, timestamps_sameadjacentrows)

    indices_between_times = find(timestamps >= start_time & timestamps <= end_time);
    frametypes= frametypes(indices_between_times);
    timestamps= timestamps(indices_between_times);
    
    % Get the unique data types
    uniqueTypes = unique(frametypes);

    colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];  % Add more colors if needed
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.'};  % Add more markers if needed

    figure;

    
    % Loop through each unique data type
    for i = 1:length(uniqueTypes)
        typeIndices = (frametypes == uniqueTypes(i));
        
        typeTimestamps = timestamps(typeIndices);

        color = colors(mod(i-1, length(colors)) + 1);
        marker = markers{mod(i-1, length(markers)) + 1};
        
        hold on;
%         plot(typeTimestamps, repmat(i, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)),4)) );
        plot(typeTimestamps, repmat(1, size(typeTimestamps)), marker, 'Color', color,'DisplayName', (dec2hex(int32(uniqueTypes(i)/256),2)) );
    end

    plot(timestamps_sameadjacentrows, repmat(0, size(timestamps_sameadjacentrows)), '*', 'Color', 'r','DisplayName', 'repeated' );

    
    legend;
    xlabel('Timestamps');
    ylabel('Data Types');
    title('Timestamps by Frame Type');

end


function plot_CSIsbyType(framecontrol, csis, BW, showeveryframe)
    
    % three coarse types: management-0, control-1, data-3
%     frametypes_names = ["Management", "Control", "Data"];

    % the 3rd position of the frame control field relates to the frmae type
    % 0x8[0]00 -> 0; 0x9[4]00 -> 1; 0x8[8]42 -> 2    
    frametypes_threecoarsetypes = rem(framecontrol/256,16)/4;
    indices_frames_threetypes = separateIndicesByType(frametypes_threecoarsetypes);
%     uniqueTypes_frametypes_threetypes = unique(frametypes_threecoarsetypes);
    
    for i = 1:numel(indices_frames_threetypes)
%         fprintf('Coarse Frame Type %d: %d packets (%s)\n', uniqueTypes_frametypes_threetypes(i), length(indices_frames_threetypes{i}), frametypes_names(uniqueTypes_frametypes_threetypes(i)+1));
        
        % specific frame contro field
        indicesSeparated_finerframetype = separateIndicesByType(framecontrol(indices_frames_threetypes{i}));
        uniqueTypes_finerframetype = unique(framecontrol(indices_frames_threetypes{i}));
        
        csi_threetypes = csis(indices_frames_threetypes{i},:);
        for j = 1:numel(indicesSeparated_finerframetype)
%             fprintf('  Frame Control Field 0x%s: %d packets \n', dec2hex(uniqueTypes_finerframetype(j),4), length(indicesSeparated_finerframetype{j}));
            if showeveryframe
                plot_csidata_withwaitbuttons('CSIs', csi_threetypes(indicesSeparated_finerframetype{j},:), 'BW', BW, 'normalize', false, 'frametype', dec2hex(uniqueTypes_finerframetype(j)/256,2));
            else
                plot_csidata_nowaitbuttons('CSIs', csi_threetypes(indicesSeparated_finerframetype{j},:), 'BW', BW, 'normalize', false, 'frametype', dec2hex(uniqueTypes_finerframetype(j)/256,2));
            end
        end
    end

end

function plot_csidata_withwaitbuttons(varargin)
% plot the ampltude, phase, and spectrogram of the CSI data
% plot_csidata('CSIs', CSIs, 'BW', 80, 'normalize', true);

    % Default values

    % Process parameter-value pairs
    for k = 1:2:length(varargin)
        switch varargin{k}
            case 'CSIs'
                csi = varargin{k+1};
            case 'BW'
                BW = varargin{k+1};
                nfft = BW*3.2; % num of the subcarriers
            case 'normalize'
                normalize = varargin{k+1};
            case 'frametype'
                frametype = varargin{k+1};
            
            % ... add more cases as needed ...
        end
    end

    % PLOTCSI Summary of this function goes here
    %   Detailed explanation goes here
    
    % csi_buff = fftshift(csi,2);
    csi_buff = csi;
    csi_phase = rad2deg(angle(csi_buff));
    for cs = 1:size(csi_buff,1)
        csi = abs(csi_buff(cs,:));
        if normalize
            csi = csi./max(csi);
        end
        csi_buff(cs,:) = csi;
    end
    
    figure
    x = -(nfft/2):1:(nfft/2-1);
    subplot(3,1,3)
    imagesc(x,[1 size(csi_buff,1)],csi_buff)
    myAxis = axis();
    axis([min(x)-0.5, max(x)+0.5, myAxis(3), myAxis(4)])
    set(gca,'Ydir','reverse')
    xlabel('Subcarrier')
    ylabel('Packet number')
    
    max_y = max(csi_buff(:));
    for cs = 1:size(csi_buff, 1)
        csi = csi_buff(cs,:);
        
        subplot(3,1,1)
        plot(x,csi);
        grid on
        myAxis = axis();
        axis([min(x)-0.5, max(x)+0.5, 0, max_y])
        xlabel('Subcarrier')
        ylabel('Magnitude')
    %     title('Channel State Information')
        if frametype
            titleStr = sprintf('Channel State Information from Frame Type: 0x%s', frametype);
            title(titleStr)
        else
            title('Channel State Information')
        end
        text(max(x),max_y-(0.05*max_y),['Packet #',num2str(cs),' of ',num2str(size(csi_buff,1))],'HorizontalAlignment','right','Color',[0.75 0.75 0.75]);
        
        subplot(3,1,2)
        plot(x,csi_phase(cs,:));
        grid on
        myAxis = axis();
        axis([min(x)-0.5, max(x)+0.5, -180, 180])
        xlabel('Subcarrier')
        ylabel('Phase')
        
        disp(['Frame Type: 0x', frametype,' Packet #',num2str(cs),' of ',num2str(size(csi_buff,1))]);
        disp('    Press any key to show next frame..');

        try
            waitforbuttonpress();
        catch ME
            if contains(ME.message, 'waitforbuttonpress exit because target figure has been deleted')
                disp('Figure was closed.');
                return;
            else
                rethrow(ME); % If it's some other error, rethrow it
            end
        end
    
    end
    close

end


function plot_csidata_nowaitbuttons(varargin)
% plot the ampltude, phase, and spectrogram of the CSI data
% plot_csidata('CSIs', CSIs, 'BW', 80, 'normalize', true);

    % Default values

    % Process parameter-value pairs
    for k = 1:2:length(varargin)
        switch varargin{k}
            case 'CSIs'
                csi = varargin{k+1};
            case 'BW'
                BW = varargin{k+1};
                nfft = BW*3.2; % num of the subcarriers
            case 'normalize'
                normalize = varargin{k+1};
            case 'frametype'
                frametype = varargin{k+1};

            
            % ... add more cases as needed ...
        end
    end

    % PLOTCSI Summary of this function goes here
    %   Detailed explanation goes here
    
    % csi_buff = fftshift(csi,2);
    csi_buff = csi;
    csi_phase = rad2deg(angle(csi_buff));
    for cs = 1:size(csi_buff,1)
        csi = abs(csi_buff(cs,:));
        if normalize
            csi = csi./max(csi);
        end
        csi_buff(cs,:) = csi;
    end
    
    figure
    x = -(nfft/2):1:(nfft/2-1);
    subplot(3,1,3)
    imagesc(x,[1 size(csi_buff,1)],csi_buff)
    myAxis = axis();
    axis([min(x)-0.5, max(x)+0.5, myAxis(3), myAxis(4)])
    set(gca,'Ydir','reverse')
    xlabel('Subcarrier')
    ylabel('Packet number')
    
    max_y = max(csi_buff(:));
    for cs = 1:1
        csi = csi_buff(cs,:);
        
        subplot(3,1,1)
        plot(x,csi);
        grid on
        myAxis = axis();
        axis([min(x)-0.5, max(x)+0.5, 0, max_y])
        xlabel('Subcarrier')
        ylabel('Magnitude')
    %     title('Channel State Information')
        if frametype
            titleStr = sprintf('Channel State Information from Frame Type: 0x%s', frametype);
            title(titleStr)
        else
            title('Channel State Information')
        end
        text(max(x),max_y-(0.05*max_y),['Packet #',num2str(cs),' of ',num2str(size(csi_buff,1))],'HorizontalAlignment','right','Color',[0.75 0.75 0.75]);
        
        subplot(3,1,2)
        plot(x,csi_phase(cs,:));
        grid on
        myAxis = axis();
        axis([min(x)-0.5, max(x)+0.5, -180, 180])
        xlabel('Subcarrier')
        ylabel('Phase')
        
    %     disp('Press any key to continue..');
    %     waitforbuttonpress();
    %     try
    %         waitforbuttonpress();
    %     catch ME
    %         if contains(ME.message, 'waitforbuttonpress exit because target figure has been deleted')
    %             disp('Figure was closed.');
    %             return;
    %         else
    %             rethrow(ME); % If it's some other error, rethrow it
    %         end
    %     end
    
    
    end
    % close

end



function plot_allcsidata_withwaitbuttons(varargin)
% plot the ampltude, phase, and spectrogram of the CSI data
% plot_csidata('CSIs', CSIs, 'BW', 80, 'normalize', true);

    % Default values

    % Process parameter-value pairs
    for k = 1:2:length(varargin)
        switch varargin{k}
            case 'CSIs'
                csi = varargin{k+1};
            case 'BW'
                BW = varargin{k+1};
                nfft = BW*3.2; % num of the subcarriers
            case 'normalize'
                normalize = varargin{k+1};
            case 'frametype'
                frametype = varargin{k+1};
            
            % ... add more cases as needed ...
        end
    end

    % PLOTCSI Summary of this function goes here
    %   Detailed explanation goes here
    
    % csi_buff = fftshift(csi,2);
    csi_buff = csi;
    csi_phase = rad2deg(angle(csi_buff));
    for cs = 1:size(csi_buff,1)
        csi = abs(csi_buff(cs,:));
        if normalize
            csi = csi./max(csi);
        end
        csi_buff(cs,:) = csi;
    end
    
    figure
    x = -(nfft/2):1:(nfft/2-1);
    subplot(3,1,3)
    imagesc(x,[1 size(csi_buff,1)],csi_buff)
    myAxis = axis();
    axis([min(x)-0.5, max(x)+0.5, myAxis(3), myAxis(4)])
    set(gca,'Ydir','reverse')
    xlabel('Subcarrier')
    ylabel('Packet number')
    
    max_y = max(csi_buff(:));
    for cs = 1:size(csi_buff, 1)
        csi = csi_buff(cs,:);
        
        subplot(3,1,1)
        plot(x,csi);
        grid on
        myAxis = axis();
        axis([min(x)-0.5, max(x)+0.5, 0, max_y])
        xlabel('Subcarrier')
        ylabel('Magnitude')
    %     title('Channel State Information')
%         if frametype
%             titleStr = sprintf('Channel State Information from All Frames Type: 0x%s', frametype(cs,:));
            titleStr = sprintf('Channel State Information from All Frames');
            title(titleStr)
%         else
%             title('Channel State Information')
%         end
        text(max(x),max_y-(0.05*max_y),['Frame Type: 0x', frametype(cs,:), ': Packet #',num2str(cs),' of ',num2str(size(csi_buff,1))],'HorizontalAlignment','right','Color',[0.75 0.75 0.75]);
        
        subplot(3,1,2)
        plot(x,csi_phase(cs,:));
        grid on
        myAxis = axis();
        axis([min(x)-0.5, max(x)+0.5, -180, 180])
        xlabel('Subcarrier')
        ylabel('Phase')
        
        disp(['Frame Type: 0x', frametype(cs,:),' Packet #',num2str(cs),' of ',num2str(size(csi_buff,1))]);
        disp('    Press any key to show next frame..');

        try
            waitforbuttonpress();
        catch ME
            if contains(ME.message, 'waitforbuttonpress exit because target figure has been deleted')
                disp('Figure was closed.');
                return;
            else
                rethrow(ME); % If it's some other error, rethrow it
            end
        end
    
    end
    close

end

function adjacentRowsameIndex = adjacent_row_same (matrix)
    
    [nRows, ] = size(matrix);
    
    adjacentRowsameIndex = [];
    
    for i = 1:nRows-1
        if all(matrix(i,:) == matrix(i+1,:))
            adjacentRowsameIndex = [adjacentRowsameIndex; i];
        end
    end
    
%     disp(adjacentRowsameIndex);

end


function plot_csidata_1sniffer(varargin)
% plot the ampltude, phase, and spectrogram of the CSI data
% plot_csidata('CSIs', CSIs, 'BW', 80, 'normalize', true);

    % Default values

    % Process parameter-value pairs
    for k = 1:2:length(varargin)
        switch varargin{k}
            case 'CSIs'
                csi = varargin{k+1};
            case 'BW'
                BW = varargin{k+1};
                nfft = BW*3.2; % num of the subcarriers
            case 'normalize'
                normalize = varargin{k+1};
            case 'frametype'
                frametype = varargin{k+1};

            
            % ... add more cases as needed ...
        end
    end

    % PLOTCSI Summary of this function goes here
    %   Detailed explanation goes here
    
    % csi_buff = fftshift(csi,2);
    csi_buff = csi;
    csi_phase = rad2deg(angle(csi_buff));
    for cs = 1:size(csi_buff,1)
        csi = abs(csi_buff(cs,:));
        if normalize
            csi = csi./max(csi);
        end
        csi_buff(cs,:) = csi;
    end
    
%     figure

    y = -(nfft/2):1:(nfft/2-1);
%     subplot(3,1,3)
    imagesc([1 size(csi_buff,1)], y, csi_buff')
    myAxis = axis();
%     axis([min(y)-0.5, max(x)+0.5, myAxis(3), myAxis(4)])
    set(gca,'Ydir','reverse')
    ylabel('Subcarrier')
    xlabel('Packet number')
    
end