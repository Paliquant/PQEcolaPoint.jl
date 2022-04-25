using PQEcolaPoint

# setup DTE -
T = 149.0
DTE = range(T, stop=0.0,step=-1.0) |> collect

# setup underlying range -
Sₒ = 69.41
IV = 0.4693
σ = Sₒ*(IV)*(√(T/365))
L = round(Sₒ - 1.96*σ)  # 95%
U = round(Sₒ + 1.96*σ)  # 95%
S = range(max.(L, 0.0),stop=U, step=0.01) |> collect

# setup IV array -
IV_array = range(0.1, stop = 1.2, step = 0.005) |> collect

# setup strike coordinates -
K = range(45.0, stop = 90.0, step = 5.0) |> collect

# build JIT lattice model -
JIT_lattice = build(CRRJITContractPremiumLatticeModel, PutContractModel, S, K, IV_array, DTE; number_of_levels = 80)

# build my points -
test = roll(JIT_lattice, start_point=>end_point)

# origin version -
origin_point = encode(JIT_lattice; S = 70.98, DTE = 56.0, IV = 0.53, K = 65.0)
start_point = encode(JIT_lattice; S = 69.41, DTE = 56.0, IV = 0.5957, K = 65.0)
end_point = encode(JIT_lattice; S = 69.41 , DTE = 63.0, IV = 0.5818, K = 55.0)
test_2 = roll(JIT_lattice, origin_point, start_point=>end_point)
