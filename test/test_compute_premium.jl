using PQEcolaPoint
using Dates

# build a binary tree model -
model = build(CRRLatticeModel; Sₒ = 320.0, number_of_levels = 14, branch_factor = 2, σ = 0.45, T = (14.0 / 365), r = 0.0174)

# what is the contract?
short_put_contract = PutContractModel()
short_put_contract.ticker = "XYZ"
short_put_contract.expiration_date = Date(2022, 04, 14)
short_put_contract.strike_price = 320.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

# what is the premimum?
pdict = premium(short_put_contract, model)