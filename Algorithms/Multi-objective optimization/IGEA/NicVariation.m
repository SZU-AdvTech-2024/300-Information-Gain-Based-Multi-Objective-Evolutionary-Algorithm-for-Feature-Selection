function Offspring = NicVariation(Population, W_IG)
    Decs = Population.decs; % Decision variables of the population
    [N, D] = size(Decs); % Number of individuals (N) and decision variables (D)
    
    % K-means method for dividing the population into 2 groups
    K = 2;
    idx = KMeans(Decs, K); % Perform k-means clustering
    Group_1 = find(idx == 1); % Individuals in the first group
    Group_2 = find(idx == 2); % Individuals in the second group
    
    IP_1 = 1:N; % Original indices of parents
    IP_2 = zeros(1, N); % Indices for crossover partners
    
    % Assign crossover partners
    for i = 1:N
        if length(Group_1) == 1 || length(Group_2) == 1
            IP = setdiff(IP_1, i); % Avoid self-crossover
            IP_2(i) = IP(randi(length(IP), 1)); % Random partner
        else
            % Cross different groups
            IP_2(i) = ismember(i, Group_1) * Group_2(randi(length(Group_2), 1)) + ...
                      ismember(i, Group_2) * Group_1(randi(length(Group_1), 1));
        end
    end
    
    % Prepare parents for crossover
    Parent1 = Decs(IP_1, :);
    Parent2 = Decs(IP_2, :);
    Offspring = zeros(N, D); % Initialize offspring population
    
    %% Crossover
    for i = 1:N
        Off = Parent1(i, :); % Start with parent 1's genes
        diffGenes = find(Parent1(i, :) ~= Parent2(i, :)); % Genes that differ
        
        if numel(diffGenes) > 1 % If there's more than one gene that differs
            if rand < 0.5
                % Swap a random segment between parents
                swapIndices = sort(randsample(diffGenes, 2));
                Off(swapIndices(1):swapIndices(2)) = Parent2(i, swapIndices(1):swapIndices(2));
            else
                % Randomly set a number of differing genes to 1
                Off(randsample(diffGenes, 2)) = 1;
            end
        end
        Offspring(i, :) = Off; % Assign offspring
    end

    %% Boundary detection - Ensure at least one gene is active
    Offspring(~any(Offspring, 2), randi(D, [sum(~any(Offspring, 2)), 1])) = 1;

    %% Mutation
    for i = 1:N
        activeGenes = find(Offspring(i, :)); % Indices of active genes
        inactiveGenes = find(~Offspring(i, :)); % Indices of inactive genes
        
        % Adjust K based on population size
        K = 2 + (N > 100) + (N >= 200);
        
        if numel(activeGenes) >= numel(inactiveGenes)
            % Tournament selection for deactivation
            mutationIndex = TournamentSelection(K, 1, -W_IG(activeGenes));
            Offspring(i, activeGenes(mutationIndex)) = false;
        else
            % Tournament selection for activation
            mutationIndex = TournamentSelection(K, 1, W_IG(inactiveGenes));
            Offspring(i, inactiveGenes(mutationIndex)) = true;
        end
    end
    
    Offspring = SOLUTION(Offspring); % Wrap offspring in SOLUTION objects
end
