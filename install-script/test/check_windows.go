//go:build windows

package sumologic_scripts_tests

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"testing"
	"unsafe"

	"github.com/stretchr/testify/assert"
	"golang.org/x/sys/windows"
)

var (
	modAdvapi32                   = syscall.NewLazyDLL("advapi32.dll")
	procGetExplicitEntriesFromACL = modAdvapi32.NewProc("GetExplicitEntriesFromAclW")
)

// A Windows ACL record. Windows represents these as windows.EXPLICIT_ACCESS, which comes with an impractical
// representation of trustees. Instead, we just use a string representation of SIDs.
type ACLRecord struct {
	SID               string
	AccessPermissions windows.ACCESS_MASK
	AccessMode        windows.ACCESS_MODE
}

func checkAbortedDueToNoToken(c check) bool {
	if !assert.Greater(c.test, len(c.output), 1) {
		return false
	}
	if !assert.Greater(c.test, len(c.errorOutput), 1) {
		return false
	}
	// The exact formatting of the error message can be different depending on Powershell version
	errorOutput := strings.Join(c.errorOutput, " ")
	if !assert.Contains(c.test, errorOutput, "Installation token has not been provided.") {
		return false
	}
	return assert.Contains(c.test, errorOutput, "Please set the SUMOLOGIC_INSTALLATION_TOKEN environment variable.")
}

func checkBinaryFipsError(c check) bool {
	cmd := exec.Command(binaryPath, "--version")
	_, err := cmd.Output()
	if !assert.Error(c.test, err, "running on a non-FIPS system must error") {
		return false
	}

	exitErr, ok := err.(*exec.ExitError)
	if !assert.True(c.test, ok, "returned error must be of type ExitError") {
		return false
	}

	if !assert.Equal(c.test, 2, exitErr.ExitCode(), "got error code while checking version") {
		return false
	}
	return assert.Contains(c.test, string(exitErr.Stderr), "not in FIPS mode")
}

func checkEphemeralNotInConfig(p string) func(c check) bool {
	return func(c check) bool {
		assert.False(c.test, c.installOptions.ephemeral, "ephemeral was specified")

		conf, err := getConfig(p)
		if !assert.NoError(c.test, err, "error while reading configuration") {
			return false
		}

		assert.False(c.test, conf.Extensions.Sumologic.Ephemeral, "ephemeral is true")
		return true
	}
}

func checkEphemeralInConfig(p string) func(c check) bool {
	return func(c check) bool {
		assert.True(c.test, c.installOptions.ephemeral, "ephemeral was not specified")

		conf, err := getConfig(p)
		if !assert.NoError(c.test, err, "error while reading configuration") {
			return false
		}

		assert.True(c.test, conf.Extensions.Sumologic.Ephemeral, "ephemeral is not true")
		return true
	}
}

func checkClobberInSumoConfig(p string) func(c check) bool {
	return func(c check) bool {
		assert.True(c.test, c.installOptions.clobber, "clobber was not specified")

		conf, err := getConfig(p)
		if !assert.NoError(c.test, err, "error while reading configuration") {
			return false
		}

		assert.True(c.test, conf.Extensions.Sumologic.Clobber, "clobber is not true")
		return true
	}
}

func checkCollectorNameInConfig(c check) bool {
	if !assert.NotEmpty(c.test, c.installOptions.collectorName, "collector name has not been provided") {
		return false
	}

	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	return assert.Equal(c.test, c.installOptions.collectorName, conf.Extensions.Sumologic.CollectorName, "collector name is different than expected")
}

func checkTokenInConfig(c check) bool {
	if !assert.NotEmpty(c.test, c.installOptions.installToken, "installation token has not been provided") {
		return false
	}

	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	return assert.Equal(c.test, c.installOptions.installToken, conf.Extensions.Sumologic.InstallationToken, "installation token is different than expected")
}

