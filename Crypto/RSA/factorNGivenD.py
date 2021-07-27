from math import gcd
from gmpy2 import next_prime

def factor_n(n, e, d):
    k = (d*e)-1
    print(k)
    lg = 1
    while True:
        g = next_prime(lg)
        lg = g
        print("g: "+str(g))
        t = k
        while (t%2) == 0:
            t = t//2
            x = pow(g, t, n)
            if x > 1:
                y = gcd(x-1, n)
                if y > 1:
                    assert( y*(n//y) == n )
                    return y, n//y


