import numpy as np

def compute_ar(vs, rba, rbi):
    # Matrix initialisieren
    nv = len(vs)
    A = np.zeros((nv, nv))

    # Hilfsfunktion la
    def la(v1, v2):
        return 2 / (v1.d / v1.l + v2.d / v2.l)

    # Erste Zeile
    v = vs[0]
    a = 1 / (v.r * v.c * v.d)
    Lr = la(vs[0], vs[1])
    A[0, 0] = a * (Lr + rba.h)
    A[0, 1] = -a * Lr

    # Zweite bis vorletzte Zeile
    for i in range(1, nv - 1):
        v = vs[i]
        a = 1 / (v.r * v.c * v.d)
        Ll = la(vs[i - 1], vs[i])
        Lr = la(vs[i], vs[i + 1])
        A[i, i - 1] = -a * Ll
        A[i, i] = a * (Ll + Lr)
        A[i, i + 1] = -a * Lr

    # Letzte Zeile
    v = vs[-1]
    a = 1 / (v.r * v.c * v.d)
    Ll = la(vs[-2], vs[-1])
    A[-1, -2] = -a * Ll
    A[-1, -1] = a * (Ll + rbi.h)

    # Erste Zeile Parameter
    va = vs[0]
    aa = 1 / (va.r * va.c * va.d)

    # Letzte Zeile Parameter
    vi = vs[-1]
    ai = 1 / (vi.r * vi.c * vi.d)

    # Funktion r
    def r(t):
        rt = np.zeros(nv)
        rt[0] = aa * rba.h * rba.theta(t)
        rt[-1] = ai * rbi.h * rbi.theta(t)
        return rt

    return A, r
