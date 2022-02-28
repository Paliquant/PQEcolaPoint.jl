using PQEcolaPoint
using Dates

# create a SHORT put contract -
put_contract = CallContractModel()
put_contract.ticker = "XYZ"
put_contract.expiration_date = Date(2022, 04, 14)
put_contract.strike_price = 105.0
put_contract.premium = 1.0
put_contract.number_of_contracts = 1
put_contract.direction = 1

# setup the underlying -
underlying_range = range(100.0, stop = 110.0, length = 1000) |> collect

# compute the table -
short_put_table = expiration(put_contract, underlying_range)
