using PQEcolaPoint

# setup DTE -
T = 72.0
DTE = range(T, stop=0.0,step=-1.0) |> collect

# setup underlying range -
Sₒ = 79.74
IV = 0.4456
σ = Sₒ*(IV)*(√(T/365))
L = round(Sₒ - 2.96*σ)
U = round(Sₒ + 2.96*σ)
S = range(L,stop=U, step=0.5) |> collect

# setup IV array -
IV_array = range(0.1, stop = 1.2, step = 0.05) |> collect

# setup strike coordinates -
K = range(60.0, stop = 125.0, step = 5.0) |> collect

# build JIT lattice model -
JIT_lattice = build(CRRJITContractPremiumLatticeModel, PutContractModel, S, K, IV_array, DTE; number_of_levels = 80)

# create a point -
test_point = build(PQContractPremiumLatticePoint; i = 10, j = 5, s = 20, d = 10)

# decode -
result_tuple = decode(JIT_lattice,test_point)

# encode a point -
encoded_point = encode(JIT_lattice; S = 42.5, IV = 0.30, K = 105.0, DTE = 63.0)
results_tuple_2 = decode(JIT_lattice, encoded_point)