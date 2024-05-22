import { jsx as _jsx } from "react/jsx-runtime";
import { RpcContext, useAsync } from "@leanprover/infoview";
import katex from "katex";
import React, { createElement } from "react";
export default function (props) {
    const rpcContext = React.useContext(RpcContext);
    const [ref, setRef] = React.useState(null);
    const asyncState = useAsync(() => rpcContext.call("getType", { pos: props.pos }), [rpcContext, props.pos]);
    if (ref) {
        const test = katex.render("hello", ref);
    }
    const element = asyncState.state === "resolved" &&
        createElement("span", { ref: setRef }, asyncState.value);
    return _jsx("div", { children: JSON.stringify(asyncState) });
}
