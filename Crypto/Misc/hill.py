import numpy as np
from itertools import product

alp="abcdefghijklmnopqrstuvwxyz"

def modMatInv(A,p):
	n=len(A)
	A=np.matrix(A)
	adj=np.zeros(shape=(n,n))
	for i in range(0,n):
		for j in range(0,n):
			adj[i][j]=((-1)**(i+j)*int(round(np.linalg.det(minor(A,j,i)))))%p
	return (modInv(int(round(np.linalg.det(A))),p)*adj)%p

def modInv(a,p):
	for i in range(1,p):
		if (i*a)%p==1: return i
	raise ValueError(str(a)+" has no inverse mod "+str(p))

def minor(A,i,j):
	A=np.array(A)
	minor=np.zeros(shape=(len(A)-1,len(A)-1))
	p=0
	for s in range(0,len(minor)):
		if p==i: p=p+1
		q=0
		for t in range(0,len(minor)):
			if q==j: q=q+1
			minor[s][t]=A[p][q]
			q=q+1
		p=p+1
	return minor

def encrypt(msg, key, sz):
	triple = [list(msg[i*sz:(i*sz)+sz]) for i in range(0, len (msg)//sz)]
	mul = [i[:] for i in triple]
	for x in range(len(triple)):
		for i in range(len(triple[x])):
			triple[x][i]=ord(triple[x][i])-ord(alp[0])
	for x in range(len(triple)):
		mul[x] = np.dot(key,triple[x])%len(alp)
	enc=""
	for x in range(len(mul)):
		for s in range(0,sz):
			enc+=chr(mul[x][s]+ord(alp[0]))
	return enc

def decrypt(msg, key, sz):
	try: deckey = modMatInv(key,len(alp))
	except ValueError: return
	triple = [list(msg[i*sz:(i*sz)+sz]) for i in range(0, len (msg)//sz)]
	mul = [i[:] for i in triple]
	for x in range(len(triple)):
		for i in range(len(triple[x])):
			triple[x][i]=ord(triple[x][i])-ord(alp[0])
	for x in range(len(triple)):
		mul[x] = np.dot(deckey,triple[x])%len(alp)
	dec=""
	con=0
	for x in range(len(mul)):
		for s in range(0,sz):
			if msg[con] not in alp:
				dec += msg[con]
			else:
				dec += chr(int(mul[x][s])+ord(alp[0]))
			con += 1
	return dec

encr="wznqca{d4uqop0fk_q1nwofDbzg_eu} "
correctkey = [[1,11], [22,13]]
correctkey= np.transpose(correctkey)
sz=len(correctkey)
fin = decrypt(encr,correctkey,sz)
print(fin)
