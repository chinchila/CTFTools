# From BSidesSF CTF 2020
# given encrypted text (c) and message(m) generate a key
# the gp/pari version should be faster
############################################################################################################################
# GP/Pari script:
############################################################################################################################
# c =  \\cripted
# m =  \\msg
# candidatep(b,l) = {my(p); p = 2; while(log(p)/log(2) < b, p = p * nextprime(random(l))); p + 1;}
# divisiblep(b,l) = {my(p); p = 1; while(isprime(p) != 1, p = candidatep(b,l)); p}
# q = 2;g = 2;while(g != 1, p = divisiblep(2060, 1000000); addprimes(p); d = znlog(m, Mod(c, p * q)); g = gcd(d, p - 1);)
# e = lift(Mod(1/d, (p - 1) * (q - 1)))
# print(p)
# print(e)
# print(q)
############################################################################################################################
from numpy.random import randint

c = 30029082298423626458918317331797730712824458279653960314522818831988750307318019279067726121277119878053175539620927367012778946811416906341414123860864244749552521552311233414710306128250462784249834553759849615395773977911763564663657767431530992587212144895290159185785995293643942721086593148607174895850948443533014356220154193758581121774858597565799411158140225719721204831369243444675595874337654786964512086698884078659044535454015012519885849752458458138292456648904712847039358841233152424391826191616205077655575599508690865770150633936794333505044169469961152517435570928708737545883090196719522419964479
m = 52218557622655182058721298410128724497736237107858961398752582948746717509543923532995392133766377362569697102943053

idx = 0
primes = []

# part 1 of smooth generation
def candidatep(b, l):
    global primes, idx
    p = 2
    while(p.nbits() < b):
        if idx >= len(primes):
            shuffle(primes)
            idx = 0
        p = p * primes[idx]
        idx += 1
    return p+1

# generate p-1 smooth prime
def divisiblep(b, l):
    p = 1
    while(p not in Primes()):
        p = candidatep(b, l)
    return p

# sieve
ll = 3
l = 100000 # upper bound on B-smooth
while ll <= l:
    primes.append(ll)
    ll = ll.next_prime()

def genKey(m, c):
    q = g = 2
    while(g != 1):
        p = divisiblep(c.nbits()+20, l)
        print("Found prime!")
        d = p-1
        try:
            d = discrete_log(m, Mod(c, p * q))
        except:
            print("Discrete log probably does not exists.")
        g = gcd(d, p - 1)
    e = lift(Mod(1/d, (p - 1) * (q - 1)))
    assert(pow(m, e, p*q) == c)
    return p, q, e, d

p, q, e, d = genKey(m, c)
print("p:", p)
print("q:", q)
print("e:", e)
print("d:", d)

