debug = False
strict = False
helpful_only = True
dimension_min = 7

def helpful_vectors(BB, modulus):
    nothelpful = 0
    for ii in range(BB.dimensions()[0]):
        if BB[ii,ii] >= modulus:
            nothelpful += 1

def matrix_overview(BB, bound):
    for ii in range(BB.dimensions()[0]):
        a = ('%02d ' % ii)
        for jj in range(BB.dimensions()[1]):
            a += '0' if BB[ii,jj] == 0 else 'X'
            if BB.dimensions()[0] < 60:
                a += ' '
        if BB[ii, ii] >= bound:
            a += '~'
        print(a)

def remove_unhelpful(BB, monomials, bound, current):
    if current == -1 or BB.dimensions()[0] <= dimension_min:
        return BB
    for ii in range(current, -1, -1):
        if BB[ii, ii] >= bound:
            affected_vectors = 0
            affected_vector_index = 0
            for jj in range(ii + 1, BB.dimensions()[0]):
                if BB[jj, ii] != 0:
                    affected_vectors += 1
                    affected_vector_index = jj

            if affected_vectors == 0:
                BB = BB.delete_columns([ii])
                BB = BB.delete_rows([ii])
                monomials.pop(ii)
                BB = remove_unhelpful(BB, monomials, bound, ii-1)
                return BB
            elif affected_vectors == 1:
                affected_deeper = True
                for kk in range(affected_vector_index + 1, BB.dimensions()[0]):
                    if BB[kk, affected_vector_index] != 0:
                        affected_deeper = False
                if affected_deeper and abs(bound - BB[affected_vector_index, affected_vector_index]) < abs(bound - BB[ii, ii]):
                    BB = BB.delete_columns([affected_vector_index, ii])
                    BB = BB.delete_rows([affected_vector_index, ii])
                    monomials.pop(affected_vector_index)
                    monomials.pop(ii)
                    BB = remove_unhelpful(BB, monomials, bound, ii-1)
                    return BB
    return BB

def boneh_durfee(pol, modulus, mm, tt, XX, YY):
    PR.<u, x, y> = PolynomialRing(ZZ)
    Q = PR.quotient(x*y + 1 - u) # u = xy + 1
    polZ = Q(pol).lift()

    UU = XX*YY + 1

    gg = []
    for kk in range(mm + 1):
        for ii in range(mm - kk + 1):
            xshift = x^ii * modulus^(mm - kk) * polZ(u, x, y)^kk
            gg.append(xshift)
    gg.sort()
    monomials = []
    for polynomial in gg:
        for monomial in polynomial.monomials():
            if monomial not in monomials:
                monomials.append(monomial)
    monomials.sort()
    for jj in range(1, tt + 1):
        for kk in range(floor(mm/tt) * jj, mm + 1):
            yshift = y^jj * polZ(u, x, y)^kk * modulus^(mm - kk)
            yshift = Q(yshift).lift()
            gg.append(yshift) # substitution
    for jj in range(1, tt + 1):
        for kk in range(floor(mm/tt) * jj, mm + 1):
            monomials.append(u^kk * y^jj)
    nn = len(monomials)
    BB = Matrix(ZZ, nn)
    for ii in range(nn):
        BB[ii, 0] = gg[ii](0, 0, 0)
        for jj in range(1, ii + 1):
            if monomials[jj] in gg[ii].monomials():
                BB[ii, jj] = gg[ii].monomial_coefficient(monomials[jj]) * monomials[jj](UU,XX,YY)
    if helpful_only:
        # automatically remove
        BB = remove_unhelpful(BB, monomials, modulus^mm, nn-1)
        # reset dimension
        nn = BB.dimensions()[0]
        if nn == 0:
            print("failure")
            return 0,0
    det = BB.det()
    bound = modulus^(mm*nn)
    if det >= bound:
        if strict:
            return -1, -1
    else:
        print("det(L) < e^(m*n) (good! If a solution exists < N^delta, it will be found)")
    if debug:
        matrix_overview(BB, modulus^mm)
    BB = BB.LLL()
    found_polynomials = False
    
    for pol1_idx in range(nn - 1):
        for pol2_idx in range(pol1_idx + 1, nn):
            PR.<w,z> = PolynomialRing(ZZ)
            pol1 = pol2 = 0
            for jj in range(nn):
                pol1 += monomials[jj](w*z+1,w,z) * BB[pol1_idx, jj] / monomials[jj](UU,XX,YY)
                pol2 += monomials[jj](w*z+1,w,z) * BB[pol2_idx, jj] / monomials[jj](UU,XX,YY)
            PR.<q> = PolynomialRing(ZZ)
            rr = pol1.resultant(pol2)
            if rr.is_zero() or rr.monomials() == [1]:
                continue
            else:
                print("found them, using vectors", pol1_idx, "and", pol2_idx)
                found_polynomials = True
                break
        if found_polynomials:
            break

    if not found_polynomials:
        print("no independant vectors could be found. This should very rarely happen...")
        return 0, 0
    
    rr = rr(q, q)

    soly = rr.roots()

    if len(soly) == 0:
        print("Your prediction (delta) is too small")
        return 0, 0

    soly = soly[0][0]
    ss = pol1(q, soly)
    solx = ss.roots()[0][0]

    return solx, soly

N = 86431753033855985150102208955150746586984567379198773779001331665367046453352820308880271669822455250275431988006538670370772552305524017849991185913742092236107854495476674896994207609393292792117921602704960758666683584350417558805524933062668049116636465650763347823718120563639928978056322149710777096619
e = 43593315545590924566741189956390609253174017258933397294791907025439424425774036889638411588405163282027748339397612059157433970580764560513322386317250465583343254411506953895016705520492303066099891805233630388103484393657354623514864187319578938539051552967682959449373268200012558801313113531016410903723
c = 6017385445033775122298094219645257172271491520435372858165807340335108272067850311951631832540055908237902072239439990174700038153658826905580623598761388867106266417340542206012950531616502674237610428277052393911078615817819668756516229271606749753721145798023983027473008670407713937202613809743778378902

delta = .25
m = 5
t = int((1-2*delta) * m)  # optimization from Herrmann and May
X = 2*floor(N^delta)  # this _might_ be too much
Y = floor(N^(1/2))    # correct if p, q are ~ same size
P.<x,y> = PolynomialRing(ZZ)
A = int((N+1)/2)
pol = 1 + x * (A + y)

solx, soly = boneh_durfee(pol, e, m, t, X, Y)
print(solx, soly)
print("SIMBORA :)")

d = int(pol(solx, soly) / e)%N

if d == 0:
    print(":(")
    exit()
print("d:",d)

m = pow(c, d, N)
mh = hex(m)[2:]
msg = bytes.fromhex(mh)
print(msg)

