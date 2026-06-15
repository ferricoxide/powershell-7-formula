# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set base_root = pkg_map.get('install_root') |
        default('/opt/microsoft/powershell/7', true)
%}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set shell_path = '/usr/local/bin/pwsh' if (
          powershell_download_uri and not
          powershell_download_uri.endswith('.rpm')
        ) else '/usr/bin/pwsh'
%}

Remove Global PowerShell Profile:
  file.absent:
    - name: '{{ base_root }}/profile.ps1'

Remove OpenSSH PowerShell Subsystem Dropin:
  file.absent:
    - name: '/etc/ssh/sshd_config.d/40-powershell.conf'

Remove PowerShell Environment Profile Script:
  file.absent:
    - name: '/etc/profile.d/powershell.sh'

Remove PowerShell From Valid System Shells:
  file.replace:
    - name: '/etc/shells'
    - pattern: '^{{ shell_path }}(\n|$)'
    - repl: ''

Remove PowerShell Skeleton Configuration Directory:
  file.absent:
    - name: '/etc/skel/.config/powershell'

{%- if  powershell_download_uri and not
        powershell_download_uri.endswith('.rpm')
%}

Remove PowerShell Fapolicyd Rules File:
  file.absent:
    - name: '/etc/fapolicyd/rules.d/70-powershell.rules'
    - watch_in:
      - cmd: 'Reload Fapolicyd Engine After Deletion'

Remove PowerShell Fapolicyd Trust File:
  file.absent:
    - name: '/etc/fapolicyd/trust.d/powershell'
    - watch_in:
      - cmd: 'Reload Fapolicyd Engine After Deletion'

Remove SELinux Policy Context for Custom Tree:
  selinux.fcontext_policy_absent:
    - filetype: 'a'
    - name: '{{ base_root }}(/.*)?'
    - sel_type: 'usr_t'

Reload Fapolicyd Engine After Deletion:
  cmd.run:
    - name: 'fagenrules --load && fapolicyd-cli --update'
    - onchanges:
      - file: 'Remove PowerShell Fapolicyd Rules File'
      - file: 'Remove PowerShell Fapolicyd Trust File'
    - onlyif: 'command -v fagenrules'

{%- endif %}
