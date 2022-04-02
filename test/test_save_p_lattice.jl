using PQEcolaPoint
using Dates

# setup DTE -
T = 45.0
DTE = range(T, stop=0.0,step=-1.0) |> collect

# setup underlying range -
Sₒ = 79.74
IV = 0.4456
σ = Sₒ*(IV)*(√(T/365))
L = round(Sₒ - 2.96*σ)
U = round(Sₒ + 2.96*σ)
S = range(L,stop=U, step=1.0) |> collect

# setup IV array -
IV_array = range(0.3, stop = 0.5, step = 0.1) |> collect

# setup strike coordinates -
K = range(80.0, stop = 125.0, step = 5.0) |> collect

# compute the grid -
lattice_model = projection(PutContractModel, S, K, IV_array, DTE; number_of_levels = 80)

# # try to save -
path_to_save = "./test/tmp/Test.bson"
save(path_to_save, lattice_model)