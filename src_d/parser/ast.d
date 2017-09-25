module helm.parser.ast;

import helm.lexer;
import helm.types;

enum CallingConvention {
    HELM, C
}

abstract class AstNode {
    Token t;
    @property abstract uint my_id();
}

abstract class AstNodeWithAttrs : AstNode {
    AstNode[] attributes;
}

struct _AstNodeCTInfo {
    string kind;
    string contents;
    string base = "AstNode";
}

public _AstNodeCTInfo[] getAstNodeCTList() {
    return [
        _AstNodeCTInfo("Identifier", ""),
        _AstNodeCTInfo("Literal", ""),
        _AstNodeCTInfo("Import", "AstNode path, rename;"),
        _AstNodeCTInfo("AccessChild", "Token[] path;"),
        _AstNodeCTInfo("CallExpr", "AstNode func; AstNode[] args;"),
        _AstNodeCTInfo("TernaryExpr", "AstNode cond, if_yes, if_no;"),
        _AstNodeCTInfo("AssignStmt", "AstNode[] left, right; AstNode type; bool creation, constant;"),
        _AstNodeCTInfo("IncrDecrStmt", "AstNode var;"),
        _AstNodeCTInfo("UnaryExpr", "AstNode expr;"),
        _AstNodeCTInfo("BinaryExpr", "AstNode left, right;"),
        _AstNodeCTInfo("Block", "AstNode[] stmts;", "AstNodeWithAttrs"),
        _AstNodeCTInfo("FuncLiteral", "AstNode foreign_name, foreign_lib, body; AstNode[] params, returns; CallingConvention cc;", "AstNodeWithAttrs"),
    ];
}

private immutable uint[TypeInfo] nodeIds;
mixin(({
    auto list = getAstNodeCTList();
    string s = "shared static this() {";
    uint running_total = 0;
    import std.conv : to;
    foreach(n; list) {
        s ~= "nodeIds[typeid(" ~ n.kind ~ ")] = " ~ to!string(running_total++) ~ ";";
    }
    return s ~ "}";
})());

mixin(({
    auto list = getAstNodeCTList();
    string s;
    uint running_total = 0;
    import std.conv : to;
    foreach(c; list) {
        s ~= "class " ~ c.kind ~ " : AstNode {" ~ c.contents ~ "@property override uint my_id() { return " ~ to!string(running_total++) ~ ";}}\n";
    }
    return s;
})());