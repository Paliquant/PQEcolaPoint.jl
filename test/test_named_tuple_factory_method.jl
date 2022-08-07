using PQEcolaPoint
using Dates

# Dictionary version -
# build a PUT contract -
put_options = Dict{String,Any}()
put_options["ticker"] = "AMD"
put_options["expiration_date"] = Date(2022, 04, 14)
put_options["strike_price"] = 105.0
put_options["premium"] = 3.59
put_options["number_of_contracts"] = 1
put_options["direction"] = -1
put_options["current_price"] = 2.87
put_contract_model_dict = build(PutContractModel, put_options)

put_contract_model_tuple = build(PutContractModel, (
    ticker = "AMD",
    expiration_date = Date(2022,10,21),
    strike_price = 90.0,
    premium = 3.75,
    number_of_contracts = 1,
    direction = -1,
    current_price = 3.75
));

# build a CALL contract -
# call_options = Dict{String,Any}()
# call_options["ticker"] = "AMD"
# call_options["expiration_date"] = Date(2022, 04, 14)
# call_options["strike_price"] = 130.0
# call_options["premium"] = 302.0
# call_options["number_of_contracts"] = 1
# call_options["direction"] = -1
# call_options["current_price"] = 6.28
# call_contract_model = build(CallContractModel, call_options)

call_contract_model_tuple = build(CallContractModel, (
    ticker = "AMD",
    expiration_date = Date(2022,10,21),
    strike_price = 110.0,
    premium = 5.80,
    number_of_contracts = 1,
    direction = -1,
    current_price = 5.80
));

# build an EQUITY model -
# equity_options = Dict{String,Any}()
# equity_options["ticker"] = "AMD"
# equity_options["purchase_price"] = 106.0
# equity_options["current_price"] = 122.99
# equity_options["direction"] = 1
# equity_options["number_of_shares"] = 1
# equity_contract_model = build(EquityModel, equity_options)
equity_model_tuple = build(EquityModel, (
    ticker = "AMD",
    number_of_shares = 1,
    direction = 1,
    current_price = 101.96,
    purchase_price = 101.96
));
