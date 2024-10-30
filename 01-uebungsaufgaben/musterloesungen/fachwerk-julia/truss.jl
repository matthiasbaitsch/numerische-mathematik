function truss_p(EA, x1, x2, u1, u2)
    l0 = norm(x2 - x1)
    l = norm(x2 + u2 - (x1 + u1))
    d = 1 / l * (x2 + u2 - (x1 + u1))
    t = vcat(-d, d)
    return EA * (l - l0) / l0 * t
end


function truss_k(EA, x1, x2)
    l0 = norm(x2 - x1)
    d0 = (x2 - x1) / l0
    t0 = vcat(-d0, d0)
    return EA / l0 * t0 * t0'
end


function truss_p_lin(EA, x1, x2, u1, u2)
    K = truss_k(EA, x1, x2)
    u = vcat(u1, u2)
    return K * u
end


function truss_n(EA, x1, x2, u1, u2)
    l0 = norm(x2 - x1)
    d0 = (x2 - x1) / l0
    return EA / l0 * (u2 - u1) ⋅ d0
end


function struct_size(s)
    mm1 = extrema(s.nodes[1, :])
    l1 = mm1[2] - mm1[1]
    mm2 = extrema(s.nodes[2, :])
    l2 = mm2[2] - mm1[1]
    return sqrt(l1 * l2)
end


function draw_system(s)
    sz = struct_size(s)
    Nn = size(s.nodes, 2)

    # Graphik und Achsen
    fig = Figure()
    Axis(fig[1, 1], aspect=DataAspect())

    # Elemente
    linesegments!(reshape(s.nodes[:, s.elements], 2, :), color=:black, linewidth=3)

    # Auflager
    h = 1 / sqrt(3)
    s1 = 0.05 * sz * [0 -1 -1 0; 0 -h h 0]
    s2 = 0.05 * sz * [0 -h h 0; 0 -1 -1 0]
    for i = 1:Nn
        x = s.nodes[:, i]
        s.supports[1, i] && lines!(x .+ s1, color=:black)
        s.supports[2, i] && lines!(x .+ s2, color=:black)
    end

    # Kräfte
    f = 0.2 * sz / maximum(norm.(eachcol(s.forces))) * s.forces
    arrows!(s.nodes[1, :], s.nodes[2, :], f[1, :], f[2, :], color=:red)

    # Knoten
    scatter!(s.nodes, color=:white, strokewidth=1)

    # Grafik zurückgeben
    return fig
end


function member_forces(s)
    Ne = size(s.elements, 2)
    N = zeros(Ne)
    for e = 1:Ne
        n1, n2 = s.elements[:, e]
        x1 = s.nodes[:, n1]
        x2 = s.nodes[:, n2]
        u1 = s.u_hat[:, n1]
        u2 = s.u_hat[:, n2]
        N[e] = truss_n(s.EA, x1, x2, u1, u2)
    end
    return N
end


function solve!(s)
    Nn = size(s.nodes, 2)
    Ne = size(s.elements, 2)
    N = 2 * Nn

    # Steifigkeitsmatrix
    K = zeros(N, N)
    for e = 1:Ne
        n1, n2 = s.elements[:, e]
        x1 = s.nodes[:, n1]
        x2 = s.nodes[:, n2]
        Ke = truss_k(s.EA, x1, x2)
        I = [2 * n1 - 1, 2 * n1, 2 * n2 - 1, 2 * n2]
        K[I, I] += Ke
    end

    # Lastvektor
    F = copy(reshape(s.forces, N))

    # Auflager
    idx = reshape(s.supports, N)
    F[idx] .= 0
    K[idx, :] .= 0
    K[diagind(K)[idx]] .= 1

    # Verschiebungen und Normalkraft
    s.u_hat = reshape(K \ F, 2, Nn)
    s.N = member_forces(s)
end


function draw_deformations(s)
    sz = struct_size(s)
    Nn = size(s.nodes, 2)
    max_u = maximum(norm.(eachcol(s.u_hat)))
    xu = s.nodes + 0.1 * sz / max_u * s.u_hat

    # Graphik und Achsen
    fig = Figure()
    Axis(fig[1, 1], aspect=DataAspect())

    # Elemente
    linesegments!(reshape(s.nodes[:, s.elements], 2, :), color=:gray)
    linesegments!(reshape(xu[:, s.elements], 2, :), linewidth=3, color=:black)

    # Auflager
    h = 1 / sqrt(3)
    s1 = 0.05 * sz * [0 -1 -1 0; 0 -h h 0]
    s2 = 0.05 * sz * [0 -h h 0; 0 -1 -1 0]
    for i = 1:Nn
        x = xu[:, i]
        s.supports[1, i] && lines!(x .+ s1, color=:black)
        s.supports[2, i] && lines!(x .+ s2, color=:black)
    end

    # Kräfte
    max_f = maximum(norm.(eachcol(s.forces)))
    f = 0.2 * sz / max_f * s.forces
    arrows!(xu[1, :], xu[2, :], f[1, :], f[2, :], color=:red)

    # Knoten
    scatter!(xu, color=:white, strokewidth=1)

    # Grafik zurückgeben
    return fig
end


function draw_member_forces(s)
    fig = Figure()
    Axis(fig[1, 1], aspect=DataAspect())

    # Elemente
    for n in eachcol(s.elements)
        lines!(s.nodes[:, n], color=:black, linewidth=3)
    end

    # Polygone sammeln
    polys = []
    sz = struct_size(s)
    Ne = size(s.elements, 2)
    max_n = maximum(abs.(s.N))
    scale = 0.1 * sz / max_n
    for e = 1:Ne
        x1 = s.nodes[:, s.elements[1, e]]
        x2 = s.nodes[:, s.elements[2, e]]
        e1 = normalize(x2 - x1)
        normal = [e1[2], -e1[1]]
        offset = scale * s.N[e] * normal
        push!(polys, Point2f[x1, x2, x2+offset, x1+offset])
    end

    # Polygone plotten
    p = poly!(
        polys, color=s.N, strokewidth=1, alpha=0.5,
        colormap=:redblue, colorrange=[-max_n, max_n]
    )
    Colorbar(fig[1, 2], p)

    # Grafik zurückgeben
    return fig
end