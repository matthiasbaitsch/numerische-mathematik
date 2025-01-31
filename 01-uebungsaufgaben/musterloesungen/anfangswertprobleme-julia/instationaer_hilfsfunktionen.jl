struct WallLayer
    d
    l
    c
    r
end

struct Boundary
    h
    theta
end

index(t, ht) = Int(floor(t * 3600) / ht)

function refine_wall_layers(wall, h)
    rw = []
    for w = wall
        n = Int(ceil(w.d / h))
        for _ = 1:n
            push!(rw, WallLayer(w.d / n, w.l, w.c, w.r))
        end
    end
    rw
end

function plot_sol(t, theta)
    f = Figure()
    Axis(f[1, 1])
    for c = eachcol(theta)
        if size(theta, 2) < 5
            scatterlines!(t, c, markersize=7)
        else
            lines!(t, c)
        end
    end
    return f
end

function plot_temp(s, t, title="")
    xx, tt = collect_temperature_data(s, t)
    f = Figure()
    ax = Axis(f[1, 1], xticks=collect_wall_data(s), yticks=[-5, 0, 10, 20], title=title)
    ylims!(ax, -7, 22)
    lines!(xx, tt)
    scatter!(xx[2:2:end], tt[2:2:end], color=:hotpink)
    return f
end

function collect_wall_data(s)
    p = 0
    nv = length(s)
    x = [0.0]
    for i = 1:nv-1
        p += s[i].d
        s[i].l != s[i+1].l && append!(x, p)
    end
    push!(x, p + s[end].d)
    return x
end

function collect_temperature_data(s, theta)
    nv = length(s)
    x = zeros(2 * nv + 1)
    t = zeros(2 * nv + 1)

    x[1] = 0
    t[1] = theta[1]
    x[2] = s[1].d / 2
    t[2] = theta[1]

    for i = 2:nv
        d1 = s[i-1].d / 2
        l1 = s[i-1].l
        t1 = theta[i-1]
        d2 = s[i].d / 2
        l2 = s[i].l
        t2 = theta[i]
        tm = t2 - (t2 - t1) / (1 + d1 * l2 / (d2 * l1))
        x[2*i-1] = x[2*i-2] + d1
        t[2*i-1] = tm
        x[2*i] = x[2*i-1] + d2
        t[2*i] = t2
    end

    x[2*nv+1] = x[2*nv] + s[nv].d / 2
    t[2*nv+1] = theta[nv]

    return x, t
end