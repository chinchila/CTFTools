# Crypto  
To install requirements:  
```
pip install -r requirements.txt
```
## RSA  
### [Weiner attack](./weiner_RSA.py)  
Given n and e, if d is small we can find it fast with continued fractions  

### [Curveball](./curveball_RSA.gp)  
Find p, q to sign given message and crypted  

## [Hill cipher](./hill.py)
Matrix K is Key, vector P is PlainText, C is the CipherText, so we have  
C = K*P mod 26  
P = inverse(K)*C mod 26  

## [Linear congruential Generator](./lcg.py)  
Given states X of formula  
X[n] = aX[n-1] + c (mod m)  
find m(4 states+), a(3 states+) and c(2 states+)