import { jsx as _jsx } from "react/jsx-runtime";
import { RpcContext, useAsync } from "@leanprover/infoview";
import katex from "katex";
import React from "react";
import "./css/katex.min.css";
export default function (props) {
    const rpcContext = React.useContext(RpcContext);
    const asyncState = useAsync(() => rpcContext.call("getModuleDocs", { pos: props.pos }), [rpcContext, props.pos]);
    const docs = asyncState.state === "resolved" && asyncState.value;
    let latexHtml = null;
    if (docs && docs.length > 0) {
        const doc = docs[docs.length - 1].doc;
        latexHtml = doc
            .split("$")
            .map((s, i) => {
            if (i % 2 == 0) {
                return s;
            }
            else {
                try {
                    return katex.renderToString(s, { output: "html" });
                }
                catch (e) {
                    return s;
                }
            }
        })
            .join("");
    }
    return _jsx("div", { dangerouslySetInnerHTML: { __html: latexHtml } });
}
