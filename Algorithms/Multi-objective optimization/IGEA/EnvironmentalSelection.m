function Population = EnvironmentalSelection(Population, N)
    
    [~, U_Decs, ~] = unique(Population.decs, 'rows');
    
    % up为population去重后的新种群 
    UP = Population(U_Decs);
    Objs = UP.objs;  
    Decs = UP.decs;  
    
    if length(UP) > N 
        
        SD = pdist2(Decs, Decs, 'cityblock');  
        SD(logical(eye(length(SD)))) = inf;
        [U_Objs, ~, I_Objs] = unique(Objs, 'rows'); 
        duplicated = [];
        D = size(Decs, 2);
        for i = 1 : size(U_Objs, 1)
            j = find(I_Objs == i);
            if length(j) > 1
                t = sum(Decs(j(1), :));
                d = min(SD(j, j), [], 2) / 2;  
                p = d / t;
                r = find(p < 0.8 - 0.6 * (t - 1) / (D - 1));
                if ~isempty(r)
                    duplicated = [duplicated; j(r(randperm(length(r), length(r) - 1)))];
                end
            end
        end

        
        if length(UP) - length(duplicated) > N
            UP(duplicated) = [];
            Objs = UP.objs;
        end

        % nondominated sorting
        [Front, MaxF] = NDSort(Objs, N); 
        Selected = Front < MaxF;
        Candidate = Front == MaxF;

        % Calculate crowding distance
        CD = CrowdingDistance(Objs,Front);

        % select last front
        while sum(Selected) < N
            S = Objs(Selected, 1);
            IC = find(Candidate);
            [~, ID] = sort(CD(IC), 'descend');
            IC = IC(ID);
            C = Objs(IC, 1);
            Div_Vert = zeros(1, length(C));
            for i = 1 : length(C)
                Div_Vert(i) = length(find(S == C(i)));
            end
            [~, IDiv_Vert] = sort(Div_Vert);
            IS = IC(IDiv_Vert(1));
            % reset Selected and Candidate 
            Selected(IS) = true;
            Candidate(IS) = false;
        end
        Population = UP(Selected);
    else
        Population = [UP, Population(randperm(length(Population), (N - length(UP))))];
    end
end