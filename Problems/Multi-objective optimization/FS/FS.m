    classdef FS < PROBLEM
        %FS Feature Selection Problem Class
        % This class defines the feature selection problem, including data loading,
        % preprocessing, and objective function evaluation.

        properties
            TrainIn;    % Training set input
            TrainOut;   % Training set output
            ValidIn;    % Validation set input
            ValidOut;   % Validation set output
            Category;   % Output label set
            str = {'CNAE9'}; % Default dataset identifier
            Data;       % Loaded dataset
            problem_id = 1; % Dataset identifier
            number = 1; % Additional parameter, usage depends on specific needs
        end

        methods
            function Setting(obj)
                % Setting Method for initializing problem settings
                % It includes parameter setting, data loading, and preprocessing.

                % Parameter setting (assuming ParameterSet is a method defined elsewhere)
                [obj.str, obj.problem_id, obj.number, norm_flag] = obj.ParameterSet({'CNAE9'}, 1, 1, 1);

                % Load dataset
                Datasets = load('CNAE9.mat');
                obj.Data = Datasets.(obj.str{1});

                % Data normalization (if required)
                if norm_flag == 1
                    Fmin = min(obj.Data(:,1:end-1), [], 1);
                    Fmax = max(obj.Data(:,1:end-1), [], 1);
                    obj.Data(:,1:end-1) = bsxfun(@rdivide, bsxfun(@minus, obj.Data(:,1:end-1), Fmin), Fmax - Fmin);
                end
                
                
                % Extract unique categories and partition dataset into training and validation sets
                % 分割训练集和验证集
                obj.Category = unique(obj.Data(:, end));
                splitIndex = ceil(size(obj.Data, 1) * 0.7);
                obj.TrainIn = obj.Data(1:splitIndex, 1:end-1);
                obj.TrainOut = obj.Data(1:splitIndex, end);
                obj.ValidIn = obj.Data(splitIndex+1:end, 1:end-1);
                obj.ValidOut = obj.Data(splitIndex+1:end, end);

                % Set problem dimensions and encoding
                obj.M = 2; % Number of objectives
                obj.D = size(obj.TrainIn, 2); % Dimensionality (number of features)
                obj.encoding = 'binary'; % Encoding of solution (binary for feature selection)
            end

            function PopObj = CalObj(obj, PopDec)
                % Calculate Objective Function for the population
                % This function evaluates the objective values for each individual in the population.

                PopDec = logical(PopDec); % Ensure binary representation
                PopObj = zeros(size(PopDec, 1), 2); % Initialize objective value matrix

                for i = 1 : size(PopObj, 1)
                    % Ensure no feature subset is empty
                    if all(PopDec(i,:) == 0)
                        PopDec(i,:) = round(rand(1 , obj.D));
                    end

                    % Use KNN for classification
                    mdltest = fitcknn(obj.TrainIn(:,PopDec(i,:)), obj.TrainOut, 'NumNeighbors', 5);
                    c = crossval(mdltest, 'KFold', 10); % 10-fold cross-validation

                    % Objective 1: Minimize the feature subset size (here, the mean is used as an example)
                    % Objective 2: Minimize the validation error
                    PopObj(i,1) = mean(PopDec(i,:));
                    PopObj(i,2) = kfoldLoss(c);
                end
            end

        end
    end
