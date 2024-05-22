import «LatexInLean»

import Lean
open Lean Elab Widget
show_panel_widgets [latex with r"\sum_{n=0}^1"]

/-! Hello World! \[\sum_{n=0}^\infty a_nx^n\]. $$\int_{n=0}^\infty$$-/

theorem test : 1 = 1 := by
    sorry
