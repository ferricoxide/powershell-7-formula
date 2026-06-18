# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set base_root = pkg_map.get('install_root') |
        default('C:/Program Files/PowerShell/7', true) %}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set is_zip = powershell_download_uri.endswith('.zip') %}

{%- set target_binary = base_root ~ '/pwsh.exe' %}
{%- set public_desktop = 'C:/Users/Public/Desktop' %}
{%- set public_start_menu =
        'C:/ProgramData/Microsoft/Windows/Start Menu/Programs' %}

Ensure Public Desktop Directory Exists:
  file.directory:
    - makedirs: True
    - name: '{{ public_desktop }}'

{%- if is_zip %}

Ensure Public Start Menu Directory Exists:
  file.directory:
    - makedirs: True
    - name: '{{ public_start_menu }}'

{%- endif %}

Manage Desktop Launcher Shortcut:
  shortcut.present:
    - arguments: ''
    - description: 'PowerShell 7 Enterprise Console'
    - icon_index: 0
    - icon_location: '{{ target_binary }}'
    - name: '{{ public_desktop }}/PowerShell 7.lnk'
    - require:
      - file: 'Ensure Public Desktop Directory Exists'
    - target: '{{ target_binary }}'
    - working_dir: '{{ base_root }}'

{%- if is_zip %}

Manage Start Menu Launcher Shortcut:
  shortcut.present:
    - arguments: ''
    - description: 'PowerShell 7 Enterprise Console'
    - icon_index: 0
    - icon_location: '{{ target_binary }}'
    - name: '{{ public_start_menu }}/PowerShell 7.lnk'
    - require:
      - file: 'Ensure Public Start Menu Directory Exists'
    - target: '{{ target_binary }}'
    - working_dir: '{{ base_root }}'

{%- endif %}
