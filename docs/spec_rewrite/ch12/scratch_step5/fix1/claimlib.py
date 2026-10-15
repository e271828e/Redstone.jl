"""Exact-text replacements in units/<U>/claims.md, logged for replay."""
LOG = []


def rep(fid, u, old, new):
    p = f'units/{u}/claims.md'
    t = open(p).read()
    assert t.count(old) == 1, (fid, t.count(old), old[:70])
    open(p, 'w').write(t.replace(old, new))
    LOG.append((fid, u, old, new))


def flush(path='scratch_step5/fix1/log_claims.md', mode='a'):
    with open(path, mode) as f:
        for fid, u, o, n in LOG:
            f.write(f"### {fid}, unit {u}, `units/{u}/claims.md`\n\nOld:\n\n````text\n{o}\n````\n\nNew:\n\n````text\n{n}\n````\n\n")
    print(len(LOG), 'claims edits')
