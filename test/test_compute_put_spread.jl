using PQEcolaPoint
using Dates

# short leg -
short_put_contract = PutContractModel()
short_put_contract.ticker = "XYZ"
short_put_contract.expiration_date = Date(2022, 04, 14)
short_put_contract.strike_price = 105.0
short_put_contract.premium = 0.0
short_put_contract.number_of_contracts = 1
short_put_contract.direction = 1

# long leg -
long_put_contract = PutContractModel()
long_put_contract.ticker = "XYZ"
long_put_contract.expiration_date = Date(2022, 04, 14)
long_put_contract.strike_price = 100.0
long_put_contract.premium = 0.0
long_put_contract.number_of_contracts = 1
long_put_contract.direction = 1

# contracts -
contracts = Array{PutContractModel,1}()
push!(contracts, short_put_contract)
push!(contracts, long_put_contract)

# compute the theta array -
Sₒ = 113.46
model = build(CRRLatticeModel; Sₒ = Sₒ, number_of_levels=80, σ=0.5212, T=(37.0 / 365), μ=0.0045)
C = premium(contracts, model)
θ_array = θ(contracts; Sₒ = Sₒ, number_of_levels=80, σ=0.5212, T=(37.0 / 365), μ=0.0047)
δ_array = δ(contracts; Sₒ = Sₒ, number_of_levels=80, σ=0.5212, T=(37.0 / 365), μ=0.0047)
