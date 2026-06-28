package fsutil

// [>] 🤖🤖

import (
	"os"
	"os/exec"
	"os/user"
	"runtime"
	"strings"
)

// DetectProfile -> "<space>/<os>-<arch>", space = bare-metal|virt. base has no detection.
func DetectProfile() string {
	osName := NormalizeOS(runtime.GOOS)
	arch := NormalizeArch(runtime.GOARCH)
	space := "bare-metal"
	if Virtualized() {
		space = "virt"
	}
	return space + "/" + osName + "-" + arch
}

func NormalizeOS(goos string) string {
	switch goos {
	case "darwin":
		return "mac-os"
	default:
		return goos
	}
}

func NormalizeArch(goarch string) string {
	switch goarch {
	case "arm64":
		return "aarch64"
	case "amd64":
		return "x86"
	default:
		return goarch
	}
}

// Virtualized: mac via kern.hv_vmm_present==1 (Apple VZ guest); linux via systemd-detect-virt / container markers.
func Virtualized() bool {
	switch runtime.GOOS {
	case "darwin":
		out, err := exec.Command("sysctl", "-n", "kern.hv_vmm_present").Output()
		return err == nil && strings.TrimSpace(string(out)) == "1"
	case "linux":
		if exec.Command("systemd-detect-virt", "-q").Run() == nil {
			return true
		}
		if _, err := os.Stat("/.dockerenv"); err == nil {
			return true
		}
		if b, err := os.ReadFile("/proc/1/cgroup"); err == nil {
			s := string(b)
			return strings.Contains(s, "docker") || strings.Contains(s, "containerd") || strings.Contains(s, "lxc")
		}
		return false
	default:
		return false
	}
}

// UserHome looks up the named user's home dir from passwd.
func UserHome(name string) (string, error) {
	u, err := user.Lookup(name)
	if err != nil {
		return "", err
	}
	return u.HomeDir, nil
}

// [<] 🤖🤖
