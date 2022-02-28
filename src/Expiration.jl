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
        S = Float64[],
        payoff = Float64[],
        profit = Float64[]
    )

    # main loop -
    for (i, underlying_value) ∈ enumerate(underlying)

        # compute the payoff -
        (payoff_value, profit_value) = _expiration(model, underlying_value)

        # compute the payoff -
        data_tuple = (
            S = underlying_value,
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
    
    # initialize -
    expiration_data_table = DataFrame(
        S = Float64[],
        payoff = Float64[],
        profit = Float64[]
    )

    # main loop -
    for underlying_value ∈ underlying
        
        # init -
        tmp_payoff_value = 0.0
        tmp_profit_value = 0.0

        for model ∈ models
            
            # compute the payoff and profit for each leg of the trade -
            (payoff_value, profit_value) = _expiration(model, underlying_value)

            # accumulate -
            tmp_payoff_value += payoff_value
            tmp_profit_value += profit_value
        end

        # compute the payoff -
        data_tuple = (
            S = underlying_value,
            payoff = tmp_payoff_value,
            profit = tmp_profit_value
        )

        # push -
        push!(expiration_data_table, data_tuple)
    end

    # return -
    return expiration_data_table
end
# == PUBLIC METHODS ABIVE HERE ================================================================================================== #
