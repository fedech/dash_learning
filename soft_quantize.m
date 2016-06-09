function [second_value, p2]=soft_quantize(value,levels,window)
% SOFT_QUANTIZE = quantize a value with linear soft borders
%
%  value = the value to quantize
%  levels = the level border vector
%  window = the width of the soft border (in [0,0.5])
%
%  second_value = the second state level
%  p2 = the weight of the second factor

% find the first value and initialize
first_value = quantize(value, levels);
second_value = 0;
p2 = 0;
lower_distance = 0.5;

% the lowest level has no lower border
if (first_value == 1),
    value = value - levels(1) / 2;
else
    value = value - levels(first_value - 1);
end

% calculate the distance from the lower border
if (first_value <= length(levels) && first_value > 1),
    lower_distance = value / (levels(first_value) - levels(first_value-1));
end

% special cases: lowest and highest level
if (first_value == 1),
    lower_distance = value / (levels(first_value + 1) - levels(first_value));
end
if (first_value > length(levels)),
    lower_distance = value / (levels(first_value - 1) - levels(first_value - 2));
end

% find the weight of the linear combination if the second level is lower
if (lower_distance < window && first_value > 1),
    second_value = first_value - 1;
    p2 = 0.5 - 0.5 * lower_distance / window;
end

% find the weight of the linear combination if the second level is higher
if (1 - lower_distance < window && first_value <= length(levels)),
    second_value = first_value + 1;
    p2 = 0.5 - 0.5 * (1 - lower_distance) / window;
end

end
