package log

// [>] 🤖🤖

import (
	"fmt"
	"time"
)

// Msg prints 'HH:MM:SS.mmm: <title>: <msg>', matching zsh fn-log-msg.
func Msg(title, msg string, dryRun bool) {
	stamp := time.Now().Format("15:04:05.000")
	suffix := ""
	if dryRun {
		suffix = " [dry-run]"
	}
	fmt.Printf("%s: %s: %s%s\n", stamp, title, msg, suffix)
}

// [<] 🤖🤖
