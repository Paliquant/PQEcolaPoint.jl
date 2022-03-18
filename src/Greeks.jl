function θ(contract::Y, model::T; choice::Function=_rational, ϵ::Float64=1.0)::Float64 where {T<:AbstractLatticeModel,Y<:AbstractDerivativeContractModel}

    # get stuff from model -
    ΔTₒ = model.ΔT

    # compute the premium -
    Pₒ = premium(contract, model; choice=choice)

    # update the duraction, and recompute the premium -
    new_model = deepcopy(model)
    ΔT₁ = ϵ * ΔTₒ
    new_model.ΔT = ΔT₁
    P₁ = premium(contract, new_model; choice=choice)

    # compute theta -
    θ_value = (P₁ - Pₒ) / (ΔT₁ - ΔTₒ)

    # return the value -
    return θ_value
end