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
    move::Pair{PQContractPremiumLatticePoint, PQContractPremiumLatticePoint})::Vector{Float64}

    # initialize -
    premium_array = Array{Float64,1}(undef,3)

    # how much was the original positon?
    premium_array[1] = premium(model, origin)
    premium_array[2] = premium(model, move.first)
    premium_array[3] = premium(model, move.second)
    
    # return -
    return premium_array
end

function roll(model::CRRJITContractPremiumLatticeModel, 
    move::Pair{PQContractPremiumLatticePoint, PQContractPremiumLatticePoint})::Vector{Float64}

    # initialize -
    premium_array = Array{Float64,1}(undef,2)

    # how much was the original positon?
    premium_array[1] = premium(model, move.first)
    premium_array[2] = premium(model, move.second)
    
    # return -
    return premium_array
end

