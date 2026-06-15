## powershell-7-formula

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

### 0.1.0

**Released**: 2026.06.15

**Summary**:

*   Added ("Enterprise") Linux functionality
    *   Installs the Powershell 7.x binaries. RPM-installer may be installed by following [vendor-guidance page](https://learn.microsoft.com/en-us/powershell/scripting/install/install-rhel) or the GitHub project's [releases page](https://github.com/PowerShell/powershell/releases).
        *   Install-location defaults to `/opt/microsoft/powershell/7`
        *   Install-location overrideable via Pillar's `install_root` parameter
        *   For RHEL 9 (and related distros), latest installable version is 7.6.2 (override via Pillar's `download_uri` parameter)
    *   Creates a symlink at `/usr/local/bin/pwsh` pointing at `${install_root}/pwsh`
    *   Sets appropriate file-modes and SELinux contexts on binaries, libraries, etc.
    *   Creates `fapolicyd` rules to allow use on more-hardened systems
    *   Implements "cleanup" for all of the preceeding
*   Adds pillar.example to explain parameters/inputs that may be specified via Pillar
*   Update README with platform-notes

### 0.0.1

**Released**: 2026.06.08

**Summary**:

*   Cloned project from https://github.com/plus3it/repo-template
*   Created powershell-7 directory-tree contents by:
    1.   Cloning https://github.com/saltstack-formulas/template-formula.git
    2.   Executing `bin/convert-formula.sh powershell-7` in the new repo-copy
    3.   Moving the resulting `powershell-7` directory into this project's space
    4.   Updating all imports from "`powershell__7`" to "`powershell_7`"
*   Update [LICENSE](LICENSE), CHANGELOG.md (this file), [README.md](README.md) and [.bumpversion.cfg](.bumpversion.cfg) per the P3 repo-template guidance
*   Update the `.github` and `tests` directories' contents  per the P3 repo-template guidance
