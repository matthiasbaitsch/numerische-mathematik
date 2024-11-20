A = [
    1  2  3  4 
    5  6  7  8
]

x = [1, 2, 3, 4, 5, 6, 7, 8]

reshape(A, :)

reshape(x, 2, :)

A = ones(6, 6)
I = [6, 1]
B = [1 2; 3 4]
A[I, I] += B
A
