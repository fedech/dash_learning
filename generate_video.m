function [complexities, qualities] = generate_video(c, rates, avg_scene, segments)
% GENERATE_VIDEO generate a scene sequence using an exponentially distributed 
% scene duration
%
%  coeff = scene complexity coefficients for all the possible complexity levels
%  rates = the available video bitrates
%  avg_scene = the average scene duration (in segments)
%  segments = the length of the video (in segments)
%
%  complexities = the complexity level of each segment of the generated sequence
%  qualities = the SSIM for each bitrate and segment of the generated sequence

% initialization
complexities = zeros(1, segments);
qualities = ones(segments, length(rates));
segment = 1;
old = 0;
scene = 0;

while (segment <= segments),
    % randomly choose a scene  from the c set (different from the previous one)
    while (scene == old),
        scene = randi(length(coeff(:, 1));
    end
    old = scene;
    
    % find the quality for the scene
    for rate = 2 : length(rates),
        rho = log10(rates(rate) / rates(1));
        % get the value of the polynomial for the given complexity, i.e., the 
        % quality of the next scene at the j-th bitrate 
        qual = polyval(coeff(x, :), rho);
        qualities(segment, rate) = qual;
    end
    
    % randomly draw the duration of the next scene (limited by the duration of
    % the video)
    duration = floor(exprnd(avg_scene));
    if (duration > segments),
        duration = segments;
    end
    
    % copy the quality and complexity values for the whole scene
    for rate = 2 : length(rates),
        qualities(segment : segment + duration - 1, rate) = ones(1, duration) * qualities(segment, rate);
    end
    complexities(segment : segment + duration - 1) = ones(1, duration) * scene;
    segment = segment + duration;
end

% truncate eventual extra segments from the output (just to be safe)
if (length(qualities(:, 1) > segments)),
    qualities(segments + 1 : end, :)=[];
end
if (length(complexities) > segments),
    complexities(segments + 1 : end) = [];
end

end
