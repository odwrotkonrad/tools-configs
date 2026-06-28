package cli

// [>] 🤖🤖

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"

	"configs/ci/go/packages/che/internal/fsutil"
	"configs/ci/go/packages/che/internal/host"
	"configs/ci/go/packages/che/internal/spec"
)

// package vars: built once by the root PersistentPreRunE, read by each RunE.
var (
	dryRun   bool
	theHost  host.Host
	resolved spec.Resolved
)

// RootCmd is che's root command. It detects+resolves the profile (build) before
// any subcommand runs; subcommands are attached by the command package.
var RootCmd = &cobra.Command{
	Use:   "che",
	Short: "Spec-driven config loader",
	Long: `che detects OS+arch+virt -> profile in che.yml, then loads only the
files/dirs/installs/services that profile selects.`,
	SilenceUsage:  true,
	SilenceErrors: true,
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		return build()
	},
}

func init() {
	RootCmd.PersistentFlags().BoolVar(&dryRun, "dry-run", false,
		"print mutating actions instead of executing them")
}

// build detects -> loads spec -> resolves -> wires the host. Run by the root
// command's PersistentPreRunE before any subcommand RunE.
func build() error {
	repoRoot, err := findRepoRoot()
	if err != nil {
		return err
	}
	home, err := invokingHome()
	if err != nil {
		return err
	}
	// CHE_FORCE_PROFILE overrides detection (test/VM hook); detect lazily otherwise.
	profile := os.Getenv("CHE_FORCE_PROFILE")
	if profile == "" {
		profile = fsutil.DetectProfile()
	}
	h := host.New(repoRoot, home, profile, dryRun)
	sp, err := spec.Load(filepath.Join(repoRoot, "che.yml"))
	if err != nil {
		return err
	}
	res, err := sp.Resolve(profile, h.Root)
	if err != nil {
		return err
	}
	theHost = h
	resolved = res
	return nil
}

// findRepoRoot resolves the repo root from the git toplevel of cwd, then verifies
// che.yml lives there (che's defining marker).
func findRepoRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	root, err := fsutil.RepoRoot(dir)
	if err != nil {
		return "", err
	}
	if _, err := os.Stat(filepath.Join(root, "che.yml")); err != nil {
		return "", fmt.Errorf("che.yml not found at repo root %s", root)
	}
	return root, nil
}

// invokingHome resolves the invoking user's home. Running as root via sudo (EUID 0,
// SUDO_USER set), it looks up that user's home from passwd so dest paths derive from
// the real user, not /var/root. Otherwise it uses $HOME.
func invokingHome() (string, error) {
	if os.Geteuid() == 0 {
		if name := os.Getenv("SUDO_USER"); name != "" {
			h, err := fsutil.UserHome(name)
			if err != nil {
				return "", fmt.Errorf("lookup SUDO_USER %q: %w", name, err)
			}
			return h, nil
		}
	}
	home := os.Getenv("HOME")
	if home == "" {
		return "", fmt.Errorf("HOME must be set")
	}
	return home, nil
}

// [<] 🤖🤖
