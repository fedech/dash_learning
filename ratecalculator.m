% find the average capacity for a given increase/decrease rate rho and
% transition probability for a Markovian channel

rho = 0.667;
transition_p = 1;

% steady-state matrix
expsum = 0;
for i = 0 : 10,
    expsum = expsum + rho ^ i;
end

% calculate transition matrix
p_matrix = zeros(1, 11);
p(1) = 1 / expsum;
for i = 2 : 11,
    p(i) = p(i - 1) * transition_p * rho;
end

% calculate average capacity
rates = [300 500 1000 2000 3000 4000 5000 6500 8000 10000 15000];
rate = sum(p .* rates)
