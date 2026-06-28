package main

// [>] 🤖🤖🤖

import (
	"os"
	"os/exec"
	"runtime"
	"strings"
)

// detectProfile -> "<space>/<os>-<arch>", space = bare-metal|virt. base has no detection.
func detectProfile() string {
	osName := normalizeOS(runtime.GOOS)
	arch := normalizeArch(runtime.GOARCH)
	space := "bare-metal"
	if isVirtualized() {
		space = "virt"
	}
	return space + "/" + osName + "-" + arch
}

func normalizeOS(goos string) string {
	switch goos {
	case "darwin":
		return "mac-os"
	default:
		return goos
	}
}

func normalizeArch(goarch string) string {
	switch goarch {
	case "arm64":
		return "aarch64"
	case "amd64":
		return "x86"
	default:
		return goarch
	}
}

// isVirtualized: mac via kern.hv_vmm_present==1 (Apple VZ guest); linux via systemd-detect-virt / container markers.
func isVirtualized() bool {
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

// [<] 🤖🤖🤖
