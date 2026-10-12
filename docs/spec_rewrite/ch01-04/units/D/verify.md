# Unit D verify (§3.4)

**Counts.** 55 inventory claims: 53 MATCH, 2 DRIFT, 0 LOST. 68 phase-1 assertions. ADDED: 6 declared sentences plus 5 inline glosses. One of them claims a little too much. `check_unit.py` reports 0 failures.

## DRIFT

- **C-053.** Old: "If interval-relative dynamics ever neither factor algebraically nor tolerate the latch-back wire, the guarded addition is …". New: "It is for interval-relative dynamics that ever neither factor algebraically nor tolerate the latch-back wire." The old conditional ("if ever") becomes a garbled relative clause. Fix: "It would serve interval-relative dynamics that neither factor algebraically nor tolerate the latch-back wire, should any appear."
- **C-029.** Old: "integrates raw increments continuously: `ẋ.ϑ_c = …`". New: "… continuously. They are `ẋ.ϑ_c = ω_ic_c`, …". "They" binds to the increments, but what follows is a list of equations. Fix: "… continuously, as `ẋ.ϑ_c = ω_ic_c`, …".

## ADDED

- "[§8.6] spells this IMU in full, with its notation." §8.6 old 3377 supports "in full". §8.6 uses the notation in code and math but never defines the subscript convention. Fix: drop "with its notation".
- Every other gloss matches its glossary entry: guard, sweep, tick, boundary, tier, cell, assembly, activation, guarded addition, one home per datum, and class. "In that wire, the integrals consume the sampler's published latch" quotes §8.6 old 3423–3425. "one-sample `z⁻¹` delay" quotes §8.6 old 3585.

## Antecedents

- **New 29–33.** The tier/cell gloss sentence now sits between the last premise and "The all-in-one component is therefore …". Fix: fold both glosses into the cross-tier sentence as parentheticals.
- **New 43–45.** "Its direct formulation" now follows a sentence whose subject is §8.6. It still reads as the IMU's, but dropping "with its notation" also helps here.
- The other antecedents hold: "That deferred decode", "It is also", "One of those costs", "Such a handler", "In that wire".

## Rewordings asked about

- **"sampling interface"** keeps the claim. Both instances name the ZOH + `z⁻¹` junction that D-056 says the merge "hides" (log 1705). Note that the glossary uses "interface" for *contract*. That word is not reserved, so this is acceptable.
- **"a merged component"** keeps the claim. The old "the merged class" pointed back to "a merged component", and the generic article changes nothing.
- **"pushed the IMU … the framework's own linearization semantics"** keeps the claim. "the model" was the IMU, and "its own" was the framework's.

## Citations

- **D-141** (Position, log 4726, "A continuous component's state reset is an event") carries the claim that handlers are the sole resetters. Its Rejected entry on immutable views backs "sole".
- **D-263 bullet 5** (log 10442, "exactly one of `init_x` and `init_s`") carries the store half of the exclusivity. D-056 carries the rest, and no log words are imported. The co-citation holds.
- **D-020 Rejected** (log 776–777, "structurally unnecessary — `z⁺` is invisible until the next tick decode") carries the deferred-decode claim. The annotation pointing to D-154 and D-181 leaves this item standing.
- **D-056 citations at C-011, C-017, C-018, C-034, C-035, C-041 and C-054** are each carried by the field that rulings.md names.

## Bold

There are two bolds, both cited to D-056 in the same sentence.

- The Position sentence is one ruling: a colon and comma list. The cross-tier clause is restated plain, which is correct.
- Bullet 4 is a separate ruling. "The one recorded …" is supported by the log's "the recorded, unbuilt escape hatch".
- Neither is bold in the base spec. §8.6 bolds bullets 1, 2 (with its provisos), 3 and 5.
- "zeroes them" moved to italics. The **Why.** and **Verdict.** labels and the **Algebra removes the reset.** bold are gone (R1).

## Moves

R1 (i), R5 (seam unlinked twice; "wrong mechanism") and R6 are done. The only other change moves the *continuous component* link to its new first use, which the brief allows. No other moves.

## Reader-cold names

- **Class 2, aerospace examples:**
  - "IMU" is never spelled out. Add "inertial measurement unit".
  - "coning" and "sculling" are pointed at §8.6, as the brief directs.
  - The "error model" and the "truth/corrupted sample pair" are not introduced.
- **`Dual`** is used without "ForwardDiff's dual number". It is not ordinary Base Julia; spec 1268 defines it.
- **Class 1:** none.

## Other

- *class*: line 7 glosses it as primitive-vs-assembly, and lines 12–16 then use "classes" in the leaf sense. The trap allows this, but the gloss makes the clash visible. This is the rewriter's open question 4.
- *boundary*: line 27's glossary sense and line 38's "bug-prone boundary" (the structural sense) carry over from the old text.

## Re-check

**Verdict.** Five of the six fixes hold. The escape-hatch fix now says one claim twice. `check_unit.py` prints `checks failed: 0`. I compared the text paragraph by paragraph with the first verified version. Nothing changed beyond the listed fixes.

### Fixes that hold

- **C-029.** "integrates raw increments continuously, as `ẋ.ϑ_c = …`" matches the old colon.
- **The §8.6 pointer.** "[§8.6] spells this IMU in full." matches §8.6 old 3377 and no longer claims the notation. "The IMU's direct formulation" removes the antecedent hazard. Moving the pointer to the end of its paragraph is harmless.
- **"Influence across tiers … inside a merged component".** It keeps the scope of "Cross-tier influence", which means influence from one tier on the other. The tier gloss matches the glossary. The cell gloss also matches, apart from "typed" for "concretely typed". "therefore" now follows the premise directly.
  - Optional: merge "(typed entries of the signal table) ([D-056])" into one parenthetical.
- **IMU.** "inertial measurement unit (IMU)" is spelled out correctly.
- **`Dual`.** "`Dual` is ForwardDiff's dual number" matches spec 1268.
- **The truth/corrupted pair, ([§8.6]).** §8.6 old 3382–3402 shows the following:
  - `errors::IMUErrorModel`, commented "discrete — scale/bias/noise on the sample", as a discrete child beside the sampler.
  - Two output ports: `sample` (ideal increments) and `sample_meas` (measured increments).

  That covers the discrete sibling and the separate pair. "Loggable" is the old text's own word. It follows from every cell being public. The pointer claims nothing extra.
- **"the two leaf classes" (new 15, 63).** Both uses take the glossary's recorded form for the continuous-vs-discrete sense. Both match the old meaning.

### Fix that fails: the escape hatch (C-052/C-053)

The tick-triggered handler on continuous components now appears twice, in the bold sentence and again in the restored conditional ("… the guarded addition is a tick-triggered handler on continuous components (periodic events)").

The bold is the headline, and D-056 bullet 4 rules it, so the conditional's main clause should go. Keep the condition, "periodic event" and "guarded addition" once each. Replace the gloss sentence and the conditional with this text:

> Such a handler is a periodic event. It is a [guarded addition](#g-guarded-addition) (a capability the design admits but does not build), for use if interval-relative dynamics ever neither factor algebraically nor tolerate the latch-back wire. In that wire, the integrals consume the sampler's published latch ([§8.6][s8-6]).

Every old claim then appears once:

- one hatch, recorded and unbuilt (bold);
- it is a tick-triggered handler on continuous components (bold);
- a periodic event;
- a guarded addition;
- the "ever neither … nor" condition;
- no known case needs it.
