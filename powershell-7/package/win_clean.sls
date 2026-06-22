# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set map_src = tplroot ~ "/map.jinja" %}
{%- from map_src import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}

# Derive specific package identification configurations from the map stack
{%- set base_root = pkg_map.get('install_root') |
        default('C:/Program Files/PowerShell/7', true) %}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set pkg_name = pkg_map.get('name', 'PowerShell') %}
{%- set is_zip = powershell_download_uri.endswith('.zip') %}

{%- set winrepo_local_dir = salt['config.get'](
        'winrepo_dir',
        'C:/Watchmaker/Salt/srv/winrepo/winrepo'
) %}
{%- set winrepo_file = winrepo_local_dir ~ '/' ~ pkg_name | lower ~ '.sls' %}

{%- if is_zip %}

Remove PowerShell Custom Installation Tree:
  file.absent:
    - name: '{{ base_root }}'

{%- else %}

Compile Local Winrepo Database After Deletion:
  module.run:
    - name: winrepo.genrepo
    - onchanges:
        - file: 'Remove Powershell Winrepo Definition File'

Refresh Minion Package Manager Database Cache After Deletion:
  module.run:
    - name: pkg.refresh_db
    - onchanges:
        - module: 'Compile Local Winrepo Database After Deletion'

Remove PowerShell Core Package:
  pkg.removed:
    - name: '{{ pkg_name }}'
    - require_in:
        - file: 'Remove Powershell Winrepo Definition File'

Remove Powershell Winrepo Definition File:
  file.absent:
    - name: '{{ winrepo_file }}'

{%- endif %}
