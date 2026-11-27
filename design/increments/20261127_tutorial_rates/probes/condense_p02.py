import re, sys
for line in open(sys.argv[1]):
    if line.startswith('==') or line.strip().startswith('D:'):
        print(line.rstrip()); continue
    m = re.match(r'\s+\[(.*?)\] (\S+) (.*)', line)
    if not m: continue
    lab, kind, rest = m.groups()
    d = dict(re.findall(r'(\w+)=(\S+)', rest))
    if kind=='ch5': print(f"  [{lab}] late_h {d['late_h']} late_V {d['late_V']} peak {d['peak']} Vexc {d['V_exc']}@{d['t_V_exc']} 1m {d['within_1m']}")
    elif kind=='limited': print(f"  [{lab}] {rest.strip()}")
    elif kind=='ch6': print(f"  [{lab}] gaps δe {d['gap_δe']} δt {d['gap_δt']} hθm {d['gap_hθm']} θqm {d['gap_θqm']} latch {d['t_latch']} jumps {d['jump_δe']} {d['jump_δt']} act {d['jump_act']} jitter {d['jitter']} recap {d['recapture']}")
    elif kind=='ch7': print(f"  [{lab}] {d.get('writes')} stop {d['t_stop']} track {d['tracking']} V {d['V_lo']}..{d['V_hi']} γ {d['γ_stop']} lim {d['limited']}")
