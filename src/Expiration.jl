# == PRIVATE METHODS BELOW HERE ================================================================================================= #
function _expiration(contract::PutContractModel, underlying::Float64)::Tuple{Float64,Float64}

    # get data from the contract model - 
    direction = contract.direction
    K = contract.strike_price
    premium = contract.premium
    number_of_contracts = contract.number_of_contracts

    payoff_value = 0.0
    profit_value = 0.0

    # PUT contract -
    payoff_value = number_of_contracts*direction * max((K - underlying), 0.0)
    profit_value = (payoff_value - direction * premium * number_of_contracts)

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
    number_of_contracts = contract.number_of_contracts

    # PUT contract -
    payoff_value = number_of_contracts * direction * max((underlying - K), 0.0)
    profit_value = (payoff_value - direction * premium * number_of_contracts)

    # return -
    return (payoff_value, profit_value)
end

function _expiration(equity::EquityModel, underlying::Float64)::Tuple{Float64,Float64}

    # get data from Equity model -
    direction = equity.direction
    purchase_price = equity.purchase_price
    number_of_shares = equity.number_of_shares
    current_price = equity.current_price

    # Equity -
    payoff_value = number_of_shares*current_price
    profit_value = direction*(payoff_value - number_of_shares*purchase_price)

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
    expiration_data_dictionary = Dict{String,Any}()

    # we know the underlying already -
    expiration_data_dictionary["S"] = underlying

    # process each leg -
    for (i,model) ∈ enumerate(models)
        
        # create a new tmp array for each component -
        tmp_leg_payoff_array = Array{Float64,1}()
        tmp_leg_profit_array = Array{Float64,1}()
        
        for underlying_value ∈ underlying

            # compute the payoff and profit for each leg of the trade -
            (payoff_value, profit_value) = _expiration(model, underlying_value)

            # capture -
            push!(tmp_leg_payoff_array, payoff_value)
            push!(tmp_leg_profit_array, profit_value)
        end

        # build key names -
        payoff_key_name = "PAYOUT_L$(i)"
        profit_key_name = "PROFIT_L$(i)"

        # capture -
        expiration_data_dictionary[payoff_key_name] = tmp_leg_payoff_array
        expiration_data_dictionary[profit_key_name] = tmp_leg_profit_array
    end

    # create total profit and payoff data cols -
    tmp_profit_array = Array{Float64,1}()
    tmp_payoff_array = Array{Float64,1}()
    for underlying_value ∈ underlying
        
        tmp_profit_value = 0.0
        tmp_payoff_value = 0.0

        for model ∈ models
            
            # compute the payoff and profit for each leg of the trade -
            (payoff_value, profit_value) = _expiration(model, underlying_value)

            tmp_profit_value += profit_value
            tmp_payoff_value += payoff_value
        end

        push!(tmp_profit_array, tmp_profit_value)
        push!(tmp_payoff_array, tmp_payoff_value)
    end

    # add -
    expiration_data_dictionary["TOTAL_PAYOUT"] = tmp_payoff_array
    expiration_data_dictionary["TOTAL_PROFIT"] = tmp_profit_array

    # return -
    return DataFrame(expiration_data_dictionary)
end
# == PUBLIC METHODS ABIVE HERE ================================================================================================== #
