package main

// [>] 🤖🤖🤖

// sync runs every load pass in order: prune-links, mk-dirs, link, copy, render-templates.
func (a *app) sync() error {
	for _, pass := range []func() error{
		a.passPrune,
		a.passDirs,
		a.passLink,
		a.passCopy,
		a.passTmpl,
	} {
		if err := pass(); err != nil {
			return err
		}
	}
	return nil
}

// [<] 🤖🤖🤖
