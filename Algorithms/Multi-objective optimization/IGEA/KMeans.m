%kmeans method
function idx = KMeans(data, K)
    [N, ~] = size(data);
    % init U
    sampleIds = randsample(1:N, K, false);    %/从n个点中随机选择K个点作为中心点
    U = data(sampleIds, :);                   %/以这三个点为中心形成簇类
    labels_u = zeros(N, 1);                   %/初始换建立一个N行1列的零数组
    stop = true;  
    while stop                                %/把true复制给stop，需要一直循环
        for i = 1:N                           %/从第1个点一直到第n个点
            x = data(i, :);                   %/读取第1个数据放到X里面
            % check label        
            label = 0;                        %/初始化label为0，代表是第几个簇类
            dist = 0;                         %/初始化dist距离为0
            for j = 1:K                       %/计算到达三个中心点的距离，依次推断属于哪个簇类
                tmp_dist = sum((x-U(j, :)).^2);        %/计算欧式距离，因比较大小，不用开根号也行
                if label == 0 || tmp_dist < dist       %/如果是第一次计算lable=0或者此时的距离小于上一次计算出的距离
                    label = j;                         %/当前的点暂时属于第j个聚类
                    dist = tmp_dist;                   %/欧式距离更新为当前的更小值
                end                                    
            end                                        %/循环结束
            if labels_u(i) ~= label                    %/如果第个i点不等于label
                stop = false;                          %/继续循环
            end
            labels_u(i) = label;                       %/第个i点属于第label个簇类
        end                                          
        if stop == true                                %/退出循环
            break;
        end
        % update U
        for j = 1:K
            U(j, :) = mean(data(labels_u == j, :));
        end
    end
    idx = labels_u;
end