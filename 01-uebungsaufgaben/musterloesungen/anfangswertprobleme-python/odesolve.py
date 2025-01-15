import numpy as np

def euler(F, I, h, y0):
    y = y0
    xs = []
    ys = []
    for x in np.arange(I[0], I[1], h):
        xs.append(x)
        ys.append(y)
        y = y + h * F(x, y)
    return np.array(xs), np.array(ys)

def halbschritt(F, I, h, y0):
    y = y0
    xs = []
    ys = []
    for x in np.arange(I[0], I[1], h):
        xs.append(x)
        ys.append(y)
        k1 = F(x, y)
        k2 = F(x + h / 2, y + h / 2 * k1)
        y = y + h * k2
    return np.array(xs), np.array(ys)

def rungekutta(F, I, h, y0):
    y = y0
    xs = []
    ys = []
    for x in np.arange(I[0], I[1], h):
        xs.append(x)
        ys.append(y)
        k1 = F(x, y)
        k2 = F(x + h / 2, y + h / 2 * k1)
        k3 = F(x + h / 2, y + h / 2 * k2)
        k4 = F(x + h, y + h * k3) 
        y = y + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
    return np.array(xs), np.array(ys)
