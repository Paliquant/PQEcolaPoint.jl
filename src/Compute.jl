# == PRIVATE METHODS BELOW HERE ================================================================================================= #
function _expiration(contract::PutContractModel, underlying::Float64)::Tuple{Float64,Float64}

    # get data from the contract model - 
    direction = contract.direction
    K = contract.strike_price
    premium = contract.premium
    payoff_value = 0.0
    profit_value = 0.0

    # PUT contract -
    payoff_value = direction * max((K - underlying), 0.0)
    profit_value = payoff_value - direction * premium

    # return -
    return (payoff_value, profit_value)
end

function _expiration(contract::CallContractModel, underlying::Float64)::Tuple{Float64,Float64}

    # get data from the contract model - 
    direction = contract.direction
    K = contract.strike_price
    premium = contract.premium
    payoff_value = 0.0
    profit_value = 0.0

    # PUT contract -
    payoff_value = direction * max((underlying - K), 0.0)
    profit_value = payoff_value - direction * premium

    # return -
    return (payoff_value, profit_value)
end

function _expiration(equity::EquityModel, underlying::Float64)::Tuple{Float64,Float64}

    # get data from Equity model -
    direction = contract.direction
    purchase_price = contract.purchase_price

    # Equity -
    payoff_value = (underlying - purchase_price)
    profit_value = payoff_value

    # return -
    return (payoff_value, profit_value)
end
# == PRIVATE METHODS ABOVE HERE ================================================================================================= #

# == PUBLIC METHODS BELOW HERE ================================================================================================== #
function expiration(model::T, underlying::Array{Float64,1})::DataFrame where {T<:AbstractAssetModel}

    # initialize -
    expiration_data_table = DataFrame(
        underlying = Float64[],
        payoff = Float64[],
        profit = Float64[]
    )

    # main loop -
    for (i, S) ∈ enumerate(underlying)

        # compute the payoff -
        (payoff_value, profit_value) = _expiration(model, S)

        # compute the payoff -
        data_tuple = (
            underlying = S,
            payoff = payoff_value,
            profit = profit_value
        )

        # push -
        push!(expiration_data_table, data_tuple)
    end

    # return -
    return expiration_data_table
end

function expiration(models::Array{T,1}, underlying::Array{Float64,1})::DataFrame where {T<:AbstractAssetModel}
    return DataFrame()
end
# == PUBLIC METHODS ABIVE HERE ================================================================================================== #
