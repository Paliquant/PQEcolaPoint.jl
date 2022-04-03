# === PRIVATE BELOW HERE ============================================================================================= #
_rational(a, b) = max(a, b)
_encode(array,value) = findfirst(x->x>=value, array)
# === PRIVATE ABOVE HERE ============================================================================================= #


# === PUBLIC BELOW HERE ============================================================================================== #
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
    b = range(start=-(k - 2), stop=1, step=1) |> collect

    # fill in connectivity -
    price_array = Array{Float64,1}()
    index_vector_reverse = reverse(range(1, stop=number_of_rows, step=1) |> collect)
    index_vector_at_level = reverse(index_vector_reverse[1:L])
    for i ∈ index_vector_at_level

        # grab the price value -
        price_value = selector(dd, i)

        # cache -
        push!(price_array, price_value)
    end

    return price_array
end

function price(model::CRRLatticeModel, level::Int64; weights::Bool=false)

    # grab the data -
    data_array = model.data
    p = model.p
    probabilities = Array{Float64,1}()

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

    # levels -
    L = tmp_array .+ 1

    # find the idx's for level -
    idx = findall(x -> x == level, L)
    price_array = data_array[idx, 1]

    # do we want to calculate the weights?
    if (weights == true)

        # compute the probabilty array -
        tmp_range = range((level - 1), stop=0, step=-1) |> collect
        for i ∈ tmp_range
            j = (level - 1) - i

            n = big((level - 1))
            k = big(j)

            coeff = binomial(n, k)
            pvalue = coeff * ((p^i) * ((1 - p)^j))
            push!(probabilities, pvalue)
        end

        # return -
        return hcat(price_array, probabilities)
    else
        return price_array
    end
end

function premium(contracts::Array{Y,1}, models::Array{CRRLatticeModel,1}; choice::Function=_rational)::DataFrame where {Y<:AbstractDerivativeContractModel}

    # initialize -
    df = DataFrame()

    for model ∈ models

        for contract ∈ contracts

            # let's compute the premium -
            premium_value = premium(contract, model; choice=choice)

            # get some value from the model, and contract -
            T = model.T
            ΔT = model.ΔT
            σ = model.σ
            Sₒ = model.Sₒ
            K = contract.strike_price

            # build tuple to add to the data frame -
            results_tuple = (
                T=T,
                ΔT=ΔT,
                Sₒ=Sₒ,
                K=K,
                IV=σ,
                P=premium_value
            )

            # push -
            push!(df, results_tuple)
        end
    end

    # return -
    return df
end

function premium(contracts::Array{T,1}, model::CRRLatticeModel; 
    choice::Function=_rational)::Array{Float64,1} where {T<:AbstractDerivativeContractModel}

    # initialize -
    premimums = Array{Float64,1}()
    for contract ∈ contracts

        # compute the premium -
        value = premium(contract, model; choice=choice)
        push!(premimums, value)
    end

    # return - 
    return premimums
end

function premium(contract::T, model::CRRLatticeModel; 
    choice::Function=_rational)::Float64 where {T<:AbstractDerivativeContractModel}

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
    reverse_node_index_array = range(number_of_nodes_to_evaluate, stop=1, step=-1) |> collect
    for (_, parent_node_index) ∈ enumerate(reverse_node_index_array)

        # ok, get the connected node indexes -
        up_node_index = connectivity_index_array[parent_node_index, 2]
        down_node_index = connectivity_index_array[parent_node_index, 3]

        # ok, let's compute the payback *if* we continue -
        future_payback = dfactor * (p * tree_value_array[up_node_index, 3] + (1 - p) * tree_value_array[down_node_index, 3])
        current_payback = tree_value_array[parent_node_index, 2]

        # use the decision logic to compute price -
        node_price = choice(current_payback, future_payback)

        # capture -
        tree_value_array[parent_node_index, 3] = node_price
    end

    # return -
    return tree_value_array[1, 3]
end

function premium(model::CRRContractPremiumLatticeModel, 
    points::Array{PQContractPremiumLatticePoint,1})::Array{Float64,1}

    # initialize -
    premium_array = Array{Float64,1}()

    # compute a trajectory -
    for point ∈ points
        value = premium(model, point)
        push!(premium_array, value)
    end

    # return -
    return premium_array
