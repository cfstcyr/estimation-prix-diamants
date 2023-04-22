function standardize(df::DataFrame)
    for col in names(df)
        df[!, col] = (df[!, col] .- mean(df[!, col])) ./ std(df[!, col])
    end
    
    return df
end;

function standardize(M::Matrix)
    means = mean(M, dims=1)
    stds = std(M, dims=1)
    
    for j in 1:size(M, 2)
        M[:,j] = (M[:,j] .- means[j]) ./ stds[j]
    end
    
    return M
end;

function standardize(v::Vector)
    return (v .- mean(v)) ./ std(v)
end;