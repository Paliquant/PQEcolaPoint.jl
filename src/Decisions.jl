function move(model::CRRJITContractPremiumLatticeModel; 
    from::PQContractPremiumLatticePoint, to::PQContractPremiumLatticePoint)::Array{Float64,1}

    # initialize -
    premium_array = Array{Float64,1}()
    p_from = premium(model,from)
    p_to = premium(model,to)
    
    push!(premium_array, p_from)
    push!(premium_array, p_to)

    # return -
    return premium_array
end

function roll(model::CRRJITContractPremiumLatticeModel, origin::PQContractPremiumLatticePoint, 
    move::Pair{PQContractPremiumLatticePoint, PQContractPremiumLatticePoint})::DataFrame

    # initialize -
    premium_array = Array{Float64,2}(undef,3,5)

    # how much was the original positon?
    premium_array[1,1] = premium(model, origin)
    premium_array[2,1] = premium(model, move.first)
    premium_array[3,1] = premium(model, move.second)

    # compute delta -
    premium_array[1,2] = δ(model, origin)
    premium_array[2,2] = δ(model, move.first)
    premium_array[3,2] = δ(model, move.second)

    # compute θ -
    premium_array[1,3] = θ(model, origin)
    premium_array[2,3] = θ(model, move.first)
    premium_array[3,3] = θ(model, move.second)

    # compute vega -
    premium_array[1,4] = vega(model, origin)
    premium_array[2,4] = vega(model, move.first)
    premium_array[3,4] = vega(model, move.second)

    # compute γ -
    premium_array[1,5] = γ(model, origin)
    premium_array[2,5] = γ(model, move.first)
    premium_array[3,5] = γ(model, move.second)

    # package -
    df = DataFrame(P = premium_array[:,1] , δ = premium_array[:,2], θ = premium_array[:,3],
        vega = premium_array[:,4], γ = premium_array[:,5])
    
    # return -
    return df
end

function roll(model::CRRJITContractPremiumLatticeModel, 
    move::Pair{PQContractPremiumLatticePoint, PQContractPremiumLatticePoint})::DataFrame

    # initialize -
    premium_array = Array{Float64,2}(undef,2,5)

    # how much was the original positon?
    premium_array[1,1] = premium(model, move.first)
    premium_array[2,1] = premium(model, move.second)

    # compute delta -
    premium_array[1,2] = δ(model, move.first)
    premium_array[2,2] = δ(model, move.second)

    # compute delta -
    premium_array[1,3] = θ(model, move.first)
    premium_array[2,3] = θ(model, move.second)

    # compute vega -
    premium_array[1,4] = vega(model, move.first)
    premium_array[2,4] = vega(model, move.second)

    # compute γ -
    premium_array[1,5] = γ(model, move.first)
    premium_array[2,5] = γ(model, move.second)

    # package -
    df = DataFrame(P = premium_array[:,1] , δ = premium_array[:,2], θ = premium_array[:,3],
        vega = premium_array[:,4], γ = premium_array[:,5])
    
    # return -
    return df
end

