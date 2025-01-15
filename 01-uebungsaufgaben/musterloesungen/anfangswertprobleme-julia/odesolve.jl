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
        y += h * F(x, y)
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
        y += h * F(x, y)
    end
    return xs, stack(ys, dims=1)
end