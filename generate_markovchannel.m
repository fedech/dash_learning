function capacities = generate_markovchannel(initial, p_matrix, segments)
% CAPACITIES generates a Markovian channel from a given transition matrix
%
%  initial = the capacity for the first segment
%  p_matrix = the transition matrix
%  segments = the number of steps of the Markov chain
%
%  capacities = the realization of the Markovian channel

% initialization
capacity_levels = [300 500 1000 2000 3000 4000 5000 6500 8000 10000 15000];
capacities = zeros(1, segments);
capacities(1) = initial;

%find the initial state
state = quantize(initial, capacity_levels(2 : 10));

% simulate the Markov chain
for segment = 2 : segments,
    %draw the next state by inverting the CDF
    event = rand;
    for future_state = 1 : 10,
        event = event - p_matrix(state, future_state);
        if(event <= 0)
            state = future_state;
            % find the capacity corresponding to the state
            capacities(segment) = (capacity_levels(future_state) + capacity_levels(future_state + 1)) / 2;
            break;
        end
    end
end

end
