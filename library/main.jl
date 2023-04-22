using DataFrames;
using StatsBase;
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

#=
Obtien le VIF pour une variable spécifiée
=#
function getVIF(data::DataFrame, keyVariable::Union{Symbol, String}, variables::Vector{String}) #keyVariable::Union{Symbol, String}
    formula = term(keyVariable) ~ term(1) + sum(term.(variables))
    model = lm(formula, data)
    
    return 1 / (1 - r2(model))
end;

#=
Obtien le VIF pour la combinaisons des variables spécifiées
=#
function getAllVIF(data::DataFrame, variables::Vector{String} = [] ; quantitativeVariables::Vector{String}=String[])
    df = DataFrame(Variable = String[], VIF = Float64[])

    for variable in combinations(variables, 1)
        push!(df, [variable[], getVIF(data, variable[], [setdiff(variables, variable)..., quantitativeVariables...])])
    end

    return df
end;

function getAllVIF(df::DataFrame)
    return getAllVIF(df, names(df))
end;

function convertQualitativeToQuantitative(df::DataFrame, variable::Union{Symbol, String})
    values = collect(skipmissing(sort(unique(train[!, variable]))))
    
    for value in values[2:end]
        # C'est tellement laid comme code, but, it works. Don't come for me.
        df[!, "$variable: $value"] = Matrix(select(df, variable))[:] .== value
        df[!, "$variable: $value"] = ifelse.(ismissing.(df[!, "$variable: $value"]), -1, df[!, "$variable: $value"])
        df[!, "$variable: $value"] = Int.(df[!, "$variable: $value"])
        df[!, "$variable: $value"] = ifelse.(df[!, "$variable: $value"] .== -1, missing, df[!, "$variable: $value"])
    end
end;

function getNamesForQuantitative(df::DataFrame, variable::Union{Symbol, String})
    filter(name -> match(Regex("$variable: .*"), name) != nothing, names(df))
end;

function convertQuantitativeToQualitative(df::DataFrame, variable::Union{Symbol, String}, thresholds::Vector{Float64}; new_var::Union{Symbol, String, Missing} = missing, labels::Union{Vector{String}, Missing} = missing)
    if (ismissing(labels))
        labels = string.(collect(1:(length(thresholds) - 1)))
    end

    if (ismissing(new_var))
        new_var = "$(string(variable))_category"
    end

    df[!, new_var] .= cut(df[!, variable], thresholds, labels = labels)

    df
end;

function replaceYWithXIfSus(data::DataFrame)
    data.y[ismissing.(data.y)] = data.x[ismissing.(data.y)]
    replace!(data.y, data.y.< zeros(size(data.y)) => data.x)
end

function RMSE(predictions::Vector, values::Vector)
    return sqrt(mean((predictions .- values).^2))
end
