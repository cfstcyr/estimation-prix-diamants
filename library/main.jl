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
    values = collect(skipmissing(sort(unique(df[!, variable]))))
    
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

function RMSE(predictions::Vector, values::Vector)
    return sqrt(mean((predictions .- values).^2))
end

function standardize(df::DataFrame)
    for col in names(df)
        df[!, col] = (df[!, col] .- mean(df[!, col])) ./ std(df[!, col])
    end
    
    return df
end;

function generateKNNModels(weight::Vector, models::Vector = [], minkowski::Vector = [])
    models_dict = Dict();
    if length(models) > 0
        for model in Models
            if model == "Euclidean"
                models_dict["euclidean_model"] = KDTree(Mat_train, WeightedEuclidean(weight));
            end
            if model == "Cityblock"
                models_dict["cityblock_model"] = KDTree(Mat_train, WeightedCityblock(weight));
            end
            if model == "Minkowski"
                if length(minkowski) > 0
                    for k in minkowski
                        models_dict["minkowski_$(k)_model"] = KDTree(Mat_train, WeightedMinkowski(weight, k));
                    end
                else
                    throw(ArgumentError("Minkowski vector required to run Minkowski models"));
                end
            end
        end
    else
        models_dict =  Dict(
            "euclidean_model" => KDTree(Mat_train, WeightedEuclidean(weight)),
            "cityblock_model" => KDTree(Mat_train, WeightedCityblock(weight)),
            "minkowski_0.5_model" => KDTree(Mat_train, WeightedMinkowski(weight, 0.5)),
            "minkowski_0.75_model" => KDTree(Mat_train, WeightedMinkowski(weight, 0.75)),
            "minkowski_1.5_model" => KDTree(Mat_train, WeightedMinkowski(weight, 1.5)),
            )
    end
    return models_dict
end;

function matrixify(data, exclusion::Vector{String})
    return Matrix(
        standardize(
            select(
                data,
                Not(exclusion),
            )
        )
    );
end

function test_models(training_data, validation_data, validation_matrix, models, k_vector)
    for k in k_vector
        println("k-neighbours: $(k)")
        for (key, value) in models

            idxs, dists = knn(value, validation_matrix, k, true)

            prediction = [
                dot(training_data.price[idxs[i]], dists[i]) / sum(dists[i])
                for i in 1:size(idxs, 1)
            ]

            rmse = RMSE(prediction, validation_data.price)

            println("\t RMSE $(key): $(round(rmse))")
        end
    end
end