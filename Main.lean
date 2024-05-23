import «LatexInLean»

import Lean
open Lean Elab Widget
show_panel_widgets [latex]

/-! Proves that $1+1 = 2$ is true.-/
theorem test : 1+1 = 2 := by
    simp
