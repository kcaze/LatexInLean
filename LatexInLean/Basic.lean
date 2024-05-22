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
      let name ← resolveGlobalConstNoOverloadCore params.name
      let c ← try getConstInfo name
        catch _ => throwThe RequestError ⟨.invalidParams, s!"no constant named '{name}'"⟩
      return Array.map (fun x => x.doc) (PersistentArray.toArray (getMainModuleDoc snap.env))

@[widget]
def latex :
Widget.Module where
  javascript := "
        import * as React from 'react';
        import renderMathInElement from 'https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/contrib/auto-render.mjs';
        import css from 'https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.css';
        import { RpcContext, InteractiveCode, useAsync, mapRpcError } from '@leanprover/infoview';

        const e = React.createElement;
        document.adoptedStyleSheets = [css];

        export default function(props) {
          const rs = React.useContext(RpcContext)
          const [name, setName] = React.useState('getType');
          const [ref, setRef] = React.useState(null);
          const st = useAsync(() =>
            rs.call('getType', { name, pos: props.pos }), [name, rs, props.pos])
          const type = st.state === 'resolved' ? st.value && e('span', {ref: setRef}, st.value)
          : st.state === 'rejected' ? e('p', null, mapRpcError(st.error).message)
          : e('p', null, 'Loading..');

          var s = '$$';
          var i = 0;
          while (i in props) {
            s += props[i];
            i++;
          }
          s += '$$';
          React.useEffect(() => {
            if (!ref) return;
            renderMathInElement(ref);
          }, [ref])
          if (ref) {
            renderMathInElement(ref);
          }
          return type;
          //return React.createElement('span', {ref: setRef}, s);
        }"
