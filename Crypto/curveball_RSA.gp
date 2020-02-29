\\ From BSidesSF CTF 2020
c = \\cripted
m = \\msg

candidatep(b,l) = {my(p); p = 2; while(log(p)/log(2) < b, p = p * nextprime(random(l))); p + 1;}
divisiblep(b,l) = {my(p); p = 1; while(isprime(p) != 1, p = candidatep(b,l)); p}
q = 2;g = 2;while(g != 1, p = divisiblep(2060, 1000000); addprimes(p); d = znlog(m, Mod(c, p * q)); g = gcd(d, p - 1);)
e = lift(Mod(1/d, (p - 1) * (q - 1)))

print("p:")
print(p)

print("e:")
print(e)

print("q:")
print(q)
