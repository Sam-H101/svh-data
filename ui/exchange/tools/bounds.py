import re,sys
x=open(sys.argv[1],encoding='utf-8').read()
defs={}
for m in re.finditer(r'<item type="(Define\w+)"[^>]*?(?:shapeId|spriteId|characterID|characterId|buttonId)="(\d+)"',x):
    defs.setdefault(m.group(2),(m.group(1),m.start()))
def bounds(cid,depth=0,mx=0,my=0):
    t,pos=defs[cid]
    if t.startswith('DefineShape') or t=='DefineEditTextTag':
        r=re.search(r'(?:shapeBounds|bounds) type="RECT" Xmax="(-?\d+)" Xmin="(-?\d+)" Ymax="(-?\d+)" Ymin="(-?\d+)"',x[pos:pos+3000])
        if not r: return None
        X1,X0,Y1,Y0=map(int,r.groups()); return (X0+mx,Y0+my,X1+mx,Y1+my)
    if t=='DefineSpriteTag':
        end=x.find('</subTags>',pos); seg=x[pos:end]; bb=None
        for p in re.finditer(r'<item type="PlaceObject[23]?Tag"[^>]*?characterId="(\d+)"[^>]*>\s*<matrix[^>]*translateX="(-?\d+)" translateY="(-?\d+)"',seg):
            if depth>4: continue
            b=bounds(p.group(1),depth+1,mx+int(p.group(2)),my+int(p.group(3)))
            if b: bb=b if not bb else (min(bb[0],b[0]),min(bb[1],b[1]),max(bb[2],b[2]),max(bb[3],b[3]))
        return bb
    return None
for c in sys.argv[2:]:
    b=bounds(c); print(c, defs[c][0], b and tuple(v/20 for v in b))
