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

{%- if powershell_download_uri and not
       powershell_download_uri.endswith('.rpm')
%}
Allow PowerShell in fapolicyd:
  file.managed:
    - contents: 'allow perm=any dir={{ base_root }}/ : all'
    - makedirs: True
    - name: '/etc/fapolicyd/rules.d/10-powershell.rules'

Configure SELinux Policy Context for Custom Tree:
  selinux.fcontext_policy_present:
    - filetype: 'a'
    - name: '{{ base_root }}(/.*)?'
    - sel_type: 'usr_t'

Enforce System SELinux Contexts on Extracted Tree:
  selinux.fcontext_policy_applied:
    - name: '{{ base_root }}'
    - recursive: True
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
        powershell_7: {{ powershell_7 | json }}
    - group: {{ salt['grains.get']('rootgroup', 'root') }}
    - makedirs: True
    - mode: 644
    - name: '{{ config_target }}'
    - require:
      - sls: {{ sls_package_install }}
    - source: {{ files_switch(src_list, lookup=lookup_id) }}
    - template: jinja
