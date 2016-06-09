function q = online_update( q, state, past_state, quality, action, reward, download_time, capacity, complexity, lambda, alpha )
% ONLINE_UPDATE = parallel update for all relevant states
%
%  q = the Q-value table at instant t
%  state = the state s_t
%  past_state = the state s_{t-1}
%  quality = the quality for the chosen action (q_{t-1})
%  action = the chosen action a_{t-1}
%  reward = the reward r_{t-1}
%  download_time = the download time for segment L_{t-1}
%  capacity = the channel capacity h_{t-1}
%  complexity = the complexity D_{t-1}
%  lambda = exponential discount factor
%  alpha = learning rate
%
%  q = the updated Q-value table for instant t+1

% state mean values for buffer and quality
buffers = [2.5 3.5 4.5 5.5 7 9 11 13.5 16.5 19];
qual = [0.82 0.855 0.885 0.91 0.93 0.95 0.97 0.985 0.9925 0.9975];

% fixed part of the state (capacity and complexity)
fixed = mod(state, 50);
past_fixed = mod(past_state, 50);
if (fixed(1) == 0),
    fixed(1) = 50;
end
if (past_fixed(1) == 0),
    past_fixed(1) = 50;
end
if (fixed(3) == 0 && fixed(4)>0),
    fixed(3) = 50;
end
if (past_fixed(3) == 0 && past_fixed(4)>0),
    past_fixed(3) = 50;
end

% real update
q = single_update(q, state, past_state, reward, action, lambda, alpha);

% fictitious updates in parallel
for i = 0 : 50 : length(q(:, 1)) - 2,
    % skip the real state
    if (i == state(1) - mod(state(1), 50)),
        continue;
    end
    
    % choose fictitious state and calculate reward
    buffer = buffers(1 + floor(mod(i, 500) / 50));
    past_quality = qual(1 + floor(i / 500));
    [r_u, r_b, pen] = find_reward(quality, past_quality, buffer, download_time);
    reward = quality - r_u - r_b - pen;
    % find fictitious state numbers
    hyp_state = find_state(capacity, 0, quality, complexity, max(buffer - download_time, 0) + 2, 1, 2);
    hyp_past = past_fixed + [i 0 i 0];
    q = single_update(q, hyp_state, hyp_past, reward, action, lambda, alpha);
end

end
