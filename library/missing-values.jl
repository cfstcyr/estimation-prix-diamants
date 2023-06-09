function fillDataFromAverage(df::DataFrame; columns::Vector = [], qualitativeColumns::Vector = [])
    for col in columns
        v = mean(dropmissing(df, col)[!, col])
        replace!(df[!, col], missing => v)
    end

    for col in qualitativeColumns
        v = mode(dropmissing(df, col)[!, col])
        replace!(df[!, col], missing => v)
    end
    
    df
end

function replaceValuesNaive(df::DataFrame)
    df.y = ifelse.(ismissing.(df.y) .|| df.y .< 0.05, df.x, df.y)
    df.depth = ifelse.(ismissing.(df.depth) .|| df.depth .< 0.05, 2 .* df.z ./ (df.x .+ df.y) .* 100, df.depth)

    cutMode = mode(dropmissing(df, :cut).cut)
    replace!(df.cut, missing => cutMode)
end

function replaceValuesRegression(df::DataFrame; ignoreCut = false)
    M_y = lm(@formula(y ~ x + table), df)
    predic_y = predict(M_y, df)

    df.y = ifelse.(ismissing.(df.y) .|| df.y .< 0.05, predic_y, df.y)
    df.depth = ifelse.(ismissing.(df.depth) .|| df.depth .< 0.05, 2 .* df.z ./ (df.x .+ df.y) .* 100, df.depth)

    if !ignoreCut
        columns = ["cut: Good", "cut: Ideal", "cut: Premium", "cut: Very Good"]

        for col in columns
            M = lm(term(col) ~ term(:color) + term(:clarity) + term(:x), df)
            predictions = predict(M, df)

            df[!, col] = ifelse.(ismissing.(df[!, col]), predictions, df[!, col])
        end
    end
end

function replaceYWithXIfSus(data::DataFrame)
    data.y[ismissing.(data.y)] = data.x[ismissing.(data.y)]
    replace!(data.y, data.y.< zeros(size(data.y)) => data.x)
end