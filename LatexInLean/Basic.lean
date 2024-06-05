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
