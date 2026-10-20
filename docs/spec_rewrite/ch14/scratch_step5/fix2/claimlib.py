"""Set fields of claim blocks in units/<U>/claims.md by claim id."""
ROOT = "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14"


class Claims:
    def __init__(self, u):
        self.u = u
        self.path = f"{ROOT}/units/{u}/claims.md"
        self.L = open(self.path).read().split("\n")

    def blocks(self):
        """Return {cid: [line indices]} for claim blocks, as build_inventory counts them."""
        out, cur, n = {}, [], 0
        def flush():
            nonlocal n
            body = [i for i in cur if not self.L[i].startswith("#")]
            if body and not self.L[body[0]].startswith("added:"):
                n += 1; out[n] = body
        for i, l in enumerate(self.L + [""]):
            if l.startswith("#"): continue
            if not l.strip():
                flush(); cur = []; continue
            cur.append(i)
        return out

    def set(self, cid, new=None, tag=None, note=None, newcites=None, ruling=None):
        idx = self.blocks()[cid]
        fields = {self.L[i].split(":", 1)[0]: i for i in idx}
        last = idx[-1]
        ins = []
        for key, val in (("new", new), ("tag", tag), ("ruling", ruling), ("newcites", newcites)):
            if val is None: continue
            if key in fields: self.L[fields[key]] = f"{key}: {val}"
            else: ins.append(f"{key}: {val}")
        if note is not None:
            if "note" in fields: self.L[fields["note"]] += "; " + note
            else: ins.append(f"note: {note}")
        # insert new: right after old:, the rest at the block's end
        for x in reversed(ins):
            if x.startswith("new:"): self.L.insert(fields["old"] + 1, x); last += 1
            else: self.L.insert(last + 1, x)

    def replace(self, old, new):
        hits = [i for i, l in enumerate(self.L) if l == old]
        assert len(hits) == 1, (old, len(hits))
        self.L[hits[0]] = new

    def save(self):
        open(self.path, "w").write("\n".join(self.L))
