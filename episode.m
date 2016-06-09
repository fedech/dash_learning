function [q, stats] = episode(q, rates, segments, qualities, complexities, capacities, alpha, lambda, tau, parallel, markov, benchmark)
% EPISODE = a video episode using the learner
%
%  q = initial Q-value table
%  rates = the available video bitrates
%  segments = the length of the video in segments
%  qualities = the quality matrix for every segment and every bitrate
%  complexities = vector of the complexity indexes
%  capacities = channel vector
%  alpha = learning rate for the episode
%  lambda = exponential discount factor
%  tau = exploration temperature for the episode
%  parallel = 1 if the learner performs parallel updates
%  markov = 1 if the channel is Markovian, 0 if its values are given at
%           10ms intervals
%  benchmark = 1 if the client uses the rate-based benchmark algorithm
%
%  q = the updated Q-value table at the end of the episode
%  stats = a matrix containing the episode statistic. The columns contain, for 
%          each segment:
%          s_t (1) | w_t (1) | s_t (2) | w_t (2) | h_t | a_t | B_t | r_t | q_t |
%          r_t^q | r_t^b (1) | r_t^b (2) | t | exp | Q(s_t, *)
%          (s_t is divided into the components of the linear combination, and 
%          the two parts of r_t^b are given separately; exp is 1 if the action 
%          is exploratory)

% initialization
timer = 0;
buffer = 0;
last_update = 1;
download_time = 0;
update = false;
stats = zeros(segments, 22);

% segment-by-segment decision loop
for segment = 1 : segments,
    
    % state value initialization (necessary for segment 1)
    capacity = 0;
    old_capacity = 0;
    prev_quality = 0;
    
    % state value retrieval
    if(segment > 1),
        capacity = stats(segment - 1, 5);
        old_capacity = stats(max(segment - 2, 1), 5);
        prev_quality = stats(segment - 1, 8);
    end
    % state calculation
    states = find_state(capacity, old_capacity, prev_quality, complexities(segment), buffer, parallel, segment);
    % stat collection: s_t
    stats(segment, 1 : 4) = states;
    
    % Q-value update for the offline algorithm
    if (parallel + benchmark == 0 && (update || segment == segments)),
        q = update_q(q, segment, last_update, stats(:, 1 : 4), stats(:, 6), stats(:, 8), lambda, alpha);
        last_update = segment;
    end
    
    % parallel Q-value update
    if (parallel == 1 && benchmark == 0 && segment > 1),
        q = parallel_update(q, states, stats(segment - 1, 1 : 4), prev_quality, stats(segment - 1, 6), stats(segment - 1, 8), download_time, capacity, complexities(segment), lambda, alpha);
    end
        
    % action selection
    if (benchmark == 0),
        % learner: Softmax policy
        q_a = find_q(q, states);
        stats(segment, 15 : 22) = q_a;
        [update, action] = choose_action(q_a, tau);
    else
        % benchmark: rate-based policy
        action = 8;
        if(segment > 1)
            while (action > 1 && rates(action - 1) <= capacity),
                action = action - 1;
            end
        end
    end
    
    % stat collection: a_t and exp
    stats(segment, 6) = action;
    if (update),
        stats(segment, 14) = 1;
    end
    
    %Segment download (for Markovian and instantaneous channels)
    if (markov == 1),
        download_time = download_markov(rates(action), capacities(segment));
        stats(segment, 5) = capacities(segment);
    else
        [download_time, stats(segment, 5)] = download_step(capacities, rate, timer);
    end
    
    % reward calculation and stat collection
    stats(segment, 9) = qualities(segment, action);
    if (segment > 1),
        [r_u, r_b, pen] = find_reward(stats(segment, 9), stats(segment - 1, 9), buffer, download_time);
        stats(segment, 10) = r_u;
        stats(segment, 11) = r_b;
        stats(segment, 12) = pen;
    end
    stats(segment, 8) = stats(segment, 9) - stats(segment, 10) - stats(segment, 11) - stats(segment, 12);
    
    % buffer update
    buffer = max(0, buffer - download_time) + 2;
    timer = timer + download_time;
    % buffer overflow control
    if (buffer > 20),
        timer = timer + 2 - download_time;
        buffer = buffer - 2 + download_time;
    end
    stats(segment, 7) = buffer;
    stats(segment, 13) = timer;
end

end
