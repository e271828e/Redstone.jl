# Fork D: new entries D-386 to D-393 (c31dea1)

Sources read in full at `c31dea1^` (`parent_decisions.md` here): D-027,
D-031, D-059, D-088, D-093, D-096, D-101, D-106, D-107, D-127, D-176, D-218,
D-255, D-260, D-274, D-316. Positions grepped from `parent_positions.txt`
(every Position at the parent, built by awk). Tip lines are `decisions.md`
at 45f5047.

## Counts

- Entries: 8. Rulings (sentences or bullets): 17 (1, 1, 4, 2, 3, 4, 1, 1).
- Tip text equals track2_log_2.md part 1 for all eight, citations unlinked.
- Spec fields: 8 checked, all name a section citing and stating the ruling
  (§12.2 8729, 8748; §12.4 9005; §12.6 9391, 9422, 9425, 9434, 9451, 9457,
  9467, 9474, 9545; §12.7 9667, 9740, 9747, 9766, 9783, 9789). All sorted.
- E1, E2, owner items: no bullet states one.
- Lesson 42: no bullet duplicated by an existing Position.
- Lesson 43: no kept bullet rests on a spec citation as its authority.
- Findings: 1 (judgment). Notes: 5 (no fix needed).

## Findings

**F1 (judgment).** c31dea1, `decisions.md` 15550 (and track2_log_2.md 17).
Text: "The spin's rule is not restated, because [D-027]'s Position states
it." Problem: B42 is UNCONFIRMED, and its status says the item takes the
evidence check's correction: "the Position clause should cover only the
monopolist and the spin's reason". D-386 covers only the monopolist. The
spin's *reason* ("µs precision traded for scheduler noise", D-027 Rejected)
is neither restated nor accounted for. The entry and the log account for the
spin's *rule*, which the correction had already set aside. Leaving the reason
out is defensible, since it is a reason and not a ruling, and §12.2 8721–8723
gives it as rationale after the rule cited to D-027. But the record gives the
wrong ground. Fix: change the log's B42 "Dropped" cell to "the spin's reason:
a reason, not a ruling; D-027's Rejected list keeps it". The entry can stay.

## Notes (checked, no finding)

- D-392 (15674): the Position's positive half, "once per run, against the
  frozen roster", is not in D-106's Rejected words. The Rationale grounds it
  in D-027's Position ("startup warning") and D-106's (the frozen roster).
  B52, confirmed, ruled that it be stated. This is an inference across three
  recorded texts, not a new decision.
- D-391 bullet 1 (15647): "the header inherited" is unscoped. The spec scopes
  it to the default form (9741). Scoping it would mean stating something
  about `restore = false`, which is an owner item (B78), so the restatement
  correctly keeps D-101's words.
- D-387: D-059's Position gives `StepError` "a replay pointer", and D-053's
  says a conformance failure is "reproducible by trace replay". Neither
  states the general ruling "replay, not resurrection".
- D-388 bullet 3: D-316's headline has a request end "the run" unless the
  advance ignores it, and D-255 and D-316 have `step!` take the policy. No
  Position states that a `step!` ends through the ordinary §12.4 tail.
- D-389 bullet 2: its colon clause ("`attach!` only registers") repeats
  D-093's and D-106's Positions. That clause is the reason, and the ruling,
  "deviceless by construction", appears in no Position. B48 "waits on E2",
  and D-389 avoids every GUI clause of D-093.
