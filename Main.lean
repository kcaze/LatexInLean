import «LatexInLean»
show_panel_widgets [latex]

def h := 1
/-! Proves that $1+1 = 2$ is true.-/
theorem test : 1+1 = 2 := by
    latex "$1+1 = 2$ test"
    /-? Prove 1+1 >= 2. -/
    sorry

/-! Test mathbb fonts: $\mathbb{R}, \mathfrak{S}$-/
