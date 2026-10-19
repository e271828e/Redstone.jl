import re, sys, subprocess
def rendered(s):
    s = re.sub(r'\[([^\]]*)\]\[[^\]]*\]', r'\1', s)
    s = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', s)
    s = s.replace('**', '').replace('`', '')
    s = re.sub(r'(?<!\w)\*(?!\s)|(?<!\s)\*(?!\w)', '', s)
    return len(s)
for rev in sys.argv[1:]:
    d = subprocess.run(['git','show','-U0',rev,'--','docs/design/spec.md','docs/design/companions/frame_walkthrough.md'],capture_output=True,text=True).stdout
    f=None; ln=0
    for line in d.splitlines():
        if line.startswith('+++ '): f=line[6:]
        elif line.startswith('@@'):
            ln=int(re.search(r'\+(\d+)',line).group(1))
        elif line.startswith('+') and not line.startswith('+++'):
            t=line[1:]
            if not t.startswith('[d-') and not t.startswith('|') and rendered(t)>80:
                print(rev,f,ln,rendered(t),t[:90])
            ln+=1
