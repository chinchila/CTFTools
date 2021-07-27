def english_test(bytes_):
    freqs = {
        'a': 0.0651738,
        'b': 0.0124248,
        'c': 0.0217339,
        'd': 0.0349835,
        'e': 0.1041442,
        'f': 0.0197881,
        'g': 0.0158610,
        'h': 0.0492888,
        'i': 0.0558094,
        'j': 0.0009033,
        'k': 0.0050529,
        'l': 0.0331490,
        'm': 0.0202124,
        'n': 0.0564513,
        'o': 0.0596302,
        'p': 0.0137645,
        'q': 0.0008606,
        'r': 0.0497563,
        's': 0.0515760,
        't': 0.0729357,
        'u': 0.0225134,
        'v': 0.0082903,
        'w': 0.0171272,
        'x': 0.0013692,
        'y': 0.0145984,
        'z': 0.0007836,
        ' ': 0.1918182
    }

    try:
        msg = bytes_.decode('ascii').lower()
    except:
        return 0

    filtered = list(filter(lambda c: c in freqs.keys(), msg))
    if not filtered:
        return 0

    error = 0
    for c, ratio in freqs.items():
        actual = filtered.count(c) / len(filtered)
        error += abs(ratio - actual)

    return 1 / error

def hamming(a, b):
    assert(len(a) == len(b))

    dist = 0
    for x, y in zip(a, b):
        z = x ^ y
        while z:
            dist += z & 1
            z >>= 1

    return dist

def xor_bytes(a, b):
    return bytes([x ^ y for x, y in zip(a, b)])


def xor_single_char_key(msg, key):
    return xor_bytes(msg, bytes([key] * len(msg)))


def xor_repeating_key(msg, key):
    repeats, leftover = divmod(len(msg), len(key))
    return xor_bytes(msg, bytes(key * repeats + key[:leftover]))


def break_xor_char_key(ciphertext, quality_test=english_test):
    return rank_xor_char_keys(ciphertext, quality_test)[0]


def rank_xor_char_keys(ciphertext, quality_test=english_test):
    possible_keys = range(256)
    decryptions = [(key, xor_single_char_key(ciphertext, key))
                   for key in possible_keys]
    best_decryptions = sorted(decryptions,
                              key=lambda key_decryption:
                              (quality_test(key_decryption[1]),
                               key_decryption[1]),
                              reverse=True)
    keys = [key for key, _ in best_decryptions]
    return keys


def break_xor_repeating_key(ciphertext, key_length,
                            quality_test=english_test):
    keys = rank_xor_repeating_keys(ciphertext, key_length, quality_test)
    key = [key_ranks[0] for key_ranks in keys]
    return bytes(key)


def rank_xor_repeating_keys(ciphertext, key_length, quality_test=english_test):
    blocks = [ciphertext[i * key_length:(i+1) * key_length]
              for i in range(len(ciphertext) // key_length)]
    nth_bytes = zip(*blocks)
    keys = [rank_xor_char_keys(bytes_, quality_test)
            for bytes_ in nth_bytes]
    return keys


def guess_key_lengths(cipher, min_length=2, max_length=40,
                      distance_fn=hamming):
    def score(cipher, size):
        distances = [distance_fn(cipher[i * size:(i+1) * size],
                                 cipher[(i+1) * size:(i+2) * size])
                     for i in range(len(cipher) // size - 2)]
        return sum(distances) / len(distances) / size

    return sorted(range(min_length, max_length+1),
                  key=lambda size: score(cipher, size))