end

function premium(model::CRRJITContractPremiumLatticeModel, point::PQContractPremiumLatticePoint)::Float64

    # get the contract type from the model -
    contractType = model.contractType

    # build an empty contract -
    contract = build(contractType, Dict{String,Any}())
    contract.number_of_contracts = 1
    contract.direction = 1

    # get our operating point from the point model -
    underlying_value = model.underlying[point.s]
    iv_value = model.iv[point.j]
    K_value = model.strike[point.i]
    dte_value = model.dte[point.d]
    number_of_levels = model.number_of_levels
    risk_free_rate = model.risk_free_rate

    # build a binary tree with these market conditions -
    world_model = build(CRRLatticeModel; Sₒ = underlying_value, number_of_levels = number_of_levels, σ = iv_value, T = (dte_value / 365), μ = risk_free_rate)

    # set the parameters on the contract / for this version of the method we have a single contract -
    contract.strike_price = K_value
    
    # compute the premimum -
    p = premium(contract, world_model)

    # return -
    return p
end

function premium(model::CRRContractPremiumLatticeModel, 
    point::PQContractPremiumLatticePoint)::Float64

    # TODO: check for values outside the range?
    key_tuple = (
        s = point.s, 
        d = point.d,
        i = point.i,
        j = point.j
    );

    # get the premimum value -
    premium_value = model.grid[key_tuple]

    # return -
    return premium_value
end

function decode(model::CRRJITContractPremiumLatticeModel, 
    points::Array{PQContractPremiumLatticePoint,1})::Array{NamedTuple, 1}

    # initialize -
    decoded_array = Array{NamedTuple,1}

    # get data -
    for point ∈ points
        results_tuple = decode(model, point)
        push!(decoded_array, results_tuple)
    end

    # return -
    return decoded_array
end

function decode(model::CRRJITContractPremiumLatticeModel, 
    point::PQContractPremiumLatticePoint)::NamedTuple

    # get all the actual values associated with this point -
    underlying_value = model.underlying[point.s]
    iv_value = model.iv[point.j]
    K_value = model.strike[point.i]
    dte_value = model.dte[point.d]

    # compute the premium -
    p = premium(model, point)

    # build results tuple -
    results_tuple = (
        S = underlying_value,
        IV = iv_value,
        K = K_value,
        DTE = dte_value,
        P = p
    )

    # return -
    return results_tuple
end

function decode(model::CRRContractPremiumLatticeModel, 
    point::PQContractPremiumLatticePoint)::NamedTuple

    # get all the actual values associated with this point -
    underlying_value = model.underlying[point.s]
    iv_value = model.iv[point.j]
    K_value = model.strike[point.i]
    dte_value = model.dte[point.d]

    # setup key tuple -
    key_tuple = (
        s = point.s, 
        d = point.d,
        i = point.i,
        j = point.j
    );

    # get the premimum value -
    premium_value = model.grid[key_tuple]

    # build results tuple -
    results_tuple = (
        S = underlying_value,
        IV = iv_value,
        K = K_value,
        DTE = dte_value,
        P = premium_value
    )

    # return -
    return results_tuple
end

function decode(model::CRRContractPremiumLatticeModel, 
    points::Array{PQContractPremiumLatticePoint,1})::Array{NamedTuple,1}

    # initialize -
    decoded_array = Array{NamedTuple,1}

    # get data -
    for point ∈ points
        results_tuple = decode(model, point)
        push!(decoded_array, results_tuple)
    end

    # return -
    return decoded_array
end

function encode(model::Union{CRRJITContractPremiumLatticeModel,CRRContractPremiumLatticeModel};
    S::Float64, IV::Float64, DTE::Float64, K::Float64)::PQContractPremiumLatticePoint

    # initialize -
    point = PQContractPremiumLatticePoint()

    # get data from model -
    underlying = model.underlying
    strike = model.strike
    iv = model.iv
    dte = model.dte

    # find nearest index -
    point.s = _encode(underlying, S)
    point.i = _encode(strike, K)
    point.j = _encode(iv, IV)
    point.d = _encode(-1*dte, -1*DTE)

    # return -
    return point
end
# === PUBLIC ABOVE HERE ============================================================================================= #