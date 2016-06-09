function q_a = find_q(q, states)
% Q_A finds the Q-values for all actions for the given state vector
%
%  q = the complete Q-value matrix
%  states = the state vector - odd indices contain states, even index i+1 
%           contains the weight of state i
%
%  q_a = the Q-value vector for the given state

% initialization
q_a = zeros(1, length(q(1, :)));

% find Q-values for all states and compute overall Q-values
for s = 1 : 2 : length(states) - 1,
    if (states(s + 1) > 0),
        %weighted contribution of state state(s)
        q_a=q_a + q(states(s), :) * states(s + 1);
    end
end

end
