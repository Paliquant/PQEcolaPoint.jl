using PQEcolaPoint
using Dates

# what is the contract?
short_put_contract = PutContractModel()
short_put_contract.ticker = "XYZ"
short_put_contract.expiration_date = Date(2022, 04, 14)
short_put_contract.strike_price = 65.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

# other version -
# origin_point = encode(JIT_lattice; S = 70.12, DTE = 53.0, IV = 0.4926, K = 65.0)
val_γ = γ(short_put_contract; Sₒ=70.12, number_of_levels=80, σ=0.5129, T=(53.0 / 365), μ=0.0047)