package main

import (
	"strings"
	"unsafe"

	sitter "github.com/tree-sitter/go-tree-sitter"
	tsmake "github.com/tree-sitter-grammars/tree-sitter-make/bindings/go"
)

// [>] 🤖🤖🤖
type target struct {
	name  string
	what  string
	chain []string
}

type section struct {
	heading string
	level   int
	targets []target
}

type frame struct {
	heading string
	depth   int
	level   int
	kept    bool
}

func parse(src []byte) ([]section, error) {
	parser := sitter.NewParser()
	if err := parser.SetLanguage(sitter.NewLanguage(unsafe.Pointer(tsmake.Language()))); err != nil {
		return nil, err
	}
	tree := parser.Parse(src, nil)
	root := tree.RootNode()

	var out []section
	var stack []frame
	var pendingWhat string

	emit := func(f frame, ts []target) {
		if f.kept && len(ts) > 0 {
			out = append(out, section{heading: f.heading, level: f.level, targets: ts})
		}
	}

	cur := func() *frame {
		if len(stack) == 0 {
			return nil
		}
		return &stack[len(stack)-1]
	}

	var buf [][]target // parallel to stack: buffered targets per open frame

	for i := uint(0); i < root.NamedChildCount(); i++ {
		node := root.NamedChild(i)
		text := strings.TrimSpace(node.Utf8Text(src))

		switch node.Kind() {
		case "comment":
			if label, depth, ok := sectionOpen(text); ok {
				if c := cur(); c != nil {
					emit(*c, buf[len(buf)-1])
					buf[len(buf)-1] = nil
				}
				kept := strings.Contains(text, includeTag) || (cur() != nil && cur().kept)
				level := 3 + depth
				stack = append(stack, frame{
					heading: label,
					depth:   depth,
					level:   level,
					kept:    kept,
				})
				buf = append(buf, nil)
				pendingWhat = ""
			} else if depth, ok := sectionClose(text); ok {
				for len(stack) > 0 && stack[len(stack)-1].depth >= depth {
					emit(stack[len(stack)-1], buf[len(buf)-1])
					stack = stack[:len(stack)-1]
					buf = buf[:len(buf)-1]
				}
				pendingWhat = ""
			} else if what, ok := whatComment(text); ok {
				pendingWhat = what
			} else {
				pendingWhat = ""
			}
		case "rule":
			if c := cur(); c != nil && c.kept {
				if t, ok := ruleTarget(node, src, pendingWhat); ok {
					buf[len(buf)-1] = append(buf[len(buf)-1], t)
				}
			}
			pendingWhat = ""
		default:
			pendingWhat = ""
		}
	}
	for len(stack) > 0 {
		emit(stack[len(stack)-1], buf[len(buf)-1])
		stack = stack[:len(stack)-1]
		buf = buf[:len(buf)-1]
	}
	return out, nil
}

//[<] 🤖🤖🤖
