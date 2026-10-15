import re,sys
def rw(s, bt=True):
    s = re.sub(r'\[([^\]]*)\]\[[^\]]*\]', r'\1', s)
    s = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', s)
    if not bt: s = s.replace('`','')
    return len(s)
if __name__=='__main__':
    f=sys.argv[1]; lo,hi=int(sys.argv[2]),int(sys.argv[3])
    L=open(f).read().split('\n')
    for i in range(lo,hi+1):
        print(i, rw(L[i-1]), rw(L[i-1],False), L[i-1])
