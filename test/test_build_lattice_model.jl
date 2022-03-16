using PQEcolaPoint
using Dates

# build a binary tree with three levels -
model = build(CRRLatticeModel; Sₒ = 109.33, number_of_levels = 80, σ = 0.6560, T = (30.0 / 365), μ = 0.0045)

# what is the contract?
short_put_contract = PutContractModel()
short_put_contract.ticker = "XYZ"
short_put_contract.expiration_date = Date(2022, 04, 1)
short_put_contract.strike_price = 95.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

# what is the premimum?
parray = premium(short_put_contract, model)