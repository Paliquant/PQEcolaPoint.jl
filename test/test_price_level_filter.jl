using PQEcolaPoint

# build a binary tree with three levels -
model = build(CRRLatticeModel; number_of_levels = 3, σ = 0.35, T = (14.0 / 365), μ = 0.00174)

# compute -
tmp_array = price(model, 3)