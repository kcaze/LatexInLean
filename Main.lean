import «LatexInLean»
show_panel_widgets [latex]

def h := 1
/-! Proves that $1+1 = 2$ is true.-/
theorem test : 1+1 = 2 := by
    latex "Step 1: Testing fonts $\\mathbb{R}$."
    latex "Step 2: Prove 1 + 0 = 0"
    let x := 1
    latex "Step 3: Prove 1 + 1 = 2"
    sorry

/-! Test mathbb fonts: $\mathbb{R}, \mathfrak{S}$-/
