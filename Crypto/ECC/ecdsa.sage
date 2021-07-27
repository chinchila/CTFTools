import hashlib
import binascii
from Crypto.Util.number import long_to_bytes, bytes_to_long

#secp256r1
p = 0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF
a = 0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC
b = 0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B

E = EllipticCurve(GF(p), [a,b])
G = E.point((0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296,
            0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5))
n = G.order()

def reused_nonce(s1, s2, z1, z2, r, G):
    n = G.order()
    res = []
    for i in [-1,1]:
        for j in [-1,1]:
            k = (z1 - z2) * inverse_mod(Integer((i * s1 + j * s2) % n), n) % n
            P = (s1 * k - z1) * inverse_mod(r,n) % n
            inverse_r = inverse_mod(r, n)
            res.append(((((s2*k)%n)-z2)*inverse_r)%n)
    return res

def recover_d_biased_k(q, messages, signatures, l, hash_function=None):
    assert(len(messages) == len(signatures))

    Zq = Zmod(q)
    bt, bu, mtr = [], [], []
    for i, (message, signature) in enumerate(zip(messages, signatures)):
        r, s = signature
        r, s = Zq(r), Zq(s)
        t = r / (s * 2 ^ l)
        if hash_function is None:
            u = message / (-s * 2^l)
        else:
            u = int(hash_function(message).hexdigest(), 16) / (-s * 2^l)
        bt.append(int(t))
        bu.append(int(u))
        mtr.append([0] * i + [q] + [0] * (len(signatures) - i - 1 + 2))

    ct = 1 / 2^l
    cu = q / 2^l
    bt.extend([ct, 0])
    bu.extend([0, cu])

    mtr.append(bt)
    mtr.append(bu)

    matrix_ecdsa = matrix(mtr)

    lll = matrix_ecdsa.LLL()
    dct = None
    possible = []

    for i in range(len(signatures) + 2):
        if lll[i][-1] == cu:
            dct = lll[i][-2]
            possible.append((-dct / ct) % q)

    if len(possible) > 0:
        return possible
    else:
        return None

def given_nonce(nonce, r, s, z, m):
    return inverse_mod(Integer(r), Integer(m)) * Mod(Integer(nonce*s - z), Integer(m))

def test_reuse():
    d = getrandbits(256)
    P = d*G

    k = randint(1, n-1)

    z1 = int(hashlib.sha256(b'Hello').hexdigest(), 16)
    x1, y1 = (k*G).xy()
    r1 = Mod(x1, n)
    assert r1 != 0
    s1 = inverse_mod(k, n)*(z1 + r1*d)
    assert s1 != 0

    print('sig1 = (%d, %d)' % (r1, s1))

    z2 = int(hashlib.sha256(b'World!').hexdigest(), 16)
    x2, y2 = (k*G).xy()
    r2 = Mod(x2, n)
    assert r2 != 0
    s2 = inverse_mod(k, n)*(z2 + r2*d)
    assert s2 != 0

    print('sig2 = (%d, %d)' % (r2, s2))

    flag = b"CTF{test nonce reuse on ecdsa}"
    m = bytes_to_long( flag )
    c = m^^d
    print('c = %d' % c)

    print("Starting attack.")
    assert(r1 == r2)
    for dA in reused_nonce(s1, s2, z1, z2, Integer(r1), G):
        msg = long_to_bytes(c^^Integer(dA))
        if msg == flag:
            print(f"Test reuse successfull.\n{msg}")
            return
    print("Test reuse failed.")


def test_biased():
    d = getrandbits(256)
    P = d*G
    BIASED_BITS = 8
    SIGNATURES = 100
    MSG = b"Hello"
    HOHO = int("1101010", 2)

    sigs = []
    for i in range(SIGNATURES):
        z = int(hashlib.sha256(MSG).hexdigest(), 16)
        k = ((randint(1, n-1) >> BIASED_BITS) << BIASED_BITS)+HOHO
        assert((k&HOHO) == HOHO)
        x, y = (k*G).xy()
        r = Mod(x, n)
        assert r != 0
        s = inverse_mod(k, n)*(z + r*d)
        assert s != 0
        sigs.append((r, s))

    d_bytes = long_to_bytes(Integer(d))
    key = int(hashlib.sha256(d_bytes).hexdigest(), 16)
    flag = b"CTF{test ecdsa biased k}"
    m = bytes_to_long(flag)

    c = m^^key
    P = P.xy()
    print('P = ' + str(P))
    print('c = %d' % c)
    print('Signatures created.')

    print("Starting attack.")
    msgs = [MSG for _ in range(SIGNATURES)]
    P = E.point(P)
    ds = recover_d_biased_k(P.order(), msgs, sigs, BIASED_BITS, hashlib.sha256)

    for d in ds:
        d_bytes = long_to_bytes(d)
        key = int(hashlib.sha256(d_bytes).hexdigest(), 16)
        m = c^^key
        msg = long_to_bytes(m)
        if( msg == flag ):
            print(f"Test biased k bits successfull.\n{msg}")
            return
    print(f"Test biased k bits failed.\n{msg}")

def test_given_nonce():
    d = getrandbits(256)
    P = d*G
    k1 = randint(1, n-1)

    z1 = Integer(int(hashlib.sha256(b'Hello').hexdigest(), 16))
    x1, y1 = (k1*G).xy()
    r1 = Mod(x1, n)
    assert r1 != 0
    s1 = inverse_mod(k1, n)*(z1 + r1*d)
    assert s1 != 0

    dA = given_nonce(k1, r1, s1, z1, n)
    assert(dA == d)
    print("Recovered d knowing nonce")

test_reuse()
print("="*50)
test_biased()
print("="*50)
test_given_nonce()
