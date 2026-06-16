# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set powershell_package_name = pkg_map.get('name') | default('PowerShell', true) %}
{%- set powershell_version = pkg_map.get('version') | default('7.6.2', true) %}

{%- if not powershell_download_uri or not powershell_download_uri.endswith('.zip') %}

{%- set winrepo_local_dir = salt['config.get']('winrepo_local_dir', 'C:/salt/srv/salt/win/repo-ng') %}
{%- set winrepo_file = winrepo_local_dir ~ '/' ~ powershell_package_name | lower ~ '.sls' %}

{#- Format the version string for Windows MSI Product code compliance (requires a 4-part structure) -#}
{%- set win_version = powershell_version if powershell_version.count('.') >= 3 else powershell_version ~ '.0' %}

{#- Determine Registry DisplayName match attributes based on standard MSI definitions -#}
{%- set arch = 'x64' if salt['grains.get']('cpuarch') == 'AMD64' else 'x86' %}
{%- set major_version = powershell_version.split('.')[0] %}
{%- set full_name = 'PowerShell ' ~ major_version ~ '-' ~ arch %}

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
        {{ powershell_package_name }}:
          '{{ win_version }}':
            full_name: '{{ full_name }}'
            installer: '{{ powershell_download_uri }}'
            install_flags: '/qn /norestart'
            uninstall_flags: '/qn /norestart'
            msiexec: true

Compile local winrepo database:
  module.run:
    - name: winrepo.genrepo
    - onchanges:
      - file: 'Manage PowerShell winrepo definition file'

Refresh minion package manager database cache:
  module.run:
    - name: pkg.refresh_db
    - onchanges:
      - module: 'Compile local winrepo database'

{%- else %}

Skip winrepo definition for ZIP deployment:
  test.nop: []

{%- endif %}
