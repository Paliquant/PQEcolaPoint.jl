using PQEcolaPoint
using Dates

# build a PUT contract -
put_options = Dict{String,Any}()
put_options["ticker"] = "AMD"
put_options["expiration_date"] = Date(2022, 04, 14)
put_options["strike_price"] = 105.0
put_options["premium"] = 3.59
put_options["number_of_contracts"] = 1
put_options["direction"] = -1
put_options["current_price"] = 2.87
put_contract_model = build(PutContractModel, put_options)

# build a CALL contract -
call_options = Dict{String,Any}()
call_options["ticker"] = "AMD"
call_options["expiration_date"] = Date(2022, 04, 14)
call_options["strike_price"] = 130.0
call_options["premium"] = 302.0
call_options["number_of_contracts"] = 1
call_options["direction"] = -1
call_options["current_price"] = 6.28
call_contract_model = build(CallContractModel, call_options)

# build an EQUITY model -
equity_options = Dict{String,Any}()
equity_options["ticker"] = "AMD"
equity_options["purchase_price"] = 106.0
equity_options["current_price"] = 122.99
equity_options["direction"] = 1
equity_options["number_of_shares"] = 1
equity_contract_model = build(EquityModel, equity_options)