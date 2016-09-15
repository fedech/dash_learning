% MARKOV_SINGLE_SIM = simulation with a Markov channel

close all
clearvars

% initialization
training = true;
runs = 100;
if (training),
    runs = 100;
end
segments = 400;
avg_scene = 5;
trained_stats = zeros(segments * runs, 22);
untrained_stats = zeros(segments, 22);
bench_stats = zeros(segments * runs, 22);
lambda = 0.9;
rates = [10000 6000 4000 3000 2000 1000 500 300];
q = ones(25001, length(rates)) / (1 - lambda);

% complexity vectors
c_matrix = zeros(5, 5);
c_matrix(1, :) = [-0.0101529728434649, -0.0288832138324094, -0.0242726545067643, 0.00415396333169108, 0.999470864310074]; %Brutta (very simple)
c_matrix(2, :) = [-0.0106444184411198, -0.0229079907856676, -0.0253096474216347, 0.000741787815715741, 0.999695979414017]; %News (simple)
c_matrix(3, :) = [-0.0105082902276503, -0.0538481485732781, -0.0821086136160996, 0.0136133264030814, 1.00032754665181]; % Bridge_far (weird)
c_matrix(4, :) = [-0.00505349968198585, 0.00553965817491702, -0.0172601861523108, 0.000220312168207077, 0.999767453624563]; % Harbor (complex)
c_matrix(5, :) = [0.00997854854814642, 0.0759046797737938, -0.0113807478426485, 0.000398673897694183, 0.999835529217596]; %Husky (very complex)

% load trained matrix
if (~training),
    load('./Summarymats/q_p1s1a12000_d5.mat')
    q_trained = q_offline;
end

% transition matrix for the Markovian channel
p_matrix = zeros(10, 10);
p = 1;
% increase/decrease rate
rho = 1;
state_p = [2 / 3 1 / 3];
for i = 1 : 10,
    for j = 1 : 10,
        pup = p / (1 + rho);
        pdown = p * rho / (1 + rho);
        if (i == j + 2),
            p_matrix(i, j) = pup * state_p(2);
        end
        if (i == j + 1),
            p_matrix(i, j) = pup * state_p(1);
        end
        if (i == j - 2),
            p_matrix(i, j) = pdown * state_p(2);
        end
        if (i == j - 1),
            p_matrix(i, j) = pdown * state_p(1);
        end
    end
    p_matrix(i, i) = 1 - sum(p_matrix(i, :));
end

% episode loop
for i = 1 : runs,
    % control printout
    if (mod(i, 10) == 0),
        i
    end
    

    % channel and video generation
    c_levels = [400 750 1500 2500 3500 4500 5750 7250 9000 12500];
    initial = c_levels(randi(10));
    [complexities, qualities] = generate_video(c_matrix, rates, avg_scene, segments);
    capacities = generate_markovchannel(initial, p_matrix, segments);

    %simulation
    alpha = 0.05;
    tau_t = 0.002;
    tau = max(tau_t, 0.4 / ceil(i / 3));
    alpha_t = 0.002;
    if (training),
        [q, untrained_stats] = episode(q, rates, segments, qualities, complexities, capacities, alpha, lambda, tau, 0, 1, 0);
    else
        [q_trained, trained_stats(1 : segments, :)] = episode(q_trained, rates, segments, qualities, complexities, capacities, alpha_t, lambda, tau_t, 0, 1, 0);
        [q0, bench_stats(1 : segments, :)] = episode(q, rates, segments, qualities, complexities, capacities, alpha, lambda, tau, 1, 1, 1);
    end
end
if (training),
    q_offline = q;
    save('q_p1s2d5.mat','q_offline');
end
