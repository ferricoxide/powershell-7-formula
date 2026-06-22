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

The Windows-portion of this formula supports the use of either ZIP- or MSI-based installation. If no override-arguments are given via Pillar, the formula will attempt to identify, download and install from the GitHub-hosted MSI file. Pillar-data can be used to:
* Select a specific 7.x.y version to install
* Select the use of a ZIP-based installation-method
* Download from a custom repository (e.g., an installation-archive hosted in S3)

This formula will attempt to install [winrepo](https://docs.saltproject.io/en/latest/topics/windows/windows-package-manager.html) definitions for PowerShell 7.X if the MSI-based installation-method is used. When this formula is run via a userData payload, the various SaltStack content, like the winrepo, will be owned by the SYSTEM-user context. If attempting to run the "clean" states, the interactive user will typically operate under a different scope. This will frequently cause the winrepo portion of the "clean" routines to fail. Logged output will be similar to:

> ```yaml
> [ERROR   ] Module function winrepo.genrepo threw an exception. Exception: [Errno 13] Permission denied: 'C:\\Watchmaker\\Salt\\srv\\
> winrepo\\winrepo\\winrepo.p'
> local:
> ----------
> [...ELIDED...]
> ----------
>           ID: Compile Local Winrepo Database After Deletion
>     Function: module.run
>         Name: winrepo.genrepo
>       Result: False
>      Comment: Module function winrepo.genrepo threw an exception. Exception: [Errno 13] Permission denied: 'C:\\Watchmaker\\Salt\\sr
> v\\winrepo\\winrepo\\winrepo.p'
>      Started: 15:56:45.448565
>     Duration: 252.323 ms
>      Changes:
> ----------
>           ID: Refresh Minion Package Manager Database Cache After Deletion
>     Function: module.run
>         Name: pkg.refresh_db
>       Result: False
>      Comment: One or more requisite failed: powershell-7.package.win_clean.Compile Local Winrepo Database After Deletion
>      Started: 15:56:45.700888
>     Duration: 0.0 ms
>      Changes:
> ----------
> [...ELIDED...]
> ----------
> ```

The `[Errno 13] Permission denied` should also show up in the Watchmaker and SaltStack log-files.


[^1]: As of this README's writing, only Enterprise Linux and related distros (Red Hat and Oracle Enterprise, CentOS Stream, Rocky and Alma Linux) are supported. It has only been specifically tested with EL **_9_** variants.
[^2]: As of this README's writing, this functionality has only been tested on Windows Server 2022
[^3]: It is _possible_ &mdash; particularly when using the non-RPM installation-versions &mdash; that downloaded commandlets will not immediately work until the `fapolicyd` trust-database is updated. If such update is required:
    ```bash
    # fapolicyd-cli --file add ${INSTALL_ROOT}/ --trust-file powershell
    # fapolicyd-cli --update
    # fagenrules --load
    ```
