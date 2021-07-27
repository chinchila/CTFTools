# https://eprint.iacr.org/2015/398.pdf

def two_weak(n, M, k):
    C = isqrt(2*pow(k,3))

    mat = [[0 for i in range(2*k+1)]for j in range(2*k+1)]
    for i in range(2*k):
        mat[i][i] = 1
        mat[i][-1] = C*pow(M, 2*k-i)

    mat[-1][-1] = -C*n

    L = matrix(mat)
    Q = L.LLL()

    w = []
    for i in range(2*k):
        w.append(abs(Q[-1][i]))

    w.append(abs(Q[-1][-1])//C)
    w.reverse()

    P.<X> = PolynomialRing(ZZ)
    poly = sum([ w[i]*X^i for i in range(2*k+1)])

    fac = poly.factor()
    assert(len(fac) > 1)

    u = fac[0][0].coefficients()
    ap = sum([ u[i]*pow(M, i) for i in range(len(u)) ])
    p = gcd(ap, n)
    assert(p > 1 and n%p == 0 )
    return p

def test_two():
    n = 18128727522177729435347634587168292968987318316812435932174117774340029

    M = 2^50
    k = 2

    p = two_weak(n, M, k)
    q = n//p
    assert(p == 126198501118389160989977983392586327)
    assert(q == 143652478924221397696146709897519627)

test_two()