function states = find_state( capacity, prev_capacity, prev_quality, complexity, buffer, online, segment )
% STATES = find the state of the MDP
%
%  capacity = the capacity for the last segment (h_{t-1})
%  prev_capacity = the capacity for the second-to-last segment (h_{t-2})
%  prev_quality = the quality (SSIM) of the last segment (q_{t-1})
%  complexity = the complexity index of the next segment (D_t)
%  buffer = the buffer level (B_t)
%  online = false if the learner is offline
%  segment = the segment number
%
%  states = state vector

% state limit values
buffer_levels = [3 4 5 6 8 10 12 15 18];
capacity_levels = [500 1000 2000 3000 4000 5000 6500 8000 10000];
quality_levels = [0.84 0.87 0.9 0.92 0.94 0.96 0.98 0.99 0.995];
cvar_levels = [-1 -1/3 1/3 1];
window = 0.25;

% special state for the first segment
if (segment == 1),
    if (online == 1),
        states = [5001 1 0 0];
    else
        states = [25001 1 0 0];
    end
    return;
end

% find the state level
buffer_value = quantize(buffer, buffer_levels);
capacity_value = quantize(capacity, capacity_levels);
quality_value = quantize(prev_quality, quality_levels);

% find the soft border linear combination between states
[second_capacity, p2] = soft_quantize(capacity, capacity_levels, window);

% if the algorithm is offline, find the correct state for h_{t-2}
cvar_value = 1;
if (online == 0),
    old_capacity = quantize(prev_capacity, capacity_levels);
    [second_old, p2old] = soft_quantize(prev_capacity, capacity_levels, window);

    current_state = capacity_value * (1 - p2) + second_capacity * p2;
    old_state = old_capacity * (1 - p2old) + second_old * p2old;
    cvar = current_state - old_state;
    cvar_value = quantize(cvar, cvar_levels);
end

% combine the values to find the state number
state = 10 * (complexity - 1) + 50 * (buffer_value - 1) + 500 * (quality_value - 1) + 5000 * (cvar_value - 1);

% linear combination (soft borders)
states(1) = capacity_value+state;
states(2) = 1 - p2;
if (p2 > 0),
    states(3) = second_capacity + state;
end
states(4) = p2;

end
