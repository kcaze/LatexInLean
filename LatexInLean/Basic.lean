import Lean
open Lean Widget

structure GetModuleDocsRequest where
  /-- Position of our widget instance in the Lean file. -/
  pos : Lsp.Position
  deriving FromJson, ToJson


structure JsonModuleDoc where
  doc: String
  pos: Position
  deriving FromJson, ToJson

open Server RequestM in
@[server_rpc_method]
def getModuleDocs (params : GetModuleDocsRequest) : RequestM (RequestTask (Array JsonModuleDoc)) :=
  withWaitFindSnapAtPos params.pos fun snap => do
    runTermElabM snap do
      return Array.map (fun x => JsonModuleDoc.mk x.doc x.declarationRange.pos) (PersistentArray.toArray (getMainModuleDoc snap.env))

@[widget]
def latex :
Widget.Module where
  javascript := include_str "Latex.js"

elab "latex" t:term : tactic => do
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
