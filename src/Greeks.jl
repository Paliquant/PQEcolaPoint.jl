# == THETA ========================================================================================================================================= #
function θ(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365),
    σ::Float64=0.15, Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Array{Float64,1} where {Y<:AbstractDerivativeContractModel}

    # value array -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = θ(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function θ(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Float64 where {Y<:AbstractDerivativeContractModel}

    # θ : 1 day diff 
    Tₒ = T
    T₁ = Tₒ - (1 / 365)

    # build a binary tree with N levels -
    mₒ = build(CRRLatticeModel; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=Tₒ, μ=μ)
    m₁ = build(CRRLatticeModel; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T₁, μ=μ)

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    θ_value = (P₁ - Pₒ)

    # return the value -
    return θ_value
end
# ================================================================================================================================================== #

# == DELTA ========================================================================================================================================= #
function δ(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Array{Float64,1} where {Y<:AbstractDerivativeContractModel}

    # value array -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = δ(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function δ(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractDerivativeContractModel}

    # advance base price by 1 -
    S₁ = Sₒ + 1

    # build models -
    mₒ = build(CRRLatticeModel; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ)
    m₁ = build(CRRLatticeModel; Sₒ=S₁, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ)

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    δ_value = (P₁ - Pₒ)

    # return the value -
    return δ_value
end
# ================================================================================================================================================== #

# == GAMMA ========================================================================================================================================= #
function γ(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractDerivativeContractModel}

    # advance base price by 1 -
    S₁ = Sₒ + 1

    # compute -
    δₒ = δ(contract; number_of_levels=number_of_levels, T=T, σ=σ, Sₒ=Sₒ, μ=μ, choice=choice)
    δ₁ = δ(contract; number_of_levels=number_of_levels, T=T, σ=σ, Sₒ=S₁, μ=μ, choice=choice)

    # compute γ -
    γ_value = (δ₁ - δₒ)

    # return -
    return γ_value
end

function γ(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractDerivativeContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = γ(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end
# ================================================================================================================================================== #

# == VEGA ========================================================================================================================================== #
function vega(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractDerivativeContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = vega(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function vega(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractDerivativeContractModel}

    # setup the calculation -
    σₒ = σ
    σ₁ = σ + 0.01

    # build models -
    mₒ = build(CRRLatticeModel; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σₒ, T=T, μ=μ)
    m₁ = build(CRRLatticeModel; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ₁, T=T, μ=μ)

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    vega_value = (P₁ - Pₒ)

    # return the value -
    return vega_value
end
# ================================================================================================================================================== #

# == RHO =========================================================================================================================================== #
function ρ(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractDerivativeContractModel}

    # setup mu -
    μₒ = μ
    μ₁ = μ + 0.001

    # build models -
    mₒ = build(CRRLatticeModel; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μₒ)
    m₁ = build(CRRLatticeModel; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ₁)

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    ρ_value = (P₁ - Pₒ)

    # return the value -
    return ρ_value
end

function ρ(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractDerivativeContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = ρ(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end
# ================================================================================================================================================== #