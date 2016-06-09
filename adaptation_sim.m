% MARKOV_PARALLEL_SIM = simulation with a Markov channel

close all
clearvars

% initialization
runs = 50;
ntrials=10;
segments = 400;
avg_scene = 5;
parallel_stats = zeros(segments * runs, 22);
offline_stats = zeros(segments * runs, 22);
faq_stats = zeros(segments * runs, 22);
bench_stats = zeros(segments * runs, 22);
lambda = 0.9;
rates = [10000 6000 4000 3000 2000 1000 500 300];
capacities=zeros(segments);

% complexity vectors
c_matrix = zeros(5, 5);
c_matrix(1, :) = [-0.0101529728434649, -0.0288832138324094, -0.0242726545067643, 0.00415396333169108, 0.999470864310074]; %Brutta (very simple)
c_matrix(2, :) = [-0.0106444184411198, -0.0229079907856676, -0.0253096474216347, 0.000741787815715741, 0.999695979414017]; %News (simple)
c_matrix(3, :) = [-0.0105082902276503, -0.0538481485732781, -0.0821086136160996, 0.0136133264030814, 1.00032754665181]; % Bridge_far (weird)
c_matrix(4, :) = [-0.00505349968198585, 0.00553965817491702, -0.0172601861523108, 0.000220312168207077, 0.999767453624563]; % Harbor (complex)
c_matrix(5, :) = [0.00997854854814642, 0.0759046797737938, -0.0113807478426485, 0.000398673897694183, 0.999835529217596]; %Husky (very complex)

% main simulation loop
for r = 1 : ntrials,
    % load Q-value matrices
    load('./Qmats/facl_p1s2ds.mat');
    load('./Qmats/q_p1s2_ds.mat');
    load('./Qmats/q_p1s2ds_on2.mat');
    q0 = q_online;
    q_offline = q_online;
    
    % channel and video parameters (pre-adaptation)
    p_matrix = zeros(10, 10);
    p = 1;
    rho = 1;
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
    avg_scene = 50000000;
    
    % inner simulation loop
    for i = 1 : runs,
        % control printout
        if(mod(i,10)==0)
            i
        end
        
        % channel and video parameters (pre-adaptation)
        if(i>=11)
            p=1;
            state_p=[2/3 1/3];
            rho = 1;
            for j = 1 : 10,
                for k = 1 : 10,
                    pup = p / (1 + rho);
                    pdown = p * rho / (1 + rho);
                    if (j == k + 2),
                        p_matrix(j, k) = pup * state_p(2);
                    end
                    if (j == k + 1),
                        p_matrix(j, k) = pup * state_p(1);
                    end
                    if (j == k - 2),
                        p_matrix(j, k) = pdown * state_p(2);
                    end
                    if (j == k - 1),
                        p_matrix(j, k) = pdown * state_p(1);
                    end
                end
                p_matrix(j, j) = 1 - sum(p_matrix(j, :));
            end
        end
        
        % channel and video generation
        c_levels = [400 750 1500 2500 3500 4500 5750 7250 9000 12500];
        initial = c_levels(randi(10));
        [complexities, qualities] = generate_video(c_matrix, rates, avg_scene, segments);
        capacities = generate_markovchannel(initial, p_matrix, segments);
        
        %simulation
        alpha_on = 0.05;
        tau_on = 0.002;
        alpha_off = 0;
        tau_off = 0;
        [q_faq, stats] = faq_episode(q_faq, rates, segments, qualities, complexities, capacities, alpha_on, 0.1, tau_on, 0, 1, 0);
        faq_stats(1 + segments * (i - 1) : segments * i, :) = faq_stats(1 + segments * (i - 1) : segments * i, :) + stats;
        [q_offline, stats]=episode(q_offline, rates, segments, qualities, complexities, capacities, alpha_off, lambda, tau_off, 1, 1, 0);
        offline_stats(1 + segments * (i - 1) : segments * i, :) = offline_stats(1 + segments * (i - 1) : segments * i, :) + stats;
        [q_online, stats] = episode(q_online, rates, segments, qualities, complexities, capacities, alpha_on, lambda, tau_on, 1, 1, 0);
        online_stats(1 + segments * (i - 1) : segments * i, :) = online_stats(1 + segments * (i - 1) : segments * i, :) + stats;
        [q0, stats] = episode(q0, rates, segments, qualities, complexities, capacities, alpha_on, lambda, tau_on, 1, 1, 1);
        bench_stats(1 + segments * (i - 1) : segments * i, :) = bench_stats(1 + segments * (i - 1) : segments * i, :) + stats;
    end
end

bench_stats = bench_stats / ntrials;
offline_stats = offline_stats / ntrials;
faq_stats = faq_stats / ntrials;
online_stats = online_stats / ntrials;
