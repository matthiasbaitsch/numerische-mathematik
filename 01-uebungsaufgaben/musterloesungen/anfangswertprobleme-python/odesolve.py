import numpy as np

def euler(F, I, h, y0):
    y = y0
    xs = []
    ys = []
    for x in np.arange(I[0], I[1], h):
        xs.append(x)
        ys.append(y)
        y = y + h * F(x, y)
    return xs, np.array(ys)

def halbschritt(F, I, h, y0):
    y = y0
    xs = []
    ys = []
    for x in np.arange(I[0], I[1], h):
        xs.append(x)
        ys.append(y)
        y = y + h * F(x, y)
    return xs, np.array(ys)

def rungekutta(F, I, h, y0):
    y = y0
    xs = []
    ys = []
    for x in np.arange(I[0], I[1], h):
        xs.append(x)
        ys.append(y)
        y = y + h * F(x, y)
    return xs, np.array(ys)
