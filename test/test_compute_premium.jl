using PQEcolaPoint
using Dates

# build a binary tree model -
model = build(CRRLatticeModel; Sₒ = 125.94, number_of_levels = 25, branch_factor = 2, σ = 0.83, T = (35.0 / 365), r = 0.0456)

# what is the contract?
short_put_contract = CallContractModel()
short_put_contract.ticker = "XYZ"
short_put_contract.expiration_date = Date(2022, 04, 1)
short_put_contract.strike_price = 125.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

# what is the premimum?
pdict = premium(short_put_contract, model)