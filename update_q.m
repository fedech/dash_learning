function q = update_q(q, step, last_update, states, actions, rewards, lambda, alpha)
% Q_UPDATE update Q-values (with eligibility traces)
%
%  q = the Q-value matrix
%  step = the current time step
%  last_update = time step of the last update
%  states = vector with the states for all past time steps
%  actions = vector of past actions
%  rewards = vector of past rewards
%  lambda = exponential discount coefficient
%  alpha = learning rate
%
%  q = updated Q-value matrix

% initialization
reward = 0;
for s = 1 : 2 : length(states(step, :)) - 1,
    if (states(step, s + 1) > 0),
        % calculate expected long-term reward for current step
        reward = reward + states(step, s + 1) * max(q(states(step, s), :));
    end
end

% update Q-values for all current states
for s = 1 : 2 : length(states(step, :)) - 1,
    if (states(step, s + 1 )> 0),
        q(states(step, s), actions(step)) = q(states(step, s), actions(step)) + alpha * states(step, s + 1) * (reward - q(states(step, s), actions(step)));
    end
end

% eligibility trave
for t = step - 1 : -1 : last_update,
    % long-term reward for timestep t
    reward = reward * lambda + rewards(t);
    
    % update Q-values for all states at timestep t
    for s = 1 : 2 : length(states(t, :)) - 1,
        if (states(t, s + 1 )> 0),
            q(states(t, s), actions(t)) = q(states(t, s), actions(t)) + alpha * states(t, s + 1) * (reward - q(states(t, s), actions(t)));
        end
    end
end
