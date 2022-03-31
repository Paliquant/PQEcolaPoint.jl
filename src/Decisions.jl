function projection(contract::Y, underlying::Array{Float64,1}, strike::Array{Float64,1}, iv::Array{Float64,1}, dte::Array{Float64,1};
    number_of_levels::Int64 = 100, μ::Float64 = 0.0045)::CRRContractPremiumLatticeModel  where {Y<:AbstractDerivativeContractModel}

    # initialize -
    simulation_archive = Dict{NamedTuple, Float64}()

    # main loop to compute look ahead archive -
    for (d, T) ∈ enumerate(dte)
        for (s, Sₒ) ∈ enumerate(underlying)
            for (i, K) ∈ enumerate(strike)
                for (j, σ) ∈ enumerate(iv)

                    # build a binary tree with these market conditions -
                    model = build(CRRLatticeModel; Sₒ = Sₒ, number_of_levels = number_of_levels, σ = σ, T = (T / 365), μ = μ)

                    # set the parameters on the contract / for this version of the method we have a single contract -
                    contract.strike_price = K
                
                    # compute the premimum -
                    p = premium(contract, model)

                    # build the key -
                    key_tuple = (
                        s = s,
                        d = d,
                        i = i,
                        j = j
                    );   
    
                    # cache -
                    simulation_archive[key_tuple] = p

                    @info (s,d,i,j)
                end
            end
        end
    end

    # build model -
    lattice_model = CRRContractPremiumLatticeModel()
    lattice_model.grid = simulation_archive
    lattice_model.underlying = underlying
    lattice_model.strike = strike
    lattice_model.iv = iv
    lattice_model.dte = dte
    lattice_model.number_of_levels = number_of_levels
    lattice_model.μ = μ
    lattice_model.contract = contract
    
    # return -
    return lattice_model
end

function roll(model::CRRContractPremiumLatticeModel; 
    from::NamedTuple, to::NamedTuple)::Array{Float64,1}

    # TODO: check are the to and from NamedTuple the correct format?
    
    # get the grid -
    grid = model.grid

    # get the from, and two premimum values -
    P_from = grid[from]
    P_to = grid[to]

    # build and return a premimum array -
    premium_array = Array{Float64,1}()
    push!(premium_array, P_from)
    push!(premium_array, P_to)

    # return -
    return premium_array
end