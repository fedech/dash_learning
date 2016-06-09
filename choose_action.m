function [exploration, action] = choose_action(q, tau)
% CHOOSE_ACTION choose an action using the Softmax policy
% p(i)=e^(q(i)/tau)/sum_j(e^(q(j)/tau))
%
%  q = vector of Q-values for the possible actions
%  tau = exploration temperature
%
%  exploration = true if the action is exploratory, i.e. if it's not the best 
%                possible action
%  action = the index i of the chosen action  

% initialization
action = 0;
exploration = false;
ps = zeros(1, length(q));
offset = mean(q);
infinity = false;

% find best action
[max_value, max_action] = max(q);

% calculation of the p(i) vector
for i = 1 : length(q),
    ps(i) = exp((q(i) - offset) / tau);
    % raise flag if any of the exponentials overflow
    if (isinf(ps(i))),
        infinity = true;
    end
end
ps = ps / sum(ps);

% in case of overflow, just revert to a greedy policy
if (infinity),
    [q, action] = max(q);
    return;
end

% draw from the Softmax distribution using the inverse CDF
roll = rand;
while (roll > 0 && action < length(q)),
    action = action + 1;
    roll = roll - ps(action);
end

% check if the action is exploratory
if (action ~= max_action),
    exploration = true;
end

end
