from gmpy2 import is_square

def rational_to_contfrac(x,y):
	a = x//y
	pquotients = [a]
	while a * y != x:
		x,y = y,x-a*y
		a = x//y
		pquotients.append(a)
	return pquotients

def contfrac_to_rational (frac):
	if len(frac) == 0:
		return (0,1)
	num = frac[-1]
	denom = 1
	for _ in range(-2,-len(frac)-1,-1):
		num, denom = frac[_]*num+denom, num
	return (num,denom)


def convergents_from_contfrac(frac):
	convs = [];
	for i in range(len(frac)):
		convs.append(contfrac_to_rational(frac[0:i]))
	return convs

def hack_RSA(e, n):
	frac = rational_to_contfrac(e, n)
	convergents = convergents_from_contfrac(frac)
	for (k,d) in convergents:
		if k!=0 and (e*d-1)%k == 0:
			phi = (e*d-1)//k
			s = n - phi + 1
			discr = s*s - 4*n
			if(discr>=0):
				t = is_square(discr)
				if t!=-1 and (s+t)%2==0:
					print("Hacked!")
					return d

e = 661151625490057940453934370537153493279700257730605194515477512671009725498263961380991701601528893073700643685154793619384597906222284581312302943633031108386035239611409086843726704760564072317698899642959235021493431970158823528801713454276445931372843291354941086502589073683071650052556718884729263395529
n = 689212079458999714154267403929927166625843767058111866239645477134952492773998962079675520264467661341542686617072168967668108333719563600290809796642750795276270240219311749182445563642967548393348416597235380064127308208210267472603943643345579877580437978785061603888831573763777365858393133612660694843693

print(hack_RSA(e, n))

