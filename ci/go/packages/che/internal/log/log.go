package log

// [>] 🤖🤖

import (
	"fmt"
	"time"
)

// Msg prints 'HH:MM:SS.mmm: <title>: <msg>' to match the zsh fn-log-msg format.
func Msg(title, msg string, dryRun bool) {
	now := time.Now()
	stamp := now.Format("15:04:05") + "." + fmt.Sprintf("%03d", now.Nanosecond()/1e6)
	if dryRun {
		fmt.Printf("%s: %s: %s [dry-run]\n", stamp, title, msg)
		return
	}
	fmt.Printf("%s: %s: %s\n", stamp, title, msg)
}

// [<] 🤖🤖
