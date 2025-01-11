function Pop = InitialPop(Problem,S)
    N = Problem.N*S;
    D = Problem.D;
    T = min(D, N * 3); %real D-number
    if T < D
        Pop = zeros(N, D);
        for i = 1 : N
            k = randperm(T, 1);
            j = randperm(D, k);
            Pop(i, j) = 1;
        end
        Pop = SOLUTION(Pop); 
    else
        Pop = Problem.Initialization();
    end
end
