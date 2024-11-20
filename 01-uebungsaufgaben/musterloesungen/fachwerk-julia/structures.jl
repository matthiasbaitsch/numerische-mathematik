function simple_example()    
    s = DotMap()
    s.EA = 60000    
    s.nodes = [
        0 4 0
        0 0 3
    ]    
    s.elements = [
        1 1 3
        2 3 2
    ]
    s.forces = zeros(2, 3)
    s.forces[1, 3] = 120
    s.supports = falses(2, 3)
    s.supports[:, 1] .= true
    s.supports[2, 2] = true
    return s
end


function girder(l=40, h1=2, h2=7, nn=11)
    s = DotMap()

    # Stiffness
    s.EA = 60000

    # Nodes
    ns = (nn - 1) ÷ 2
    x = range(-l / 2, l / 2, nn)
    y1 = zeros(nn)
    y2 = h2 .- (h2 - h1) / (l / 2)^2 * x .^ 2
    s.nodes = stack([vcat(x, x), vcat(y1, y2)], dims=1)

    # Elements
    ne1 = []
    ne2 = []
    append!(ne1, 1:nn-1)
    append!(ne2, 2:nn)
    append!(ne1, nn+1:2nn-1)
    append!(ne2, nn+2:2nn)
    append!(ne1, 1:nn)
    append!(ne2, nn+1:2nn)
    append!(ne1, nn+1:nn+ns)
    append!(ne2, 2:ns+1)
    append!(ne1, ns+1:nn-1)
    append!(ne2, nn+ns+2:2nn)
    s.elements = stack([ne1, ne2], dims=1)

    # Supports
    s.supports = falses(2, 2 * nn)
    s.supports[:, 1] .= true
    s.supports[2, nn] = true

    # Forces
    s.forces = zeros(2, 2 * nn)
    s.forces[2, 2:nn-1] .= -10

    return s
end
