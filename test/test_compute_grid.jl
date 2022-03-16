using PQEcolaPoint
using Dates
using DataFrames

# build array of models -
models = Array{CRRLatticeModel,1}()

# look at these IVs -
IV_array = range(0.01, stop = 1.0, step = 0.01) |> collect
for IV ∈ IV_array

    # build a binary tree with these market conditions -
    model = build(CRRLatticeModel; Sₒ = 109.33, number_of_levels = 80, σ = IV, T = (30.0 / 365), μ = 0.0045)
    push!(models, model)
end

# look at these strikes -
contracts = Array{PutContractModel,1}()
strike_array = range(80.0, stop = 130.0, step = 5.0) |> collect
for K ∈ strike_array

    # what is the contract?
    short_put_contract = PutContractModel()
    short_put_contract.ticker = "XYZ"
    short_put_contract.expiration_date = Date(2022, 04, 1)
    short_put_contract.strike_price = K
    short_put_contract.premium = 0.0
    short_put_contract.number_of_contracts = 1
    short_put_contract.direction = 1
    push!(contracts, short_put_contract)
end

# compute grid -
df = premium(contracts, models)