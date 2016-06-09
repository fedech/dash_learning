function level = quantize(value, levels)
% QUANTIZE quantize a continuous value for the given state borders
%
%  value = the continuous value to quantize
%  levels = the borders between quantization levels
%
%  level = the resulting quantized value

s = 1;
while (s <= length(levels) && value > levels(s)),
    %increment by one level if the value is above the current level
    level = level + 1;
end

end
