# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set dl_uri = pkg_map.get('download_uri') %}
{%- set pkg_name = pkg_map.get('name', 'PowerShell') %}
{%- set version = pkg_map.get('version') %}
{%- set full_name = pkg_map.get('full_name', 'PowerShell 7-x64') %}

{%- if not dl_uri or not dl_uri.endswith('.zip') %}
  {%- set winrepo_local_dir = salt['config.get']('winrepo_dir',
      'C:\\Watchmaker\\Salt\\srv\\winrepo\\winrepo') %}
  {%- set winrepo_file = winrepo_local_dir ~ '/' ~ pkg_name | lower ~ '.sls' %}

Compile local winrepo database:
  module.run:
    - name: winrepo.genrepo
    - onchanges:
      - file: 'Manage PowerShell winrepo definition file'

Ensure local winrepo directory exists:
  file.directory:
    - name: '{{ winrepo_local_dir }}'
    - makedirs: True

Manage PowerShell winrepo definition file:
  file.managed:
    - name: '{{ winrepo_file }}'
    - makedirs: True
    - require:
      - file: 'Ensure local winrepo directory exists'
    - contents: |
        {{ pkg_name }}:
          '{{ version }}.0':
            full_name: '{{ full_name }}'
            install_flags: '/qn /norestart'
            installer: '{{ dl_uri }}'
            msiexec: true
            uninstall_flags: '/qn /norestart'

Refresh minion package manager database cache:
  module.run:
    - name: pkg.refresh_db
    - onchanges:
      - module: 'Compile local winrepo database'

{% else %}

Skip winrepo definition for ZIP deployment:
  test.nop: []

{% endif %}
