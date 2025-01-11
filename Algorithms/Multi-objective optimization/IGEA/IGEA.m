classdef IGEA < ALGORITHM
    % IGEA - An Algorithm Class for implementing Information Gain based Evolutionary Algorithm
    % This class defines the structure and main operations of an evolutionary algorithm
    % that utilizes information gain as a weighting mechanism for crossover and mutation.

    methods
        function main(Algorithm, Problem)
            % Main method of the algorithm
            % It sets up the algorithm parameters, initializes the population,
            % and iterates through the main loop until termination criteria are met.

            % 保存路径
            [save_path] = Algorithm.ParameterSet('./');

            % 训练集和标签
            train = Problem.TrainIn;
            label = Problem.TrainOut;

            % 算IG并正则化
            Information_data = [train, label];
            IG = Information_gain(Information_data);
            W_IG = (IG - min(IG)) ./ (max(IG) - min(IG));

            % 初始化种群
            Population = InitialPop(Problem, 1);

            % Main loop of the algorithm
            % 主要循环
            while Algorithm.NotTerminated(Population)
                % Generate offspring using variation operators and information gain weights
                % 生成后代
                Off = NicVariation(Population, W_IG);

                % Environmental selection to form the next generation
                % 种群选择
                Population = EnvironmentalSelection([Population, Off], Problem.N);
            end

            % Handling results
            final = Population.decs;
            p = zeros(Problem.N, 1);
            for idx = 1:Problem.N
                s = logical(final(idx, :));
                % Ensure at least one feature is selected
                % 保证至少选了一个特征
                while sum(s) == 0
                    s = logical(round(rand(1, size(s, 2))));
                end
                % Fit KNN model and predict validation set
                mdltest = fitcknn(train(:, s), label, 'NumNeighbors', 5);
                c = predict(mdltest, Problem.ValidIn(:, s));
                % Calculate prediction accuracy
                % 计算验证集错误率
                p(idx, 1) = 1 - length(find(c == Problem.ValidOut)) / length(c);
            end

            % Compile results and write to a CSV file
            p = [Population.objs, p, final];
            dir_name = class(Algorithm);
            xls_name = strcat(dir_name, '-', Problem.str{Problem.problem_id}, '_', num2str(Problem.number), '.csv');
            writematrix(p, fullfile(save_path, xls_name));
        end
    end
end
