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

    # get parameters from the LatticeModel -
    connectivity = model.connectivity
    data = model.data
    p = model.probability
    r = model.risk_free_rate
    ΔT = model.ΔT

    # what is the size of the system?
    (NR, NC) = size(connectivity)

    # initialize -
    discounted_payoff_dict = Dict{Int64,Float64}()

    # compute discount factor -
    d = exp(-r * ΔT)

    # get size of the connectivity array -
    for i ∈ NR:-1:1

        # get underlyng price of children nodes -
        Sₒ = data[i]
        S₁ = data[connectivity[i, 1]]
        S₂ = data[connectivity[i, 2]]

        # compute the payoff for each of my children nodes -
        payoff_value_0 = intrinsic(contract, Sₒ)
        payoff_value_1 = intrinsic(contract, S₁)
        payoff_value_2 = intrinsic(contract, S₂)

        # compute the discounted expected payoff -
        dep = d * (p * payoff_value_1 + (1 - p) * payoff_value_2)

        # what is the value of this node?
        node_value = max(payoff_value_0, dep)

        # grab this payoff value -
        discounted_payoff_dict[i] = node_value
    end

    return discounted_payoff_dict
end