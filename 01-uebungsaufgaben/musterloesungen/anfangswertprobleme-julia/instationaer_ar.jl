function compute_ar(vs, rba, rbi)

    # Matrix vorbelegen
    nv = length(vs)
    A = zeros(nv, nv)

    # Hilfsfunktion Lambda
    Lambda(v1, v2) = 2 / (v1.d / v1.l + v2.d / v2.l)

    # Erste Zeile
    v = vs[1]
    a = 1 / (v.r * v.c * v.d)
    Lr = Lambda(vs[1], vs[2])
    A[1, 1] = a * (Lr + rba.h)
    A[1, 2] = -a * Lr

    # Zweite bis vorletzte Zeile
    for i = 2:nv-1
        v = vs[i]
        a = 1 / (v.r * v.c * v.d)
        Ll = Lambda(vs[i-1], vs[i])
        Lr = Lambda(vs[i], vs[i+1])
        A[i, i-1] = -a * Ll
        A[i, i] = a * (Ll + Lr)
        A[i, i+1] = -a * Lr
    end

    # Letzte Zeile
    v = vs[nv]
    a = 1 / (v.r * v.c * v.d)
    Ll = Lambda(vs[nv-1], vs[nv])
    A[nv, nv-1] = -a * Ll
    A[nv, nv] = a * (Ll + rbi.h)

    # Erste Zeile
    va = vs[1]
    aa = 1 / (va.r * va.c * va.d)

    # Letzte Zeile
    vi = vs[nv]
    ai = 1 / (vi.r * vi.c * vi.d)

    # Funktion r
    r(t) = [aa * rba.h * rba.theta(t); zeros(nv - 2); ai * rbi.h * rbi.theta(t)]

    return A, r
end

