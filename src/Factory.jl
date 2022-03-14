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

function build(CRRLatticeModel; number_of_levels::Int64 = 2, branch_factor::Int64 = 2,
    T::Float64 = (1 / 365), σ::Float64 = 10.0, Sₒ::Float64 = 1.0, r::Float64 = 0.015)::Union{ArgumentError,CRRLatticeModel}

    # compute the time step -
    ΔT = T / number_of_levels

    # create a blanck LatticeModel -
    lattice_model = CRRLatticeModel()
    lattice_model.number_of_levels = number_of_levels
    lattice_model.branch_factor = branch_factor
    lattice_model.risk_free_rate = r
    lattice_model.ΔT = ΔT

    # check: number_of_levels ≥ 2
    if (number_of_levels < 2)
        return ArgumentError("Check failure: number_of_levels must be ≥ 2")
    end

    # check: branch_factor ≥ 2
    if (branch_factor < 2)
        return ArgumentError("Check failure: branch_factor must be ≥ 2")
    end

    # setup connectivity array -
    h = (number_of_levels - 2)
    k = branch_factor
    L = k^h
    number_of_rows = convert(Int, (k * L - 1) / (k - 1))
    connectivity_array = Array{Int64,2}(undef, number_of_rows, k)

    # what is my b?
    b = range(start = -(k - 2), stop = 1, step = 1) |> collect

    # fill in connectivity -
    for i ∈ 1:number_of_rows
        for j ∈ 1:k
            connectivity_array[i, j] = k * i + b[j]
        end
    end
    lattice_model.connectivity = connectivity_array

    # Finally, let's compute the price for the nodes in the network -
    u = exp(σ * sqrt((k - 1) * ΔT))
    d = exp(-σ * sqrt((k - 1) * ΔT))
    p = (exp(r * ΔT) - d) / (u - d)
    δ = reverse(range(start = d, stop = u, length = k) |> collect)
    data_dictionary = Dict{Int64,Any}()
    for i ∈ 1:number_of_rows

        # which node is this node connected to?
        list_of_children_nodes = connectivity_array[i, :]

        if (i == 1)

            # set the initial price -
            data_dictionary[i] = Sₒ

            # price for the children -
            S_child = Sₒ .* δ

            # what nodes is i connected to -
            list_of_children_nodes = connectivity_array[i, :]
            for (j, child_index) ∈ enumerate(list_of_children_nodes)
                data_dictionary[child_index] = S_child[j]
            end
        else

            # get the parent price -
            S_parent = data_dictionary[i]
            S_child = S_parent .* δ

            # what nodes is i connected to -
            for (j, child_index) ∈ enumerate(list_of_children_nodes)
                data_dictionary[child_index] = S_child[j]
            end
        end
    end

    # set data -
    lattice_model.data = data_dictionary
    lattice_model.probability = p

    # return -
    return lattice_model
end