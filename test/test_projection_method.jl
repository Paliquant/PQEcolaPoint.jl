using PQEcolaPoint
using Dates

# setup DTE -
T = 36
DTE = range(T, stop=0,step=-1) |> collect

# setup underlying range -
Sₒ = 79.74
IV = 0.4456
σ = Sₒ*(IV)*(√(T/365))
L = Sₒ - 2.96*σ
U = Sₒ + 2.96*σ
S = range(L,stop=U,100) |> collect

# setup IV array -


# what is the contract?
short_put_contract = PutContractModel()
short_put_contract.ticker = "MU"
short_put_contract.expiration_date = Date(2022, 05, 06)
short_put_contract.strike_price = 75.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

