import { RpcContext, useAsync, mapRpcError } from "@leanprover/infoview";
import katex from "katex";
import React, { createElement } from "react";

type ModuleDoc = {
  pos: { line: number; column: number };
  doc: string;
};

export default function (props) {
  const rpcContext = React.useContext(RpcContext);
  const asyncState = useAsync(
    () => rpcContext.call("getModuleDocs", { pos: props.pos }),
    [rpcContext, props.pos]
  );
  const docs: ModuleDoc[] =
    asyncState.state === "resolved" && (asyncState.value as any);

  let latexHtml = null;
  if (docs && docs.length > 0) {
    const doc = docs[docs.length - 1].doc;
    latexHtml = doc
      .split("$")
      .map((s, i) => {
        if (i % 2 == 0) {
          return s;
        } else {
          try {
            return katex.renderToString(s, { output: "mathml" });
          } catch (e) {
            return s;
          }
        }
      })
      .join("");
  }

  return <div dangerouslySetInnerHTML={{ __html: latexHtml }}></div>;
}
