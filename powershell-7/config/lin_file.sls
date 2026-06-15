# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set base_root = pkg_map.get('install_root') |
        default('/opt/microsoft/powershell/7', true)
%}
{%- set config_target = base_root ~ '/powershell.config.json' %}
{%- set lookup_id = 'Manage PowerShell Client Configuration File' %}
{%- set src_list = [
          'powershell.config.json',
          'powershell.config.json.jinja'
        ]
%}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set shell_path = '/usr/local/bin/pwsh' if (
          powershell_download_uri and not
          powershell_download_uri.endswith('.rpm')
        ) else '/usr/bin/pwsh'
%}

{%- if powershell_download_uri and not
       powershell_download_uri.endswith('.rpm')
%}

Allow PowerShell in fapolicyd:
  file.managed:
    - contents: |
        allow perm=execute all : path={{ shell_path }}
        allow perm=execute all : dir={{ base_root }}/
        allow perm=any dir={{ base_root }}/ : all
    - makedirs: 'True'
    - name: '/etc/fapolicyd/rules.d/70-powershell.rules'

Configure SELinux Policy Context for Custom Tree:
  selinux.fcontext_policy_present:
    - filetype: 'a'
    - name: '{{ base_root }}(/.*)?'
    - sel_type: 'usr_t'

Enforce System SELinux Contexts on Extracted Tree:
  selinux.fcontext_policy_applied:
    - name: '{{ base_root }}'
    - recursive: 'True'
    - require:
      - selinux: 'Configure SELinux Policy Context for Custom Tree'
      - sls: {{ sls_package_install }}
    - watch_in:
      - file: 'Manage PowerShell Client Configuration File'

Recompile fapolicyd Rules Engine:
  cmd.run:
    - name: 'fagenrules --load'
    - onchanges:
      - file: 'Allow PowerShell in fapolicyd'
    - onlyif: 'command -v fagenrules'

{%- endif %}

Manage PowerShell Client Configuration File:
  file.managed:
    - context:
        powershell_7: '{{ powershell_7 | json }}'
    - group: '{{ salt["grains.get"]("rootgroup", "root") }}'
    - makedirs: 'True'
    - mode: '0644'
    - name: '{{ config_target }}'
    - require:
      - sls: {{ sls_package_install }}
    - source: '{{ files_switch(src_list, lookup=lookup_id) }}'
    - template: 'jinja'

Register PowerShell as Valid System Shell:
  file.append:
    - name: '/etc/shells'
    - require:
      - sls: {{ sls_package_install }}
    - text: '{{ shell_path }}'

Setup Basic Powershell User-Profiles:
  file.managed:
    - dir_mode: '0755'
    - group: 'root'
    - makedirs: 'True'
    - mode: '0644'
    - name: '/etc/skel/.config/powershell/profile.ps1'
    - selinux:
        serange: 's0'
        serole: 'object_r'
        setype: 'bin_t'
        seuser: 'system_u'
    - source: 'salt://{{ tplroot }}/files/default/profile.ps1'
    - user: 'root'

Setup User-Envs:
  file.managed:
    - contents: |
        # Suppress vendor tracking for compliance
        export DOTNET_CLI_TELEMETRY_OPTOUT=1
        export POWERSHELL_TELEMETRY_OPTOUT=1
        export POWERSHELL_UPDATECHECK=Off

        # Alias for those who like to type
        if [[ "${SHELL}" == *"/bash" ]]
        then
          alias powershell="/usr/local/bin/pwsh"
        fi
    - group: 'root'
    - mode: '0644'
    - name: '/etc/profile.d/powershell.sh'
    - selinux:
        serange: 's0'
        serole: 'object_r'
        setype: 'bin_t'
        seuser: 'system_u'
    - user: 'root'
