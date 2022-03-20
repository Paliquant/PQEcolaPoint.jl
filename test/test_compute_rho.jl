using PQEcolaPoint
using Dates

# what is the contract?
short_put_contract = PutContractModel()
short_put_contract.ticker = "XYZ"
short_put_contract.expiration_date = Date(2022, 04, 14)
short_put_contract.strike_price = 105.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

# other version -
val_ρ = ρ(short_put_contract; Sₒ=113.46, number_of_levels=80, σ=0.5212, T=(27.0 / 365), μ=0.0047)