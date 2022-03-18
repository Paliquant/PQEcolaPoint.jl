using PQEcolaPoint

# build a binary tree with three levels -
model = build(CRRLatticeModel; number_of_levels=84, σ=0.35, T=(28.0 / 365), μ=0.00174)

# compute -
a = price(model, 84; weights=true)