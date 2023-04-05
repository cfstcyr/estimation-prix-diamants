using DataFrames;

#=
Sépare les lignes données en deux parties selon un ratio
=#
function partitionData(data::DataFrame, ratio::Float64)
    n_train = trunc(Int, nrow(data) * ratio)

    train_rows = sample(1:nrow(data), n_train, replace=false, ordered=true)
    valid_rows = setdiff(1:nrow(data), train_rows);

    train = data[train_rows, :]
    valid = data[valid_rows, :]

    return train, valid
end