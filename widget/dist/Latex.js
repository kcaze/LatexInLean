import { jsx as _jsx } from "react/jsx-runtime";
import { RpcContext, useAsync } from "@leanprover/infoview";
import katex from "katex";
import React from "react";
import "./css/katex.min.css";
export default function (props) {
    const rpcContext = React.useContext(RpcContext);
    const asyncState = useAsync(() => rpcContext.call("getDocStrings", { pos: props.pos }), [rpcContext, props.pos]);
    // Cursor position is 0-indexed but module docs are 1-indexed.
    // So add 1 to the line and column.
    const cursorPos = { line: props.pos.line + 1, column: props.pos.character + 1 };
    const rpcResponse = asyncState.state === "resolved" && asyncState.value;
    const docs = [];
    if (rpcResponse) {
        for (const data of rpcResponse.docStrings) {
            if (data[0] && data[1]) {
                const [docString, [start, end]] = data;
                if (start && end) {
                    if (start.line <= cursorPos.line) {
                        docs.push({
                            pos: {
                                line: start.line,
                                column: start.column
                            },
                            doc: docString
                        });
                    }
                }
            }
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
