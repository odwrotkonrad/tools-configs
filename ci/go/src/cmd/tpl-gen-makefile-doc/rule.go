package main

import (
	"strings"

	sitter "github.com/tree-sitter/go-tree-sitter"
)

// [>] 🤖🤖🤖
func ruleTarget(node *sitter.Node, src []byte, what string) (target, bool) {
	var name string
	for i := uint(0); i < node.NamedChildCount(); i++ {
		child := node.NamedChild(i)
		if child.Kind() == "targets" {
			name = strings.TrimSpace(child.Utf8Text(src))
			break
		}
	}
	if name == "" || strings.HasPrefix(name, ".") {
		return target{}, false
	}
	var chain []string
	if normal := node.ChildByFieldName("normal"); normal != nil {
		chain = words(normal.Utf8Text(src))
	}
	return target{name: name, what: what, chain: chain}, true
}

func words(s string) []string {
	return strings.Fields(strings.TrimSpace(s))
}

//[<] 🤖🤖🤖
