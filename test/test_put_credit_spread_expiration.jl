using PQEcolaPoint
using Dates

# Simulate a PUT credit spread -
function ticker(type::String, underlying::String, expiration::Date, K::Float64)::String

    # build components for the options ticker -
    ticker_component = uppercase(underlying)
    YY = year(expiration) - 2000 # hack to get 2 digit year 
    MM = lpad(month(expiration), 2, "0")
    DD = lpad(day(expiration), 2, "0")

    # compute the price code -
    strike_component = lpad(convert(Int64,K*1000), 8, "0")

    # build the ticker string -
    ticker_string = "O:$(ticker_component)$(YY)$(MM)$(DD)$(type)$(strike_component)"
    
    # return -
    return ticker_string
end

# create a SHORT put contract -
K₁ = 315.0
D₁ = Date(2022, 04, 14)
short_put_contract = PutContractModel()
short_put_contract.ticker = ticker("P", "XYZ", D₁, K₁)
short_put_contract.expiration_date = D₁
short_put_contract.strike_price = K₁
short_put_contract.premium = 5.25
short_put_contract.number_of_contracts = 1
short_put_contract.direction = -1

# create a LONG put contract -
K₂ = 310.0
D₂ = Date(2022, 04, 14)
long_put_contract = PutContractModel()
long_put_contract.ticker = ticker("P", "XYZ", D₂, K₂)
long_put_contract.expiration_date = D₂
long_put_contract.strike_price = K₂
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
