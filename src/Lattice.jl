function price(model::T, level::Int64)::Array{Float64,1} where {T<:AbstractLatticeModel}

    # get network parameters -
    number_of_levels = model.number_of_levels
    branch_factor = model.branch_factor

    # get the connectivity array -
    dd = model.data
    h = (level - 1)
    k = branch_factor
    L = k^h
    number_of_rows = convert(Int, (k * L - 1) / (k - 1))

    # what is my b?
    b = range(start = -(k - 2), stop = 1, step = 1) |> collect

    # fill in connectivity -
    price_array = Array{Float64,1}()
    index_vector_reverse = reverse(range(1, stop = number_of_rows, step = 1) |> collect)
    index_vector_at_level = reverse(index_vector_reverse[1:L])
    for i ∈ index_vector_at_level
        push!(price_array, dd[i])
    end

    return price_array
end