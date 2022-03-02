# setup internal paths -
_PATH_TO_SRC = dirname(pathof(@__MODULE__))

# load external packages
using CSV
using DataFrames
using Dates

# load my codes 
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Expiration.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))