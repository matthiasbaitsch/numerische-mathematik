import numpy as np
import matplotlib.pyplot as plt

class WallLayer:

    def __init__(self, d, l, c, r):
        self.d = d
        self.l = l
        self.c = c
        self.r = r

    def __str__(self):
        return f"WallLayer(d={self.d}, l={self.l}, c={self.c}, r={self.r})"

class Boundary:
    
    def __init__(self, h, theta):
        self.h = h
        self.theta = theta

def index(t, ht):
    return int(np.floor(t * 3600) / ht)

def refine_wall_layers(wall, h):
    rw = []
    for w in wall:
        n = int(np.ceil(w.d / h))
        for _ in range(n):
            rw.append(WallLayer(w.d / n, w.l, w.c, w.r))
    return rw

def plot_sol(t, theta):
    plt.figure()
    for col in theta.T:
        plt.plot(t, col)
        if theta.shape[1] < 5:
            plt.scatter(t, col, s=7)
    plt.show()

def plot_temp(s, t, title=""):
    xx, tt = collect_temperature_data(s, t)
    plt.figure()
    plt.xticks(collect_wall_data(s))
    plt.yticks([-5, 0, 10, 20])
    plt.title(title)
    plt.ylim(-7, 22)
    plt.scatter(xx[1::2], tt[1::2], color='hotpink')
    plt.plot(xx, tt)
    plt.grid(True)
    plt.show()

def collect_wall_data(s):
    p = 0
    nv = len(s)
    x = [0.0]
    for i in range(nv - 1):
        p += s[i].d
        if s[i].l != s[i + 1].l:
            x.append(p)
    x.append(p + s[-1].d)
    return x

def collect_temperature_data(s, theta):
    nv = len(s)
    x = np.zeros(2 * nv + 1)
    t = np.zeros(2 * nv + 1)
    
    x[0] = 0
    t[0] = theta[0]
    x[1] = s[0].d / 2
    t[1] = theta[0]
    
    for i in range(1, nv):
        d1 = s[i-1].d / 2
        l1 = s[i-1].l
        t1 = theta[i-1]
        d2 = s[i].d / 2
        l2 = s[i].l
        t2 = theta[i]
        tm = t2 - (t2 - t1) / (1 + d1 * l2 / (d2 * l1))
        x[2*i] = x[2*i-1] + d1
        t[2*i] = tm
        x[2*i+1] = x[2*i] + d2
        t[2*i+1] = t2
    
    x[2*nv] = x[2*nv-1] + s[nv-1].d / 2
    t[2*nv] = theta[nv-1]
    
    return x, t
