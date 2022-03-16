function price(selector::Function, model::T, level::Int64)::Array{Float64,1} where {T<:AbstractLatticeModel}

    # get network parameters -
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

        # grab the price value -
        price_value = selector(dd, i)

        # cache -
        push!(price_array, price_value)
    end

    return price_array
end

function premium(contract::T, model::CRRLatticeModel) where {T<:AbstractDerivativeContractModel}

    # initialize -
    tree_value_array = model.data
    connectivity_index_array = model.connectivity

    # add other stuff -
    p = model.p
    μ = model.μ
    ΔT = model.ΔT
    dfactor = exp(-μ * ΔT)

    # size -
    total_number_of_lattice_nodes = connectivity_index_array[end, end]
    number_of_nodes_to_evaluate = connectivity_index_array[end, 1]

    # Next: compute the intrinsice value for each node -
    for node_index = 1:total_number_of_lattice_nodes

        # ok, get the underlying price -
        underlying_price_value = tree_value_array[node_index, 1]

        # compute the intrinsic value -
        iv_value = intrinsic(contract, underlying_price_value)

        # capture - 
        tree_value_array[node_index, 2] = iv_value
        tree_value_array[node_index, 3] = iv_value
    end

    # Last: compute the option price -
    reverse_node_index_array = range(number_of_nodes_to_evaluate, stop = 1, step = -1) |> collect
    for (_, parent_node_index) in enumerate(reverse_node_index_array)

        # ok, get the connected node indexes -
        up_node_index = connectivity_index_array[parent_node_index, 2]
        down_node_index = connectivity_index_array[parent_node_index, 3]

        # ok, let's compute the payback *if* we continue -
        future_payback = dfactor * (p * tree_value_array[up_node_index, 3] + (1 - p) * tree_value_array[down_node_index, 3])
        current_payback = tree_value_array[parent_node_index, 2]

        # use the decision logic to compute price -
        node_price = max(current_payback, future_payback)

        # capture -
        tree_value_array[parent_node_index, 3] = node_price
    end

    return tree_value_array
end