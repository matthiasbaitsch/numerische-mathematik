function euler(F, I, h, y0)
    y = y0
    xs = Float64[]
    ys = []
    for x = I[1]:h:I[2]
        push!(xs, x)
        push!(ys, y)
        y += h * F(x, y)
    end
    return xs, stack(ys, dims=1)
end

function halbschritt(F, I, h, y0)
    y = y0
    xs = Float64[]
    ys = []
    for x = I[1]:h:I[2]
        push!(xs, x)
        push!(ys, y)
        k1 = F(x, y)
        k2 = F(x + h / 2, y + h / 2 * k1)
        y += h * k2
    end
    return xs, stack(ys, dims=1)
end

function rungekutta(F, I, h, y0)
    y = y0
    xs = Float64[]
    ys = []
    for x = I[1]:h:I[2]
        push!(xs, x)
        push!(ys, y)
        k1 = F(x, y)
        k2 = F(x + h / 2, y + h / 2 * k1)
        k3 = F(x + h / 2, y + h / 2 * k2)
        k4 = F(x + h, y + h * k3) 
        y = y + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
    end
    return xs, stack(ys, dims=1)
end