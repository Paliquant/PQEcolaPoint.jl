# == PRIVATE METHODS BELOW HERE ================================================================================================= #
function _payoff(contract::PutContractModel, underlying::Float64)::Float64 end

function _payoff(contract::CallContractModel, underlying::Float64)::Float64
    return 0.0
end

function _payoff(equity::EquityModel, underlying::Float64)::Float64
    return 0.0
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
        payoff_value = _payoff(model, S)

        # compute the payoff -
        data_tuple = (
            underlying = S,
            payoff = payoff_value
        )

        # push -
        push!(expiration_data_table, data_tuple)
    end

    # return -
    return expiration_data_table
end
# == PUBLIC METHODS ABIVE HERE ================================================================================================== #
