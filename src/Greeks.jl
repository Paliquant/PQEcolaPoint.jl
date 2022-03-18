function θ(contract::Y, mₒ::CRRLatticeModel, m₁::CRRLatticeModel; 
    choice::Function=_rational)::Float64 where {Y<:AbstractDerivativeContractModel}

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    θ_value = (P₁ - Pₒ)

    # return the value -
    return θ_value
end