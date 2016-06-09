function state = faq_state(capacity, buffer, segment)
% FAQ_STATE finds the state of the FA(Q) learning algorithm
%
%  capacity = the current capacity
%  buffer = the current buffer level
%  segment = the segment number

% initialization
state = 0;
capacity_levels = [300 500 1000 2000 3000 4000 6000 10000];

% special initial state
if(segment == 1),
    state = 100;
    return;
end

% quantize the buffer and capacity values
capacity_value = quantize(capacity, capacity_levels);
buffer_value = floor(1 + buffer / 2);

% find the state
state = 9 * (buffer_value - 1) + capacity_value;

end
