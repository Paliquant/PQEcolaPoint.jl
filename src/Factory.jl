function build(contractType::Type{T}, options::Dict{String,Any})::AbstractAssetModel where {T<:AbstractAssetModel}

    # initialize -
    model = eval(Meta.parse("$(contractType)()")) # empty contract model -

    # if we have options, add them to the contract model -
    if (isempty(options) == false)
        
        # for the result of the fields, let's lookup in the dictionary.
        # error state: if the dictionary is missing a value -
        for field_name_symbol ∈ fieldnames(contractType)

            # convert the field_name_symbol to a string -
            field_name_string = string(field_name_symbol)

            # check the for the key -
            if (haskey(options, field_name_string) == false)
                throw(ArgumentError("dictionary is missing: $(field_name_string)"))
            end

            # get the value -
            value = options[field_name_string]

            # set -
            setproperty!(model, field_name_symbol, value)
        end
    end

    # return -
    return model
end

function build(contractType::Type{T}, options::NamedTuple)::AbstractAssetModel where {T<:AbstractAssetModel}

    # initialize -
    model = eval(Meta.parse("$(contractType)()")) # empty contract model -

    # if we have options, add them to the contract model -
    if (isempty(options) == false)
    
        for key ∈ fieldnames(contractType)
            
            # convert the field_name_symbol to a string -
            field_name_string = string(key)

            # check the for the key -
            if (haskey(options, key) == false)
                throw(ArgumentError("NamedTuple is missing: $(field_name_string)"))
            end

            # get the value -
            value = options[key]

            # set -
            setproperty!(model, key, value)
        end
    end

    # return -
    return model
end

function build(modelType::Type{CRRContractPremiumLatticeModel}, options::Dict{String,Any})::CRRContractPremiumLatticeModel

     # initialize -
     model = eval(Meta.parse("$(modelType)()")) # empty contract model -

     # if we have options, add them to the contract model -
     if (isempty(options) == false)
         
         # for the result of the fields, let's lookup in the dictionary.
         # error state: if the dictionary is missing a value -
         for field_name_symbol ∈ fieldnames(modelType)
 
             # convert the field_name_symbol to a string -
             field_name_string = string(field_name_symbol)
 
             # check the for the key -
             if (haskey(options, field_name_string) == false)
                 throw(ArgumentError("dictionary is missing: $(field_name_string)"))
             end
 
             # get the value -
             value = options[field_name_string]
 
             # set -
             setproperty!(model, field_name_symbol, value)
         end
     end
 
     # return -
     return model
end

function build(type::Type{PQContractPremiumLatticePoint}; 
    i::Int64=1, j::Int64=1, s::Int64=1, d::Int64 = 1)::PQContractPremiumLatticePoint

    point_model = PQContractPremiumLatticePoint()
    point_model.i = i
    point_model.j = j
    point_model.s = s
    point_model.d = d

    # return -
    return point_model
end

