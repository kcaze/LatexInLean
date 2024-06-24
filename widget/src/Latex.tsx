import { RpcContext, useAsync, mapRpcError } from "@leanprover/infoview";
import katex from "katex";
import React, { createElement } from "react";
import "./css/katex.min.css";

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
  // Cursor position is 0-indexed but module docs are 1-indexed.
  // So add 1 to the line and column.
  const cursorPos = {line: props.pos.line + 1, column: props.pos.character + 1};
  const allDocs: ModuleDoc[] = Array.from(
    asyncState.state === "resolved" && (asyncState.value as any));

  const docs = [];
  // Only keep docs before the cursor.
  for (const doc of allDocs) {
    if (doc.pos.line <= cursorPos.line) {
      docs.push(doc);
    }
  }

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
            return katex.renderToString(s, { output: "html" });
          } catch (e) {
            return s;
          }
        }
      })
      .join("");
  }

  return <div dangerouslySetInnerHTML={{ __html: latexHtml }}></div>;
}
