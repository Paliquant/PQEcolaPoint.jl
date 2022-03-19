function θ(contract::Y; number_of_levels::Int64 = 2, T::Float64 = (1 / 365), σ::Float64 = 0.15, 
    Sₒ::Float64 = 1.0, μ::Float64 = 0.0015, 
    choice::Function=_rational)::Float64 where {Y<:AbstractDerivativeContractModel}

    # θ : 1 day diff 
    Tₒ = T
    T₁ = Tₒ - (1/365)

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

function δ(contract::Y; number_of_levels::Int64 = 2, T::Float64 = (1 / 365), σ::Float64 = 0.15, 
    Sₒ::Float64 = 1.0, μ::Float64 = 0.0015, 
    choice::Function=_rational)

    

end

function δ(contract::Y, mₒ::CRRLatticeModel, m₁::CRRLatticeModel; 
    choice::Function=_rational)::Float64 where {Y<:AbstractDerivativeContractModel}

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    δ_value = (P₁ - Pₒ)

    # return the value -
    return δ_value
end