function build(type::Type{CRRLatticeModel}; number_of_levels::Int64 = 2, T::Float64 = (1 / 365), σ::Float64 = 0.15, 
    Sₒ::Float64 = 1.0, μ::Float64 = 0.0015)::Union{ArgumentError,CRRLatticeModel}

    # check: number_of_levels ≥ 2
    if (number_of_levels < 2)
        return ArgumentError("Check failure: number_of_levels must be ≥ 2")
    end

    # initialize -
    lattice_model = CRRLatticeModel()

    # compute the movement up, down and probability -
    ΔT = T / number_of_levels
    u = exp(σ * √ΔT)
    d = exp(-σ * √ΔT)
    p = (exp(µ * ΔT) - d) / (u - d)

    # compute connectivity - 
    number_items_per_level = [i for i = 1:number_of_levels]
    tmp_array = Array{Int64,1}()
    theta = 0
    for value in number_items_per_level
        for _ = 1:value
            push!(tmp_array, theta)
        end
        theta = theta + 1
    end

    N = sum(number_items_per_level[1:(number_of_levels-1)])
    connectivity_index_array = Array{Int64,2}(undef, N, 3)
    for row_index = 1:N

        # index_array[row_index,1] = tmp_array[row_index]
        connectivity_index_array[row_index, 1] = row_index
        connectivity_index_array[row_index, 2] = row_index + 1 + tmp_array[row_index]
        connectivity_index_array[row_index, 3] = row_index + 2 + tmp_array[row_index]
    end
    lattice_model.connectivity = connectivity_index_array

    # init the tree -
    total_number_of_lattice_nodes = connectivity_index_array[end, end]
    number_of_nodes_to_evaluate = connectivity_index_array[end, 1]
    tree_value_array = Array{Float64,2}(undef, total_number_of_lattice_nodes, 3) # nodes x 3 = col1: underlying price, col2: intrinsic value, col3: option price

    # First: let's compute the underlying price on the lattice -
    tree_value_array[1, 1] = Sₒ
    for node_index ∈ 1:number_of_nodes_to_evaluate

        # get index -
        parent_node_index = connectivity_index_array[node_index, 1]
        up_node_index = connectivity_index_array[node_index, 2]
        down_node_index = connectivity_index_array[node_index, 3]

        # compute prices -
        parent_price = tree_value_array[parent_node_index, 1]
        up_price = parent_price * u
        down_price = parent_price * d

        # store prices -
        tree_value_array[up_node_index, 1] = up_price
        tree_value_array[down_node_index, 1] = down_price
    end

    # Second: let's add the data to the lattice model -
    lattice_model.data = tree_value_array

    # add other stuff -
    lattice_model.p = p
    lattice_model.μ = μ
    lattice_model.u = u
    lattice_model.d = d
    lattice_model.ΔT = ΔT
    lattice_model.σ = σ
    lattice_model.T = T
    lattice_model.Sₒ = Sₒ

    # return the model -
    return lattice_model
end

function build(latticeType::Type{CRRJITContractPremiumLatticeModel},contractType::Type{Y}, underlying::Array{Float64,1}, 
    strike::Array{Float64,1}, iv::Array{Float64,1}, dte::Array{Float64,1}; number_of_levels::Int64 = 100, μ::Float64 = 0.0045)::CRRJITContractPremiumLatticeModel  where {Y<:AbstractDerivativeContractModel}

    # show -
    @info "Building a $(latticeType) lattice with a $(contractType) contract"

    # data fields -
    # underlying::Array{Float64,1}
    # strike::Union{Array{Float64,1}, Array{Float64,2}}
    # iv::Array{Float64,1}
    # dte::Array{Float64,1}
    # number_of_levels::Int64
    # risk_free_rate::Float64
    # contractType::Type{T} where {T <: AbstractDerivativeContractModel}

    # build an empty CRRContractPremiumLatticeModel -
    model = CRRJITContractPremiumLatticeModel()
    model.underlying = underlying
    model.strike = strike
    model.iv = iv
    model.dte = dte
    model.number_of_levels = number_of_levels
    model.risk_free_rate = μ
    model.contractType = contractType

    # return -
    return model
end

function build(latticeType::Type{CRRContractPremiumLatticeModel},contractType::Type{Y}, underlying::Array{Float64,1}, 
    strike::Array{Float64,1}, iv::Array{Float64,1}, dte::Array{Float64,1}; number_of_levels::Int64 = 100, μ::Float64 = 0.0045)::CRRContractPremiumLatticeModel  where {Y<:AbstractDerivativeContractModel}

    # show -
    @info "Building $(latticeType). This may take several minutes."

    # initialize -
    simulation_archive = Dict{NamedTuple, Float64}()

    # build an empty contract -
    contract = build(contractType, Dict{String,Any}())
    contract.number_of_contracts = 1
    contract.direction = 1

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
    lattice_model.risk_free_rate = μ
    lattice_model.contractType = contractType
    
    # return -
    return lattice_model
end