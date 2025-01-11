% Information_gain 
function W_IG = Information_gain(Data)
    [~,D] = size(Data);
    D = D-1;
    %Caculate information entropy
    Class_tbl = tabulate(Data(:,end));
    %总Data中有Class_N种分类结果
    [Class_N,~] = size(Class_tbl);
    h = zeros(1,Class_N);
    for i = 1:Class_N
        h(i) = -Class_tbl(i,3)/100*log10(Class_tbl(i,3)/100);
    end
    H = sum(h);
    Ce = zeros(1,D);
    for i = 1:D
        Sample_tbl = tabulate(Data(:,i));
        %第i个特征有Sample_N种取值情况
        [Sample_N,~] = size(Sample_tbl);
        ce = 0;
        for j = 1:Sample_N
           %J1是第i个特征取到第j种取值的位置
           J1 = find(Data(:,i)==Sample_tbl(j,1));
            m = 0;
            for k = 1:Class_N
                %J2是位置为J1的样本的分类结果为k时的位置
                J2= find(Data(J1,end)==Class_tbl(k,1));
                if isempty(J2)
                   m = m - 0; 
                else
                   m = m - (length(J2)/length(J1))*log10((length(J2)/length(J1)));
                end
            end
            ce = ce + Sample_tbl(j,3)*m/100;
        end
        %Conditional entropy
        Ce(i) = ce;
    end
    %Information_gain = Information entropy - Conditional entropy
    W_IG = H - Ce;
end