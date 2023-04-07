function fillDataFromAverage(data::DataFrame; is_test::Bool = false)
    avgCut = mode(dropmissing(data, :cut).cut)
    avgColor = mode(dropmissing(data, :color).color)
    avgClarity = mode(dropmissing(data, :clarity).clarity)
    avgDepth = mean(dropmissing(data, :depth).depth)
    avgTable = mean(dropmissing(data, :table).table)
    avgX = mean(dropmissing(data, :x).x)
    avgY = mean(dropmissing(data, :y).y)
    avgZ = mean(dropmissing(data, :z).z)

    replace!(data.cut, missing => avgCut)
    replace!(data.color, missing => avgColor)
    replace!(data.clarity, missing => avgClarity)
    replace!(data.depth, missing => avgDepth)
    replace!(data.table, missing => avgTable)
    replace!(data.x, missing => avgX)
    replace!(data.y, missing => avgY)
    replace!(data.z, missing => avgZ)

    if (!is_test)
        avgPrice = mean(dropmissing(data, :price).price)
        replace!(data.price, missing => avgPrice)
    end
end