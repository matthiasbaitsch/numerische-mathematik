import numpy as np
from objdict import *


def simple_example():
    s = ObjDict()
    s.EA = 60000
    s.nodes = np.array(
        [[0, 4, 0],
        [0, 0, 3]])
    s.elements = np.array(
        [[0, 0, 2],
        [1, 2, 1]])
    s.forces = np.zeros((2, 3))
    s.forces[0, 2] = 120
    s.supports = np.full((2, 3), False)
    s.supports[:, 0] = True
    s.supports[1, 1] = True
    return s


def girder(l=40, h1=2, h2=7, nn=11):
    s = ObjDict()
    
    # Anzahl Knoten je Seite (ohne Mitte)
    ns = int((nn - 1) / 2)

    # E-Modul
    s.EA = 60000

    # Knoten
    x = np.linspace(-l/2, l/2, nn)
    y1 = 0 * x
    y2 = h2 - (h2 - h1) / (l/2)**2 * x**2
    x = np.concatenate([x, x])
    y = np.concatenate([y1, y2])
    s.nodes = np.array([x, y])

    # Elemente
    ne1 = []
    ne2 = []
    ne1 += range(0, nn-1)
    ne2 += range(1, nn)
    ne1 += range(nn, 2*nn-1)
    ne2 += range(nn+1, 2*nn)
    ne1 += range(0, nn)
    ne2 += range(nn, 2*nn)
    ne1 += range(nn, nn+ns)
    ne2 += range(1, 1+ns)
    ne1 += range(ns, nn-1)
    ne2 += range(nn+ns+1, 2*nn)
    s.elements = np.array([ne1, ne2])

    # Kräfte
    s.forces = np.zeros([2, 2*nn])
    s.forces[1,1:nn-1] = -10

    # Auflager
    s.supports = np.full([2, 2*nn], False)
    s.supports[:,0] = True
    s.supports[1,nn-1] = True
    
    return s
