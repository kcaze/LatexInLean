import Lean
open Lean Widget


structure GetDocStringRequest where
  /-- Position of our widget instance in the Lean file. -/
  pos : Lsp.Position
  deriving FromJson, ToJson

structure JsonModuleDoc where
  doc: String
  pos: Position
  deriving FromJson, ToJson

structure GetDocStringResponse where
  moduleDocs: Array JsonModuleDoc
  docStrings: List ((Option String) × (Option (Position × Position)))
  deriving FromJson, ToJson


-- Idea, try to do something like https://github.com/leanprover/lean4/blob/702c31b8071269f0052fd1e0fb3891a079a655bd/src/Lean/Server/InfoUtils.lean#L351-L392 in order to find the positions of docstrings + also the command currently under the cursor.

open Server RequestM in
@[server_rpc_method]
def getDocStrings (params : GetDocStringRequest) : RequestM (RequestTask GetDocStringResponse) :=
  withWaitFindSnapAtPos params.pos fun snap => do
    runTermElabM snap do
      let infoTrees ← Elab.getInfoTrees
      let env := snap.env
      let constants := env.constants.map₂.foldl (fun acc key _ => List.cons key acc) []
      let docstrings ← constants.mapM (fun name => findDocString? env name)
      let declarationRanges ← constants.mapM (fun name => findDeclarationRanges? name)
      let declarationRanges : List (Option (Position × Position)) := declarationRanges.map
        (fun range? => match range? with
          | some range => some ⟨range.selectionRange.pos, range.selectionRange.endPos⟩
          | none => none
        )
      let moduleDocs := Array.map
        (fun x => JsonModuleDoc.mk x.doc x.declarationRange.pos)
        (PersistentArray.toArray (getMainModuleDoc snap.env))
      return {moduleDocs := moduleDocs, docStrings := List.zip docstrings declarationRanges }

@[widget]
def latex :
Widget.Module where
  javascript := include_str "Latex.js"

elab t:docComment : command => do
  logInfo s!"Hello"
  -- let fileMap ← Lean.MonadFileMap.getFileMap
  -- let tElab ← Lean.Elab.Term.elabTerm t none
  -- match Lean.Syntax.getRange? t with
  -- | some range => do {
  --   let pos := Lean.FileMap.toPosition fileMap range.start
  --   let endPos := Lean.FileMap.toPosition fileMap range.stop
  --   let declarationRange := {
  --     pos := pos
  --     charUtf16 := 0
  --     endPos := endPos
  --     endCharUtf16 := 0
  --     :Lean.DeclarationRange
  --   }
  --   match tElab with
  --   | Lean.Expr.lit val => do
  --     match val with
  --     | Lean.Literal.strVal string => do
  --       modifyEnv (
  --         fun env => Lean.addMainModuleDoc env {
  --           doc := string
  --           declarationRange := declarationRange
  --         }
  --       )
  --       return tElab
  --     | _ => return tElab
  --   | _ => return tElab
  -- }
  -- | _ => return tElab


elab "/--" t:term "-/": tactic => do
  logInfo s!"Hello"
  let fileMap ← Lean.MonadFileMap.getFileMap
  match Lean.Syntax.getRange? t with
  | some range => do {
    let pos := Lean.FileMap.toPosition fileMap range.start
    let endPos := Lean.FileMap.toPosition fileMap range.stop
    let declarationRange := {
      pos := pos
      charUtf16 := 0
      endPos := endPos
      endCharUtf16 := 0
      :Lean.DeclarationRange
    }
    let t ← Lean.Elab.Term.elabTerm t none
    match t with
    | Lean.Expr.lit val => do
      match val with
      | Lean.Literal.strVal string => do
        modifyEnv (
          fun env => Lean.addMainModuleDoc env {
            doc := string
            declarationRange := declarationRange
          }
        )
      | _ => pure ()
    | _ => pure ()
  }
  | _ => pure ()
