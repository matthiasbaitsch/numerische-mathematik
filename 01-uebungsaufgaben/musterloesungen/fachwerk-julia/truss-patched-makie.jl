function draw_system(s)
    sz = struct_size(s)
    nn = size(s.nodes, 2)

    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())

    # Elements
    for n in eachcol(s.elements)
        lines!(s.nodes[:, n], color=:black, linewidth=3)
    end

    # Supports
    h = 1 / sqrt(3)
    s1 = 0.05 * sz * [0 -1 -1 0; 0 -h h 0]
    s2 = 0.05 * sz * [0 -h h 0; 0 -1 -1 0]
    for (i, x) = enumerate(eachcol(s.nodes))
        s.supports[1, i] && lines!(x .+ s1, color=:black)
        s.supports[2, i] && lines!(x .+ s2, color=:black)
    end

    # Forces with scaling factor
    sf = 0.2 * sz / maximum(norm.(eachcol(s.forces))) * s.forces
    arrows!(s.nodes, sf, color=:red)

    # Nodes
    scatter!(s.nodes, color=:white, strokewidth=1)

    return fig
end