func checkTokenInSumoConfig(c check) bool {
	if !assert.NotEmpty(c.test, c.installOptions.installToken, "installation token has not been provided") {
		return false
	}

	conf, err := getConfig(configPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	return assert.Equal(c.test, c.installOptions.installToken, conf.Extensions.Sumologic.InstallationToken, "installation token is different than expected")
}

func checkConfigFilesOwnershipAndPermissions(ownerSid string) func(c check) bool {
	return func(c check) bool {
		etcPathGlob := filepath.Join(etcPath, "*")
		etcPathNestedGlob := filepath.Join(etcPath, "*", "*")

		for _, glob := range []string{etcPathGlob, etcPathNestedGlob} {
			paths, err := filepath.Glob(glob)
			if !assert.NoError(c.test, err) {
				return false
			}
			for _, path := range paths {
				var aclRecords []ACLRecord
				info, err := os.Stat(path)
				if !assert.NoError(c.test, err) {
					return false
				}
				if info.IsDir() {
					if path == opampDPath {
						aclRecords = opampDPermissions
					} else {
						aclRecords = configPathDirPermissions
					}
				} else {
					aclRecords = configPathFilePermissions
				}
				PathHasWindowsACLs(c.test, path, aclRecords)
				PathHasOwner(c.test, path, ownerSid)
			}
		}
		return true
	}
}

func PathHasOwner(t *testing.T, path string, ownerSID string) bool {
	securityDescriptor, err := windows.GetNamedSecurityInfo(
		path,
		windows.SE_FILE_OBJECT,
		windows.OWNER_SECURITY_INFORMATION,
	)
	if !assert.NoError(t, err) {
		return false
	}

	// get the owning user
	owner, _, err := securityDescriptor.Owner()
	if !assert.NoError(t, err) {
		return false
	}

	return assert.Equal(t, ownerSID, owner.String(), "%s should be owned by user '%s'", path, ownerSID)
}

func PathHasWindowsACLs(t *testing.T, path string, expectedACLs []ACLRecord) bool {
	securityDescriptor, err := windows.GetNamedSecurityInfo(
		path,
		windows.SE_FILE_OBJECT,
		windows.DACL_SECURITY_INFORMATION,
	)
	if !assert.NoError(t, err) {
		return false
	}

	// get the ACL entries
	acl, _, err := securityDescriptor.DACL()
	if !assert.NoError(t, err) || !assert.NotNil(t, acl) {
		return false
	}
	entries, err := GetExplicitEntriesFromACL(acl)
	if !assert.NoError(t, err) {
		return false
	}
	aclRecords := []ACLRecord{}
	for _, entry := range entries {
		aclRecord := ExplicitEntryToACLRecord(entry)
		if aclRecord != nil {
			aclRecords = append(aclRecords, *aclRecord)
		}
	}
	assert.Equal(t, expectedACLs, aclRecords, "invalid ACLs for %s", path)
	return true
}

// GetExplicitEntriesFromACL gets a list of explicit entries from an ACL
// This doesn't exist in golang.org/x/sys/windows so we need to define it ourselves.
func GetExplicitEntriesFromACL(acl *windows.ACL) ([]windows.EXPLICIT_ACCESS, error) {
	var pExplicitEntries *windows.EXPLICIT_ACCESS
	var explicitEntriesSize uint64
	// Get dacl
	r1, _, err := procGetExplicitEntriesFromACL.Call(
		uintptr(unsafe.Pointer(acl)),
		uintptr(unsafe.Pointer(&explicitEntriesSize)),
		uintptr(unsafe.Pointer(&pExplicitEntries)),
	)
	if r1 != 0 {
		return nil, err
	}
	if pExplicitEntries == nil {
		return []windows.EXPLICIT_ACCESS{}, nil
	}

	// convert the pointer we got from Windows to a Go slice by doing some gnarly looking pointer arithmetic
	explicitEntries := make([]windows.EXPLICIT_ACCESS, explicitEntriesSize)
	for i := 0; i < int(explicitEntriesSize); i++ {
		elementPtr := unsafe.Pointer(
			uintptr(unsafe.Pointer(pExplicitEntries)) +
				uintptr(i)*unsafe.Sizeof(pExplicitEntries),
		)
		explicitEntries[i] = *(*windows.EXPLICIT_ACCESS)(elementPtr)
	}
	return explicitEntries, nil
}

// ExplicitEntryToACLRecord converts a windows.EXPLICIT_ACCESS to a ACLRecord. If the trustee type is not SID,
// we return nil.
func ExplicitEntryToACLRecord(entry windows.EXPLICIT_ACCESS) *ACLRecord {
	trustee := entry.Trustee
	if trustee.TrusteeType != windows.TRUSTEE_IS_SID {
		return nil
	}
	trusteeSid := (*windows.SID)(unsafe.Pointer(entry.Trustee.TrusteeValue))
	return &ACLRecord{
		SID:               trusteeSid.String(),
		AccessMode:        entry.AccessMode,
		AccessPermissions: entry.AccessPermissions,
	}
}
