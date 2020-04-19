# attack from https://eprint.iacr.org/2020/053.pdf
# breaks Chen et al.’s Encryption Scheme in O(2^30)

q,n,a,s = (3,59,10,25)
m = n+1-a+s
FF = GF(q)
R = PolynomialRing(FF, ["x{}".format(i) for i in range(n)])
xs = R.gens()

globals().update({str(xx): xx for xx in xs})

with open("output") as of:
  lines = of.readlines()

P = eval(lines[0].replace("^", "**"))
d = eval(lines[1])

for i in range(len(d)):
	d[i] = tuple(map(FF, d[i]))

# step 1

## get quadratic part of poly
def Quad(p):
	return [p.monomial_coefficient(x**2) for x in xs]

quadz = [Quad(p) for p in P]

## solve sum(ai*quad(pi)) = 0
mat = matrix(FF, m, n, lambda i, j: quadz[i][j]);

# step 2

## get basis on ai of size n-a
krnl = mat.kernel();

# step 3
def decrypt_block(d):
	rs = [
		sum((ca[i] * P[i] for i in range(m))) - sum((ca[i] * d[i] for i in range(m)))
		for ca in krnl.basis()
	]
	RI = R.ideal([p - v for p, v in zip(P, d)] + rs)
	# solve quadratic 
	solution = RI.groebner_basis()
	ans = []
	for term, x in zip(solution, xs):
		term = list(term)
		assert term[0][0] == 1 and term[0][1] == x
		if len(term) > 1:
			assert term[1][1] == 1
			ans.append(-term[1][0])
		else:
			ans.append(FF(0))
	return ans

def combine_blocks(blocks):
	x = 0
	for i in blocks[::-1]:
		for j in i[::-1]:
			x = x*q+Integer(j)
	ss = ""
	while x > 0:
		ss = chr(x % 256) + ss
		x = x//256
	return ss

def decrypt(cipher):
	dec = []
	for i in range(len(cipher)):
		dec.append(decrypt_block(cipher[i]))
	return combine_blocks(dec)

msg = decrypt(d)
print(msg)

