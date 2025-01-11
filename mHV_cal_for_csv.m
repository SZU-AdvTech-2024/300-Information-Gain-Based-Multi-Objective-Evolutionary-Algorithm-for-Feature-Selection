clear all;
clc;

% 定义问题和算法的字符串数组
problemStr = {'CNAE9'};
algorithmStr = {'IGEA'};
problemIndex = [1];
runtime = 30;
currentPath = './result_11.19/';

% 初始化综合结果表
tableOfAll = initTableForAll(length(problemStr), length(algorithmStr), problemStr, algorithmStr);

% 遍历所有算法
for k = 1:length(algorithmStr)
    algorithmName = algorithmStr{k};
    
    % 初始化每个算法对每个问题的超体积（HV）结果
    hvResults = zeros(length(problemIndex), runtime);
    
    % 遍历所有问题
    for i = problemIndex
        disp(['Processing problem: ', num2str(i)]);
        pathOfHV = fullfile(currentPath, ['HV_', algorithmName, '_result.xls']);
        
        % 初始化HV结果表
        tableOfHV = initTableForHV(length(problemStr), problemStr, runtime);
        
        % 多次运行以获取统计数据
        for j = 1:runtime
            csvName = fullfile(currentPath, strcat(algorithmName, '-', problemStr{i}, '_', num2str(j), '.csv'));
            pop = readmatrix(csvName);
            
            % 假定第一列和第三列分别是目标函数值
            PopObj = pop(:, [1, 3]);
            optimum = [1, 1];
            
            % 计算超体积
            hvResults(i, j) = HyperV(PopObj, optimum);
        end
        
        % 更新HV统计数据
        stats = [mean(hvResults, 2), std(hvResults, 0, 2)];
        UpdateHV(tableOfHV, length(problemIndex), runtime, stats, hvResults, pathOfHV);
    end
end

function tableOfAll = initTableForAll(problemNum,algorithmNum,problem_str,algorithm_str)
    row = 2 + problemNum;
    col = 1 + 2*algorithmNum;
    tableOfAll = cell(row, col);
    for i = 3:row
        tableOfAll{i,1} = (problem_str{i-2});
    end

    for i = 1:algorithmNum
        tableOfAll{1,2*i} = (algorithm_str{i});
        tableOfAll{2,2*i} = ['Mean'];
        tableOfAll{2,2*i+1} = ['Std'];
    end
end


function tableOfHV = initTableForHV(problemNum,problem_str,runtime)
    row = 1 + problemNum;
    col = 3 + runtime;
    tableOfHV = cell(row, col); 
    for i = 2:row
        tableOfHV{i,1} = (problem_str{i-1});
    end
    tableOfHV{1,2} = ['Mean'];
    tableOfHV{1,3} = ['Std'];
end

function UpdateHV(tableOfHV,problemNum,runtime,value1,value2,currentPath)
    row = 1 + problemNum;
    col = 3 + runtime;
    MeanValue = value1(:,1);
    StdValue = value1(:,2);
    for i = 1:length(MeanValue)
        tableOfHV{i+1,2} = MeanValue(i);
        tableOfHV{i+1,3} = StdValue(i);
    end
    for i = 2:row
        for j = 4:col
            tableOfHV{i,j} = value2(i-1,j-3);
        end
    end
    writecell(tableOfHV, currentPath);
end


