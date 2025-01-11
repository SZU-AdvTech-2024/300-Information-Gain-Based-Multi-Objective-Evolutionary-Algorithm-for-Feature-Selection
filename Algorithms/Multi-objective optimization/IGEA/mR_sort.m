function mrmr = mR_sort(Decs,W_IG)
    [n,~] = size(Decs);
    mrmr = zeros(1,n);
    for i = 1:n
        J = find(Decs(i,:));
        mrmr(i) = mean(W_IG(J));
    end
end