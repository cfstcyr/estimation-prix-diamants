using DataFrames;

function partitionData(data::DataFrame, ratio::Float64)
    n_data = trunc(Int, nrow(data) * ratio)
    n_validate = nrow(data) - n_data

    validation = last(data, n_validate)
    data = first(data, n_data)

    return (; data, validation)
end