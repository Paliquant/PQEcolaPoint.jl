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

