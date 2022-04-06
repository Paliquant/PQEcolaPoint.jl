using PQEcolaPoint

# setup DTE -
T = 300.0
DTE = range(T, stop=0.0,step=-1.0) |> collect

# setup underlying range -
Sₒ = 76.04
IV = 0.4456
σ = Sₒ*(IV)*(√(T/365))
L = round(Sₒ - 1.96*σ)  # 95%
U = round(Sₒ + 1.96*σ)  # 95%
S = range(max.(L, 0.0),stop=U, step=0.5) |> collect

# setup IV array -
IV_array = range(0.1, stop = 1.2, step = 0.05) |> collect

# setup strike coordinates -
K = range(50.0, stop = 125.0, step = 5.0) |> collect

# build JIT lattice model -
JIT_lattice = build(CRRJITContractPremiumLatticeModel, PutContractModel, S, K, IV_array, DTE; number_of_levels = 80)

# build a point -
test_point = encode(JIT_lattice; S = 73.0, DTE = 35.0, IV = 0.4498, K = 75.0)

# compute delta -
δ_value = δ(JIT_lattice, test_point)