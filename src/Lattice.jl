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


function price(model::CRRLatticeModel, level::Int64)::Array{Float64,1}

    # grab the data -
    data_array = model.data

    # compute connectivity - 
    number_items_per_level = [i for i = 1:level]
    tmp_array = Array{Int64,1}()
    theta = 0
    for value in number_items_per_level
        for _ = 1:value
            push!(tmp_array, theta)
        end
        theta = theta + 1
    end

end

function premium(contracts::Array{T,1}, models::Array{CRRLatticeModel,1})::DataFrame where {T<:AbstractDerivativeContractModel}

    # initialize -
    df = DataFrame()

    for model ∈ models

        for contract ∈ contracts

            # let's compute the premium -
            premium_value = premium(contract, model)

            # get some value from the model, and contract -
            L = model.L
            ΔT = model.ΔT
            σ = model.σ
            Sₒ = model.Sₒ
            K = contract.strike_price

            # build tuple to add to the data frame -
            results_tuple = (
                L = L,
                ΔT = ΔT,
                Sₒ = Sₒ,
                K = K,
                IV = σ,
                P = premium_value
            )

            # push -
            push!(df, results_tuple)
        end
    end

    # return -
    return df
end

function premium(contracts::Array{T,1}, model::CRRLatticeModel)::Array{Float64,1} where {T<:AbstractDerivativeContractModel}

    # initialize -
    premimums = Array{Float64,1}()
    for contract ∈ contracts

        # compute the premium -
        value = premium(contract, model)
        push!(premimums, value)
    end

    # return - 
    return premimums
end

function premium(contract::T, model::CRRLatticeModel)::Float64 where {T<:AbstractDerivativeContractModel}

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
    for node_index ∈ 1:total_number_of_lattice_nodes

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
    for (_, parent_node_index) ∈ enumerate(reverse_node_index_array)

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

    # return -
    return tree_value_array[1, 3]
end