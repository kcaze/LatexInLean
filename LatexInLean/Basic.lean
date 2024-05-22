import Lean
open Lean Widget

structure GetTypeParams where
  /-- Name of a constant to get the type of. -/
  name : Name
  /-- Position of our widget instance in the Lean file. -/
  pos : Lsp.Position
  deriving FromJson, ToJson

open Server RequestM in
@[server_rpc_method]
def getType (params : GetTypeParams) : RequestM (RequestTask (Array String)) :=
  withWaitFindSnapAtPos params.pos fun snap => do
    runTermElabM snap do
      return Array.map (fun x => x.doc) (PersistentArray.toArray (getMainModuleDoc snap.env))

@[widget]
def latex :
Widget.Module where
  javascript := include_str ".." / ".lake" / "build" / "js" / "Latex.js"
