clc;
clear all;

problem_str  = {'CNAE9'};

algorithm_str = {'IGEA'};
currentPath = './result_11.19/';
problemIndex = [1];
runtime = 30;

All1 = []; All2 = []; All3 = []; All4 = [];
tableOfAll_MCE_train = initTableforAll(length(problem_str), length(algorithm_str), problem_str, algorithm_str);
pathOfAll_MCE_test = ['./MCE/All_MCE_test.xlsx'];
tableOfAll_MCE_test = initTableforAll(length(problem_str), length(algorithm_str), problem_str, algorithm_str);
pathOfAll_Ratio_train = ['./MCE/All_Ratio_train.xlsx'];
tableOfAll_Ratio_test = initTableforAll(length(problem_str), length(algorithm_str), problem_str, algorithm_str);
pathOfAll_Ratio_test = ['./MCE/All_Ratio_test.xlsx'];


for k = 1:length(algorithm_str)
    dir_name = algorithm_str{k};
    algorithm_name = algorithm_str{k};
    for i = problemIndex
        disp([num2str(dir_name),'| i=',num2str(i)]);
        pathOfMCE_train = ['./',algorithm_name,'_MCE_train.xlsx'];
        tableOfMCE_train = initTable(length(problem_str),problem_str,runtime);

        pathOfMCE_test = ['./',algorithm_name,'_MCE_test.xlsx'];
        tableOfMCE_test = initTable(length(problem_str),problem_str,runtime);

        pathOfRatio_train = ['./',algorithm_name,'_Ratio_train.xlsx'];
        tableOfRatio_train = initTable(length(problem_str),problem_str,runtime);

        pathOfRatio_test = ['./',algorithm_name,'_Ratio_test.xlsx'];
        tableOfRatio_test = initTable(length(problem_str),problem_str,runtime);
        pop=[];
        PopObj=[];
        for j = 1:runtime
            pop=readmatrix([currentPath,dir_name,'-',problem_str{i},'_',num2str(j),'.csv']);
            [x,y]=size(pop);
            [mce_train(i,j),index1]=min(pop(:,2));
            [mce_test(i,j),index2]=min(pop(:,3));
            ratio_train(i,j)=sum(pop(index1,3:end))/(y-2);
            ratio_test(i,j)=sum(pop(index2,3:end))/(y-2);
        end
    end
    a1(:,1)=mean(mce_train,2);
    a1(:,2)=std(mce_train,[],2);
    a2(:,1)=mean(mce_test,2);
    a2(:,2)=std(mce_test,[],2);
    a3(:,1)=mean(ratio_train,2);
    a3(:,2)=std(ratio_train,[],2);
    a4(:,1)=mean(ratio_test,2);
    a4(:,2)=std(ratio_test,[],2);

%     UpdateT(tableOfMCE_train,length(problemIndex),runtime,a1,mce_train,pathOfMCE_train);
    UpdateT(tableOfMCE_test,length(problemIndex),runtime,a2,mce_test,pathOfMCE_test);
%     UpdateT(tableOfRatio_train,length(problemIndex),runtime,a3,ratio_train,pathOfRatio_train);
    UpdateT(tableOfRatio_test,length(problemIndex),runtime,a4,ratio_test,pathOfRatio_test);

    All1 = [All1,a1];
    All2 = [All2,a2];
    All3 = [All3,a3];
    All4 = [All4,a4];
end
UpdateAll(tableOfAll_MCE_test,All2,pathOfAll_MCE_test);
UpdateAll(tableOfAll_Ratio_test,All4,pathOfAll_Ratio_test);

function T = initTable(problemNum, problem_str, runtime)
row = 1 + problemNum;
col = 3 + runtime;
T = cell(row, col);
for i = 2:row
    T{i, 1} = (problem_str{i-1});
end
T{1, 2} = ['Mean'];
T{1, 3} = ['Std'];
end

function UpdateT(T, problemNum, runtime, value1, value2, currentPath)
row = 1 + problemNum;
col = 3 + runtime;
MeanValue = value1(:, 1);
StdValue = value1(:, 2);
for i = 1:length(MeanValue)
    T{i+1, 2} = MeanValue(i);
    T{i+1, 3} = StdValue(i);
end
for i = 2:row
    for j = 4:col
        T{i, j} = value2(i-1, j-3);
    end
end
writecell(T,currentPath);

end

function tableOfAll = initTableforAll(problemNum, algorithmNum, problem_str, algorithm_str)
row = 2 + problemNum;
col = 1 + 2 * algorithmNum;
tableOfAll = cell(row, col);
for i = 3:row
    tableOfAll{i, 1} = (problem_str{i-2});
end

for i = 1:algorithmNum
    tableOfAll{1, 2*i} = (algorithm_str{i});
    tableOfAll{2, 2*i} = ['Mean'];
    tableOfAll{2, 2*i+1} = ['Std'];
end
end

function UpdateAll(tableOfAll, value, currentPath)
[a, b] = size(value);
for i = 1:a
    for j = 1:b
        tableOfAll{i+2, j+1} = value(i, j);
    end
end
writecell(tableOfAll,currentPath);
end