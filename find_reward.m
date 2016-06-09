function [r_u, r_b, pen] = find_reward(quality, prev_quality, buffer, download_time)
% FAQ_REWARD finds the reward of the FA(Q) algorithm (except for the quality 
% component)
%
%  quality = the current segment quality
%  prev_quality = the quality of the previous segment
%  buffer = the buffer level when the segment starts
%  download_time = the download time of the current segment
%
%  r_u = quality oscillation penalty
%  r_b = low buffer penalty
%  pen = rebuffering penalty

% parameter initialization
beta = 2;
gamma = 50;
delta = 0.001;
safe_buffer = 10;

% buffer and rebuffering time calculation
final_buffer =  max(0, buffer - download_time);
rebuffering = max(0, download_time - buffer);

% reward calculation
r_u = beta * abs(quality - prev_quality);
r_b = delta*max(0, safe_buffer - final_buffer) ^ 2;
pen = min(gamma * rebuffering, 1);
