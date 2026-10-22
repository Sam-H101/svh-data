import re,sys
x=open(sys.argv[1],encoding='utf-8').read()
i=x.index('type="SymbolClassTag"')
blk=x[i:x.index('</item>\n    <item type="ShowFrameTag"',i)] if False else x[i:i+3000000]
tags=re.search(r'<tags>(.*?)</tags>',blk,re.S).group(1)
names=re.search(r'<names>(.*?)</names>',blk,re.S).group(1)
t=re.findall(r'<item>(\d+)</item>',tags); n=re.findall(r'<item>([^<]*)</item>',names)
m=dict(zip(t,n))
for k in sys.argv[2:]: print(k, m.get(k))
import collections
inv={v:k for k,v in m.items()}
for nm in ['SrvButtonShared','SrvButtonRedShared','SrvMessageExchangeSkinnedPop']: print(nm, inv.get(nm))
