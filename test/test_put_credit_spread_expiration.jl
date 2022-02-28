using PQEcolaPoint
using Dates

# Simulate a PUT credit spread -

# create a SHORT put contract -
short_put_contract = PutContractModel()
short_put_contract.ticker = "XYZ"
short_put_contract.expiration_date = Date(2022, 04, 14)
short_put_contract.strike_price = 315.0
short_put_contract.premium = 5.25
short_put_contract.number_of_contracts = 1
short_put_contract.direction = -1

# create a LONG put contract -
long_put_contract = PutContractModel()
long_put_contract.ticker = "XYZ"
long_put_contract.expiration_date = Date(2022, 04, 14)
long_put_contract.strike_price = 310.0
long_put_contract.premium = 4.31
long_put_contract.number_of_contracts = 1
long_put_contract.direction = 1

# build model -
put_credit_spread_contract_array = Array{AbstractAssetModel,1}()
push!(put_credit_spread_contract_array, short_put_contract)
push!(put_credit_spread_contract_array, long_put_contract)

# setup the underlying -
underlying_range = range(305.0, stop = 320.0, length = 1000) |> collect

# compute the table -
short_credit_spread_table = expiration(put_credit_spread_contract_array, underlying_range)
