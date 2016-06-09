function [r_u, r_b, pen] = facl_reward(quality, prev_quality, buffer, download_time)
% FAQ_REWARD finds the reward of the FA(Q) algorithm
%
%  quality = the current segment quality
%  prev_quality = the quality of the previous segment
%  buffer = the buffer level when the segment starts
%  download_time = the download time of the current segment
%
%  r_u = the reward given by the segment quality
%  r_b = quality oscillation penalty
%  pen = buffer penalty

% buffer values
max_buffer = 22;
final_buffer = max(0,buffer-download_time);

% quality reward
r_u = 1 - quality;
r_b = abs(quality - prev_quality);

% buffer penalty
pen = b_m - final_buffer;
if(final_buffer == 0)
    pen = 50;
end
