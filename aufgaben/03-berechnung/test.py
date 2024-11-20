import numpy as np

A = np.ones([6, 6])
I = [5, 0]
B = np.array([[1, 2], [3, 4]])
A[np.ix_(I, I)] += B
print(A)
