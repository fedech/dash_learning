function [download_time, capacity] = download_step(capacity_step, rate, start_time)
% DOWNLOAD_STEP find a segment download time from its instantaneous capacity
%
%  capacity_step = the capacity vector, with a sampling time of 10 ms
%  rate = the requested bitrate
%  start_time = the starting time of the segment download
%
%  download_time = the segment download time
%  capacity = the average capacity for the download

% initialization
segment_length = 2;
% total requested segment size
total_size = rate * segment_length;
downloaded = 0;
current_time = start_time;

% download the segment 10 ms by 10 ms
while (downloaded < total_size),
    downloaded = downloaded + capacity(current_time) / 10;
    current_time = current_time + 1;
end

% calculate total download time and capacity
download_time = current_time - start_time;
capacity = total_size / download_time;

end
