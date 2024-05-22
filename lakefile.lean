import Lake
open Lake DSL

package «LatexInLean» where
  -- add package configuration options here

lean_lib «LatexInLean» where
  -- add library configuration options here

@[default_target]
lean_exe «latexinlean» where
  root := `Main
