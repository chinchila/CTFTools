from gmpy2 import gcd, invert

class LCG:
	"""
	m is mod
	a is multiplicative
	c is increment
	"""
	def __init__(self, m, a, c, seed):
		self.m = m
		self.a = a
		self.c = c
		self.X = seed

	def next(self):
		self.X = (self.a * self.X + self.c) % self.m
		return self.X

def find_c(X, m, a):
	c = (X[1] - X[0]*a) % m
	return m, a, c

def find_a(X, m):
	a = (X[2]-X[1])*invert(X[1] - X[0], m)%m
	return find_c(X, m, a)

def find_m(X):
	t = []
	cong = []
	for i in range(len(X)-1):
		t.append(X[i+1] - X[i])
	for i in range(len(t)-2):
		cong.append(t[i+2]*t[i] - t[i+1]*t[i+1])
	m = cong[0]
	for i in range(len(cong)-1):
		m = gcd(m, cong[i+1])
	return find_a(X, m)

