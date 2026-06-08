# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

{%- set pkg_map = powershell_7.get('pkg', {}) %}
{%- set base_root = pkg_map.get('install_root') | default('/opt/microsoft/powershell/7', true) %}
{%- set config_target = base_root ~ '/powershell.config.json' %}
{%- set src_list = ['powershell.config.json', 'powershell.config.json.jinja'] %}
{%- set lookup_id = 'Manage PowerShell Client Configuration File' %}

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

{%- if pkg_map.get('download_uri') and not
       pkg_map.get('download_uri').endswith('.rpm') %}
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
      - selinux: Configure SELinux Policy Context for Custom Tree
      - sls: {{ sls_package_install }}
    - watch_in:
      - file: Manage PowerShell Client Configuration File
{%- endif %}
