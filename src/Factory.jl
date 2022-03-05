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

function build(LatticeModel; number_of_levels::Int64 = 2, branch_factor::Int64 = 2)::Union{ArgumentError,LatticeModel}

    # create a blanck LatticeModel -
    lattice_model = LatticeModel()
    lattice_model.number_of_levels = number_of_levels
    lattice_model.branch_factor = branch_factor

    # check: number_of_levels ≥ 2
    if (number_of_levels < 2)
        return ArgumentError("Check failure: number_of_levels must be ≥ 2")
    end

    # check: branch_factor ≥ 1
    if (branch_factor < 1)
        return ArgumentError("Check failure: branch_factor must be ≥ 1")
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

    # return -
    return lattice_model
end