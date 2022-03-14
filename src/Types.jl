# abstract types -
abstract type AbstractLatticeModel end
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
    number_of_contracts::Int64

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
    number_of_contracts::Int64

    # constructor -
    CallContractModel() = new()
end

mutable struct EquityModel <: AbstractAssetModel

    # data -
    ticker::String
    purchase_price::Float64
    current_price::Float64
    direction::Int64
    number_of_shares::Int64

    # constructor -
    EquityModel() = new()
end

mutable struct CRRLatticeModel <: AbstractLatticeModel

    # data -
    number_of_levels::Int64
    branch_factor::Int64
    connectivity::Array{Int64,2}
    probability::Float64
    risk_free_rate::Float64
    ΔT::Float64
    data::Dict{Int64,Any}

    # constructor -
    CRRLatticeModel() = new()
end