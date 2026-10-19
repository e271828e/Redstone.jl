import re,sys
L=open(sys.argv[1]).read().split('\n')
secs=[(11267,11319,'head'),(11320,11375,'14.1'),(11376,11487,'14.2'),(11488,11558,'14.3'),(11559,11717,'14.4'),(11718,11820,'14.5'),(11821,11873,'14.6')]
for a,b,n in secs:
    t=' '.join(L[a-1:b])
    bs=re.findall(r'\*\*(.+?)\*\*',t)
    print(n,len(bs),sum(len(x.split()) for x in bs))
    for x in bs: print('   ',x)
