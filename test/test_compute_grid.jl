using PQEcolaPoint
using Dates
using DataFrames

# simulation dictionary -
simulation_archive = Dict{NamedTuple,DataFrame}()

# build array of models -
models = Array{CRRLatticeModel,1}()
Sₒ = 81.68
σ = Sₒ*(0.50)*sqrt(37/365)
L = Sₒ - 2.96*σ
U = Sₒ + 2.96*σ
DTEₒ = 37
underlying_price_range = range(L,stop=U,length = 10) |> collect
IV_array = range(0.1, stop = 1.0, step = 0.1) |> collect
strike_array = range(50, stop = 125, step = 5) |> collect
dte_array = range(DTEₒ, stop = 1.0, step=-1) |> collect

# build contract array -
contracts = Array{PutContractModel,1}()
for K ∈ strike_array

    # what is the contract?
    short_put_contract = PutContractModel()
    short_put_contract.ticker = "XYZ"
    short_put_contract.expiration_date = Date(2022, 05, 06)
    short_put_contract.strike_price = K
    short_put_contract.premium = 0.0
    short_put_contract.number_of_contracts = 1
    short_put_contract.direction = 1
    push!(contracts, short_put_contract)
end

for underlying_price ∈ underlying_price_range
    for dte_value ∈ dte_array
        for IV ∈ IV_array

            # build a binary tree with these market conditions -
            model = build(CRRLatticeModel; Sₒ = underlying_price, number_of_levels = 80, σ = IV, T = (dte_value / 365), μ = 0.0045)
            push!(models, model)
        end

        # compute grid -
        df = premium(contracts, models)

        # build the key -
        key_tuple = (
            Sₒ = underlying_price,
            DTE = dte_value
        )

        # cache -
        simulation_archive[key_tuple] = df

        # clean out the model array -
        empty!(models)

        @info (underlying_price, dte_value)
    end
end