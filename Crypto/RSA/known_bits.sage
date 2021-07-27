def trivariateCoppersmith(pol, X, Y, Z, l=2, debug=False):
    P.<x,y,z> = PolynomialRing(ZZ)
    pol = pol(x,y,z)

    # Handle case where pol(0,0,0) == 0
    xoffset = 0

    while pol(xoffset,0,0) == 0:
        xoffset += 1

    pol = pol(x+xoffset,y,z)

    # Handle case where gcd(pol(0,0,0),X*Y*Z) != 1
    while gcd(pol(0,0,0), X) != 1:
        X = next_prime(X, proof=False)

    while gcd(pol(0,0,0), Y) != 1:
        Y = next_prime(Y, proof=False)

    while gcd(pol(0,0,0), Z) != 1:
        Z = next_prime(Z, proof=False)

    pol = P(pol//gcd(pol.coefficients())) # seems to be helpful
    p000 = pol(0,0,0)

    # maximum degree of any variable
    delta = max(pol.degree(x),pol.degree(y),pol.degree(z))

    W = max(abs(i) for i in pol(x*X,y*Y,z*Z).coefficients())
    u = W + ((1-W) % abs(p000))
    N = u*(X*Y*Z)^l # modulus for polynomials

    # Construct polynomials
    p000inv = inverse_mod(p000,N)
    polq = P(sum((i*p000inv % N)*j for i,j in zip(pol.coefficients(),
                                                 pol.monomials())))
    polynomials = []
    for i in range(delta+l+1):
        for j in range(delta+l+1):
            for k in range(delta+l+1):
                if 0 <= i <= l and 0 <= j <= l and 0 <= k <= l:
                    polynomials.append(polq * x^i * y^j * z^k * X^(l-i) * Y^(l-j) * Z^(l-k))
                else:
                    polynomials.append(x^i * y^j * z^k * N)

    # Make list of monomials for matrix indices
    monomials = []
    for i in polynomials:
        for j in i.monomials():
            if j not in monomials:
                monomials.append(j)
    monomials.sort()

    # Construct lattice spanned by polynomials with xX, yY, zZ
    L = matrix(ZZ,len(monomials))
    for i in range(len(monomials)):
        for j in range(len(monomials)):
            L[i,j] = polynomials[i](X*x,Y*y,Z*z).monomial_coefficient(monomials[j])

    # makes lattice upper triangular
    # probably not needed, but it makes debug output pretty
    L = matrix(ZZ,sorted(L,reverse=True))

    if debug:
        print("Bitlengths of matrix elements (before reduction):")
        print(L.apply_map(lambda x: x.nbits()).str())
        set_verbose(2)

    L = L.LLL()

    if debug:
        print("Bitlengths of matrix elements (after reduction):")
        print(L.apply_map(lambda x: x.nbits()).str())

    roots = []
    P2.<q> = PolynomialRing(ZZ)

    for i in range(L.nrows()-1):
        for j in range(i+1,L.nrows()):
            print("Trying rows %d, %d" % (i,j))
            pol2 = P(sum(map(mul, zip(L[i],monomials)))(x/X,y/Y,z/Z))
            pol3 = P(sum(map(mul, zip(L[j],monomials)))(x/X,y/Y,z/Z))

            r = pol.resultant(pol2, z)
            r2 = pol.resultant(pol3, z)
            r = r.resultant(r2,y)
            assert r.is_univariate()

            if r.is_constant(): # not independent
                continue

            r = r(q,0,0) # convert to univariate polynomial

            if len(r.roots()) > 0:
                for x0, _ in r.roots():
                    if x0 == 0:
                        continue
                    if debug:
                        print("Potential x0:",x0)
                    for y0, _ in P2(r2(x0,q,0)).roots():
                        if debug:
                            print("Potential y0:",y0)
                        for z0, _ in P2(pol(x0,y0,q)).roots():
                            if debug:
                                print("Potential z0:",z0)
                            if pol(x0-xoffset,y0,z0) == 0:
                                roots += [(x0-xoffset,y0,z0)]
    return roots

def bivariateCoppersmith(pol, X, Y, k=2, debug=False):
    """
    http://www.jscoron.fr/publications/bivariate.pdf
    Returns all small roots of pol.
    Applies Coron's reformulation of Coppersmith's algorithm for finding small
    integer roots of bivariate polynomials modulo an integer.
    Args:
        pol: The polynomial to find small integer roots of.
        X: Upper limit on x.
        Y: Upper limit on y.
        k: Determines size of lattice. Increase if the algorithm fails.
        debug: Turn on for debug print stuff.
    Returns:
        A list of successfully found roots [(x0,y0), ...].
    Raises:
        ValueError: If pol is not bivariate
    """

    if pol.nvariables() != 2:
        raise ValueError("pol is not bivariate")

    P.<x,y> = PolynomialRing(ZZ)
    pol = pol(x,y)

    # Handle case where pol(0,0) == 0
    xoffset = 0

    while pol(xoffset,0) == 0:
        xoffset += 1

    pol = pol(x+xoffset,y)

    # Handle case where gcd(pol(0,0),X*Y) != 1
    while gcd(pol(0,0), X) != 1:
        X = next_prime(X, proof=False)

    while gcd(pol(0,0), Y) != 1:
        Y = next_prime(Y, proof=False)

    pol = P(pol//gcd(pol.coefficients())) # seems to be helpful
    p00 = pol(0,0)
    delta = max(pol.degree(x),pol.degree(y)) # maximum degree of any variable

    W = max(abs(i) for i in pol(x*X,y*Y).coefficients())
    u = W + ((1-W) % abs(p00))
    N = u*(X*Y)^k # modulus for polynomials

    # Construct polynomials
    p00inv = inverse_mod(p00,N)
    polq = P(sum((i*p00inv % N)*j for i,j in zip(pol.coefficients(),
                                                 pol.monomials())))
    polynomials = []
    for i in range(delta+k+1):
        for j in range(delta+k+1):
            if 0 <= i <= k and 0 <= j <= k:
                polynomials.append(polq * x^i * y^j * X^(k-i) * Y^(k-j))
            else:
                polynomials.append(x^i * y^j * N)

    # Make list of monomials for matrix indices
    monomials = []
    for i in polynomials:
        for j in i.monomials():
            if j not in monomials:
                monomials.append(j)
    monomials.sort()

    # Construct lattice spanned by polynomials with xX and yY
    L = matrix(ZZ,len(monomials))
    for i in range(len(monomials)):
        for j in range(len(monomials)):
            L[i,j] = polynomials[i](X*x,Y*y).monomial_coefficient(monomials[j])

    # makes lattice upper triangular
    # probably not needed, but it makes debug output pretty
    L = matrix(ZZ,sorted(L,reverse=True))

    if debug:
        print("Bitlengths of matrix elements (before reduction):")
        print(L.apply_map(lambda x: x.nbits()).str())

    L = L.LLL()

    if debug:
        print("Bitlengths of matrix elements (after reduction):")
        print(L.apply_map(lambda x: x.nbits()).str())

    roots = []

    for i in range(L.nrows()):
        if debug:
            print("Trying row %d" % i)

        # i'th row converted to polynomial dividing out X and Y
        pol2 = P(sum(map(mul, zip(L[i],monomials)))(x/X,y/Y))

        r = pol.resultant(pol2, y)

        if r.is_constant(): # not independent
            continue

        for x0, _ in r.univariate_polynomial().roots():
            if x0-xoffset in [i[0] for i in roots]:
                continue
            if debug:
                print("Potential x0:",x0)
            for y0, _ in pol(x0,y).univariate_polynomial().roots():
                if debug:
                    print("Potential y0:",y0)
                if (x0-xoffset,y0) not in roots and pol(x0,y0) == 0:
                    roots.append((x0-xoffset,y0))
    return roots

def factor_given_msb(p0, N, unknown_bits, beta=0.44, epsilon=1/32):
    F.<x> = PolynomialRing(Zmod(N))
    f = (p0 << unknown_bits) + x
    x0 = f.small_roots(X=(2^unknown_bits), beta=beta, epsilon=epsilon)
    if len(x0) > 0:
        return (p0 << unknown_bits) + x0[0]
    return 1

def factor_given_lsb(p0, n, lbits, nbits, k=2):
    ln = 2**lbits
    q0 = (n * inverse_mod(p0,ln)) % ln
    X = Y = 2^(nbits+1-lbits)
    P.<x,y> = PolynomialRing(ZZ)
    pol = (ln*x+p0)*(ln*y+q0) - n
    res = bivariateCoppersmith(pol, X, Y, k)
    if len(res) > 0:
        x0_2, y0_2 = res[0]
        p_2 = x0_2*ln + p0
        q_2 = y0_2*ln + q0
        return p_2, q_2
    return 1, 1

def factor_shared_msb_lsb(size, knownbits, msb, lsb, N, beta=0.44, epsilon=1/64):
    """
    This works when p and q shares msb and lsb
    size: size of one of the primes
    known bits: size of lsb and msb (same value) known.
    """
    R = 2**(knownbits//2)
    invR = inverse_mod(R,N)
    F.<x> = PolynomialRing(Zmod(N))
    f = x + (msb+lsb)*invR
    rts = f.small_roots(X=2^(size-knownbits)-1, beta=beta, epsilon=epsilon)
    if len(rts) > 0:
        return rts[0]*R+msb+lsb
    return 1

def test_shared_msb_lsb():
    size = 2048
    p = random_prime(2**(size//2),lbound=2**(size//2-1)+2**(size//2-2))
    q = random_prime(2*p,lbound=p+1)
    N = p*q
    knownbits= 600
    sizep=p.nbits()
    p_msb = (p>>(sizep-knownbits//2))<<(sizep-knownbits//2)
    p_lsb = p%(2**(knownbits//2))
    pp = factor_shared_msb_lsb(sizep, knownbits, p_msb, p_lsb, N)
    assert(pp == p)
    print("Shared msb and lsb ok.")

def test_given_msb():
    size = 1024
    p = random_prime(2**size)
    q = random_prime(2**size)
    unknown_bits = 450
    p0 = (p >> unknown_bits)
    pp = factor_given_msb(p0, p*q, unknown_bits)
    assert(p == pp)
    print("Given p msb ok.")

def test_given_lsb():
    nbits = 1024
    p = random_prime(2^nbits-1, proof=False, lbound=2^(nbits-1))
    q = random_prime(2^nbits-1, proof=False, lbound=2^(nbits-1))
    n = p*q
    lbits = 600
    p0 = p&(2^lbits-1)
    p_2, q_2 = factor_given_lsb(p0, n, lbits, nbits)
    assert(p_2 == p and q_2 == q)
    print("Given p lsb ok.")


# test_shared_msb_lsb()
# test_given_msb()
# test_given_lsb()
