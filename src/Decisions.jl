function projection(contract::Y, underlying::Array{Float64,1}, iv::Array{Float64,1}, dte::Array{Float64,1};
    number_of_levels::Int64 = 100, μ::Floa64 = 0.0045)::Dict{NamedTuple, DataFrame}  where {Y<:AbstractDerivativeContractModel}

    # initialize -
    models = Array{CRRLatticeModel,1}()
    simulation_archive = Dict{NamedTuple,DataFrame}()

    # main loop to compute look ahead archive -
    for (i, Sₒ) ∈ enumerate(underlying)
        for (j, dte_value) ∈ enumerate(dte)
            for σ ∈ iv
    
                # build a binary tree with these market conditions -
                model = build(CRRLatticeModel; Sₒ = Sₒ, number_of_levels = number_of_levels, σ = σ, T = (dte_value / 365), μ = μ)
                push!(models, model)
            end
    
            # compute grid -
            df = premium(contract, models)
    
            # build the key -
            key_tuple = (
                i = i,
                j = j
            )
    
            # cache -
            simulation_archive[key_tuple] = df
    
            # clean out the model array -
            empty!(models)
        end
    end

    # return -
    return simulation_archive
end