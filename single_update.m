function q = single_update(q, state, past_state, reward, action, lambda, alpha)
% SINGLE_UPDATE = update the Q-value table for a single state
%
%  q = the Q-value table at instant t
%  state = the state s_t
%  past_state = the state s_{t-1}
%  reward = the reward r_{t-1}
%  action = the chosen action a_{t-1}
%  lambda = exponential discount factor
%  alpha = learning rate
%
%  q = the updated Q-value table for instant t+1

% find the long-term reward
for i = 1 : 2 : length(state) - 1,
    if (state(i + 1) > 0),
        reward = reward + lambda * state(i + 1) * max(q(state(i), :));
    end
end

% update the Q-value for all states in the old state vector s_{t-1}
for i = 1 : 2 : length(past_state) - 1,
    if (past_state(i + 1) > 0),
        q(past_state(i), action) = q(past_state(i), action) + alpha * past_state(i + 1) * (reward - q(past_state(i), action));
    end
end

end
