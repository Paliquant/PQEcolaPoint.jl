function load(path::String, 
    modelType::Union{Type{CRRContractPremiumLatticeModel}, Type{CRRJITContractPremiumLatticeModel}})
    
    # load the BSON model -
    tmp_data = BSON.load(path, @__MODULE__)[:model_dictionary]

    # return -
    return build(modelType, tmp_data)
end

function save(path::String, model::CRRJITContractPremiumLatticeModel)::Bool

    # TODO: check: is this is legit path?

    # fields that need to be persisted -
    # underlying::Array{Float64,1}
    # strike::Union{Array{Float64,1}, Array{Float64,2}}
    # iv::Array{Float64,1}
    # dte::Array{Float64,1}
    # number_of_levels::Int64
    # μ::Float64 -> risk_free_rate
    # contractType::T where {T <: AbstractDerivativeContractModel}

    try

        # save -
        model_dictionary = Dict{String,Any}()
        model_dictionary["underlying"] = model.underlying
        model_dictionary["strike"] = model.strike
        model_dictionary["iv"] = model.iv
        model_dictionary["dte"] = model.dte
        model_dictionary["number_of_levels"] = model.number_of_levels
        model_dictionary["risk_free_rate"] = model.risk_free_rate
        model_dictionary["contractType"] = model.contractType
        
        # dump -
        @save path model_dictionary

        # return -
        return true
    catch ex
        @error showerror(stdout, ex, catch_backtrace())
        return false
    end
end

function save(path::String, model::CRRContractPremiumLatticeModel)::Bool

    # TODO: check: is this is legit path?

    # fields that need to be persisted -
    # grid::Dict{NamedTuple,Union{Float64, Array{Float64,1}}}
    # underlying::Array{Float64,1}
    # strike::Union{Array{Float64,1}, Array{Float64,2}}
    # iv::Array{Float64,1}
    # dte::Array{Float64,1}
    # number_of_levels::Int64
    # μ::Float64 -> risk_free_rate
    # contractType::T where {T <: AbstractDerivativeContractModel}

    try

        # save -
        model_dictionary = Dict{String,Any}()
        model_dictionary["grid"] = model.grid
        model_dictionary["underlying"] = model.underlying
        model_dictionary["strike"] = model.strike
        model_dictionary["iv"] = model.iv
        model_dictionary["dte"] = model.dte
        model_dictionary["number_of_levels"] = model.number_of_levels
        model_dictionary["risk_free_rate"] = model.risk_free_rate
        model_dictionary["contractType"] = model.contractType
        
        # dump -
        @save path model_dictionary

        # return -
        return true
    catch ex
        @error showerror(stdout, ex, catch_backtrace())
        return false
    end
end