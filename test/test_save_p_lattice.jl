using PQEcolaPoint
using Dates

# setup DTE -
T = 36.0
DTE = range(T, stop=14.0,step=-1.0) |> collect

# setup underlying range -
Sₒ = 79.74
IV = 0.4456
σ = Sₒ*(IV)*(√(T/365))
L = Sₒ - 2.96*σ
U = Sₒ + 2.96*σ
S = range(L,stop=U, length=10) |> collect

# setup IV array -
IV_array = range(0.1, stop = 1.2, step = 0.1) |> collect

# setup strike coordinates -
K = range(50.0, stop = 125.0, step = 5.0) |> collect

# what is the contract?
short_put_contract = PutContractModel()
short_put_contract.ticker = "MU"
short_put_contract.expiration_date = Date(2022, 05, 06)
short_put_contract.strike_price = 75.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

# compute the grid -
lattice_model = projection(short_put_contract, S, K, IV_array, DTE; number_of_levels = 80)

# try to save -
path_to_save = "./test/tmp/Test.bson"
save(path_to_save, lattice_model)