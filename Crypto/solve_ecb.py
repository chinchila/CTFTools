# solve AES ECB input + flag
from pwn import *
import string

FLAG_ENC = "8410ead9260e9f50e0a4be0c2ebc7a8c3d5fa368f6ba7be891801c93e3888e0438dd62761e0fa0a27cc448db0ea8eb1e" # This is used only to calculate blocks and everything
PREFIX = "Encrypted: " # What goes before the hex cipher
BLOCK_SIZE = 16 # Most of time this is 16
HOST = "10.3.159.52"
PORT = 8000

HEX_BLOCK_SIZE = BLOCK_SIZE * 2
BLOCKS = len(FLAG_ENC)//HEX_BLOCK_SIZE

r = remote(HOST, PORT)
plaintext = ""

def encrypt( string_sent ):
    r.recv()
    r.sendline( string_sent )
    g = r.recvline()[len( PREFIX ):].strip()
    g = g[:HEX_BLOCK_SIZE + k * HEX_BLOCK_SIZE]
    return g


for k in range(BLOCKS):
    b = ""
    for i in range( 1, BLOCK_SIZE + 1 ):
        string_sent = "a" * ( BLOCK_SIZE - i )
        g1 = encrypt( string_sent )
        print( "String sent: " + string_sent )
        for j in string.printable:
            g2 = encrypt( string_sent + plaintext + b + j )
            if g1 == g2:
                b += j
                # print(j)
                break
    plaintext += b
    print(plaintext)
