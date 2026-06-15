powershell-7-formula
==================

A SaltStack formula designed to install and configure the [Powershell 7 package](https://github.com/PowerShell/powershell/) on installation-targets.

It is primarily expected that this formula will be run via [P3](https://www.plus3it.com/)'s "[watchmaker](https://watchmaker.readthedocs.io/en/stable/)" framework.

This formula is able to install the Powershell 7 utility on Linux[^1] and Windows Server[^2] operating environments. Installation for internet-connected systems may come from the Powershell 7's ["Releases" page](https://github.com/PowerShell/PowerShell/releases). Alternately:

* Sites whose installation-targets won't be able to reach the Powershell 7 product's "Releases" page will need to self-host copies of the desired content.
* Sites that wish to use a specific version of the Powershell 7 will need to target that content

Targeting specific versions of the Powershell 7 or local copies of the install-archives can be directed to do so by adding appropriate content to the formula's associated Pillar-data (see this projct's [pillar.example](pillar.example) file for guidance).


## Available states

- [powershell-7](#powershell-7)
- [powershell-7.clean](#powershell-7.clean)
- [powershell-7.package](#powershell-7.package)
- [powershell-7.package.clean](#powershell-7.package.clean)
- [powershell-7.config](#powershell-7.config)
- [powershell-7.config.clean](#powershell-7.config.clean)

### powershell-7

Executes the `package` and `config` states to install and configure the Powershell 7

### powershell-7.clean

Executes the `package` and `config` states' `clean` actions to fully uninstall the Powershell 7 and remove previously-installed browser policy-configs (and, on Windows, associated registry entries)

### powershell-7.package

Executes _just_ the `package` state to install the Powershell 7 package.

### powershell-7.package.clean

Executes _just_ the `package.clean` state to uninstall the Powershell 7 package.

### powershell-7.config

Executes _just_ the `config` state to install/configure the Powershell 7 client-configuration (etc.) files

### powershell-7.config.clean

Executes _just_ the `config` state to uninstall the Powershell 7 client-configuration (etc.) files and, on Windows, remove any registry-keys set by prior install-runs of the formula.

## Compatibility Notes:

### Linux

Preliminary testing was performed on a STIG-hardened installation-target with FIPS-mode, SELinux and `fapolicyd` all enabled. No issues were observed during the authoring of this content[^3]. If any are found, please open a documentation-PR with generic guidance for how to provoke the issues encountered.


### Windows


[^1]: As of this README's writing, only Enterprise Linux and related distros (Red Hat and Oracle Enterprise, CentOS Stream, Rocky and Alma Linux) are supported. It has only been specifically tested with EL **_9_** variants.
[^2]: As of this README's writing, this functionality has only been tested on Windows Server 2022
[^3]: It is _possible_ &mdash; particularly when using the non-RPM installation-versions &mdash; that downloaded commandlets will not immediately work until the `fapolicyd` trust-database is updated. If such update is required:
    ```bash
    # fapolicyd-cli --file add ${INSTALL_ROOT}/ --trust-file powershell
    # fapolicyd-cli --update
    # fagenrules --load
    ```
