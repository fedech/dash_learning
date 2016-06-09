function download_time = download_markov(rate, capacity);
% DOWNLOAD_MARKOV downloads a video segment using a Markovian capacity for the
% whole segment
%
%  rate = the requested video bitrate
%  capacity = the average channel capacity
%
%  download_time = the total download time for the segment

%segment length (in seconds)
segment_length = 2;

% total segment size
total_size=rate*segment_length;

% total download time
download_time=total_size/capacity;

end
