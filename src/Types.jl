# abstract types -
abstract type AbstractAssetModel end
abstract type AbstractDerivativeContractModel <: AbstractAssetModel end

# option contract types -
mutable struct PutContractModel <: AbstractDerivativeContractModel

    # data -
    ticker::String
    strike_price::Float64
    expiration_date::Date
    premium::Float64
    current_price::Float64
    direction::Int64

    # constructor -
    PutContractModel() = new()
end

mutable struct CallContractModel <: AbstractDerivativeContractModel

    # data -
    ticker::String
    strike_price::Float64
    expiration_date::Date
    premium::Float64
    current_price::Float64
    direction::Int64

    # constructor -
    CallContractModel() = new()
end

mutable struct EquityModel <: AbstractAssetModel

    # data -
    ticker::String
    purchase_price::Float64
    current_price::Float64
    direction::Int64

    # constructor -
    EquityModel() = new()
end
