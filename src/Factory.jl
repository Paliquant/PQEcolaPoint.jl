function build(contractType::Type{T}, options::Dict{String,Any})::AbstractAssetModel where {T<:AbstractAssetModel}

    # initialize -
    model = eval(Meta.parse("$(contractType)()")) # empty contract model -

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

    # return -
    return model
end

function build(CRRLatticeModel; number_of_levels::Int64 = 2, T::Float64 = (1 / 365), σ::Float64 = 0.15, Sₒ::Float64 = 1.0, μ::Float64 = 0.0015)::Union{ArgumentError,CRRLatticeModel}

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
    discount = exp(-µ * ΔT)

    # compute connectivity - 
    number_items_per_level = [i for i = 1:number_of_levels]
    tmp_array = Array{Int64,1}()
    theta = 0
    for value in number_items_per_level
        for index = 1:value
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
    lattice_model.L = T
    lattice_model.Sₒ = Sₒ

    # return the model -
    return lattice_model
end