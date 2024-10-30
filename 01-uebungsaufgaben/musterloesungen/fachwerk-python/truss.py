import numpy as np
import matplotlib.pyplot as plt

from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection


def truss_p(EA, x1, x2, u1, u2):
    l0 = np.linalg.norm(x2 - x1)
    l = np.linalg.norm(x2 + u2 - (x1+u1))
    d = 1 / l * (x2 + u2 - (x1+u1))
    t = np.concatenate((-d, d))
    return EA * (l - l0) / l0 * t


def truss_ke(EA, x1, x2):
    l0 = np.linalg.norm(x2 - x1)
    d0 = (x2 - x1) / l0
    t0 = np.concatenate((-d0, d0))
    return EA / l0 * np.outer(t0, t0)


def truss_n(EA, x1, x2, u1, u2):
    l0 = np.linalg.norm(x2 - x1)
    d0 = (x2 - x1) / l0
    return EA / l0 * np.dot(u2 - u1, d0)


def truss_p_lin(EA, x1, x2, u1, u2):
    K = truss_ke(EA, x1, x2)
    u = np.concatenate((u1, u2))
    return K @ u


def draw_system(s):
    
    # Knoten
    plt.scatter(s.nodes[0, :], s.nodes[1, :], color='black', zorder=2, s=15)
    
    # Elemente
    for e in range(s.elements.shape[1]):
        n = s.elements[:, e]
        plt.plot(s.nodes[0, n], s.nodes[1, n], color = 'black')    
    
    # Kräfte
    plt.quiver(
        s.nodes[0, :], s.nodes[1, :], 
        s.forces[0, :], s.forces[1, :], 
        color = 'red', width=0.003
    )
    
    # Auflager
    sn = s.supports[0, :]
    sx = s.nodes[0, sn]
    sy = s.nodes[1, sn]
    plt.scatter(sx, sy, marker=5, s=150, color='tab:blue')
    sn = s.supports[1, :]
    sx = s.nodes[0, sn]
    sy = s.nodes[1, sn]
    plt.scatter(sx, sy, marker=6, s=150, color='tab:blue')
    
    # Anzeigen
    plt.axis('equal')
    plt.show()


def solve(s):

    # Anzahl Knoten und Freiheitsgrade
    Nn = s.nodes.shape[1]
    Ne = s.elements.shape[1]
    N = 2 * Nn
    
    # Globale Steifigkeitsmatrix
    K = np.zeros([N, N])
    for e in range(0, Ne):
        n1, n2 = s.elements[:, e]
        x1 = s.nodes[:, n1]
        x2 = s.nodes[:, n2]
        Ke = truss_ke(s.EA, x1, x2)
        I = [2*n1, 2*n1+1, 2*n2, 2*n2+1]    
        K[np.ix_(I, I)] += Ke

    # Lastvektor
    F = np.reshape(s.forces, N, order='F')

    # Auflager
    idx = np.reshape(s.supports, N, order='F')
    F[idx] = 0
    K[idx, :] = 0
    K[idx, idx] = 1

    # LGS lösen und Verschiebungen in Matrix ablegen
    s.u_hat = np.reshape(np.linalg.solve(K, F), (2, Nn), order='F')
    s.N = member_forces(s)


def member_forces(s):
    Ne = s.elements.shape[1]
    N = np.zeros(Ne)
    
    for e in range(0, Ne):
        n1, n2 = s.elements[:, e]
        x1 = s.nodes[:, n1]
        x2 = s.nodes[:, n2]
        u1 = s.u_hat[:, n1]
        u2 = s.u_hat[:, n2]
        N[e] = truss_n(s.EA, x1, x2, u1, u2)
    
    return N


def draw_deformation(s, scale):
    
    # Knotenkoordinaten verschoben
    nu = s.nodes + scale * s.u_hat
    
    # Knoten
    plt.scatter(nu[0, :], nu[1, :], color='black', zorder=2, s=15)
    
    # Elemente
    for e in range(s.elements.shape[1]):
        n = s.elements[:, e]
        plt.plot(s.nodes[0, n], s.nodes[1, n], color = 'gray', zorder=-5)
        plt.plot(nu[0, n], nu[1, n], color = 'black')    
    
    # Auflager
    sn = s.supports[0, :]
    sx = nu[0, sn]
    sy = nu[1, sn]
    plt.scatter(sx, sy, marker=5, s=150, color='tab:blue')
    sn = s.supports[1, :]
    sx = nu[0, sn]
    sy = nu[1, sn]
    plt.scatter(sx, sy, marker=6, s=150, color='tab:blue')
    
    # Anzeigen
    plt.axis('equal')
    plt.show()


def draw_member_forces(s, scale):
    
    # Liste von Patches    
    patches = []
    
    # Patches für Normalkraft und Elemente plotten
    for e in range(s.elements.shape[1]):
        n1, n2 = s.elements[:, e]
        x1 = s.nodes[:, n1]
        x2 = s.nodes[:, n2]

        e1 = np.array(x2 - x1) / np.linalg.norm(x2 - x1)
        normal = np.array([e1[1], -e1[0]])
        o = scale *s.N[e] * normal
        patches.append(Polygon(np.row_stack((x1, x2, x2 + o, x1 + o))))
        
        plt.plot([x1[0], x2[0]], [x1[1], x2[1]], color = 'black')    
    
    # Betragsmaessig groesste Normalkraft
    max_n = np.max(np.abs(s.N))

    # Plotten
    pc = PatchCollection(patches, edgecolor='black', alpha=0.6)
    pc.set_array(s.N)
    pc.set_clim(-max_n, max_n)
    pc.set_cmap('bwr')
    plt.gca().add_collection(pc)
    plt.axis('equal')
    plt.colorbar(pc)
    plt.show()
