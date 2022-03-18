function θ(contract::Y, model::T; choice::Function=_rational)::Float64 where {T<:AbstractLatticeModel,Y<:AbstractDerivativeContractModel}

    # get stuff from model -
    ΔTₒ = model.ΔT
    N = model.number_of_levels

    # compute the premium -
    Pₒ = premium(contract, model; choice=choice)

    # update the duraction, and recompute the premium -
    new_model = deepcopy(model)
    Δ = (1/N)*(1.0/365)
    new_model.ΔT = (ΔTₒ - Δ)
    P₁ = premium(contract, new_model; choice=choice)

    # compute theta -
    θ_value = (P₁ - Pₒ)

    # return the value -
    return θ_value
end