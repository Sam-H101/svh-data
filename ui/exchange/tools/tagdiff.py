import sys, zlib, struct, hashlib
def tags(path):
    d = open(path,'rb').read()
    sig, ver, ln = d[:3], d[3], struct.unpack_from('<I', d, 4)[0]
    body = zlib.decompress(d[8:]) if sig[0:1] in (b'C',) else d[8:]
    nbits = body[0] >> 3
    rect = (5 + 4*nbits + 7)//8
    p = rect + 4
    out = []
    while p < len(body):
        h, = struct.unpack_from('<H', body, p); code, l = h >> 6, h & 0x3f; q = p + 2
        if l == 0x3f: l, = struct.unpack_from('<I', body, q); q += 4
        out.append((code, body[p:q+l]))
        p = q + l
        if code == 0: break
    return sig, ver, ln, len(body), body[:rect+4], out
a = tags(sys.argv[1]); b = tags(sys.argv[2])
print('hdr', a[:4], b[:4], 'rect+rate same', a[4]==b[4])
ta, tb = a[5], b[5]
print('tags', len(ta), len(tb))
diff = [(i, ta[i][0], len(ta[i][1]), len(tb[i][1])) for i in range(min(len(ta),len(tb))) if ta[i][1] != tb[i][1]]
print('differing tags', len(diff), diff[:10])
import collections
print('codes of differing', collections.Counter(c for _,c,_,_ in diff))
