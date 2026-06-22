# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set full_name_override = pkg_map.get('full_name') %}
{%- set pkg_name = pkg_map.get('name', 'PowerShell') %}
{%- set powershell_download_uri = pkg_map.get('download_uri') %}
{%- set powershell_version = pkg_map.get('version') %}

# Execute a GitHub lookup if "download_uri" parameter is empty/nulled,
{%- if not powershell_download_uri %}
  {%- set api_url = 'https://api.github.com/repos/' ~
          'PowerShell/PowerShell/releases/latest' %}
  {%- set api_res = salt['http.query'](
          api_url,
          decode=True,
          decode_type='json'
  ) %}
  {%- if 'dict' in api_res and 'tag_name' in api_res['dict'] %}
    {%- set latest_tag = api_res['dict']['tag_name'] %}
    {%- set powershell_version = latest_tag | replace('v', '') %}
    {%- set arch = 'x64' if salt['grains.get']('cpuarch') == 'AMD64'
        else 'x86' %}
    {%- set powershell_download_uri = 'https://github.com/' ~
            'PowerShell/PowerShell/releases/download/' ~ latest_tag ~
            '/PowerShell-' ~ powershell_version ~ '-win-' ~ arch ~ '.msi' %}
  {%- endif %}
{%- endif %}

{%- if powershell_download_uri and not powershell_version %}

Enforce Explicit Version Contract:
  test.fail_without_changes:
    - name: 'Pillar configuration missing required "version" attribute!'

{%- else %}

  {%- set is_zip = powershell_download_uri.endswith('.zip') if
          powershell_download_uri else False %}

  {%- if not is_zip %}

    {%- set winrepo_local_dir = salt['config.get'](
            'winrepo_dir',
            'C:/Watchmaker/Salt/srv/winrepo/winrepo'
    ) %}
    {%- set winrepo_file = winrepo_local_dir ~ '/' ~
            pkg_name | lower ~ '.sls' %}

    # Winrepo wants 4-part version-string
    {%- set win_version = powershell_version ~ '.0' if
            powershell_version.count('.') < 3 else
            powershell_version %}

    # Use machine grains to compute display attributes
    {%- set arch = 'x64' if salt['grains.get']('cpuarch') == 'AMD64'
            else 'x86' %}
    {%- set major_version = powershell_version.split('.')[0] if
            powershell_version else '7' %}
    {%- set default_full_name = 'PowerShell ' ~ major_version ~ '-' ~ arch %}
    {%- set full_name = full_name_override if full_name_override else
            default_full_name %}

Compile Local Winrepo Database:
  module.run:
    - name: winrepo.genrepo
    - onchanges:
      - file: 'Manage Powershell Winrepo Definition File'

Ensure Local Winrepo Directory Exists:
  file.directory:
    - makedirs: True
    - name: '{{ winrepo_local_dir }}'

Manage Powershell Winrepo Definition File:
  file.managed:
    - contents: |
        {{ pkg_name }}:
          '{{ win_version }}':
            full_name: '{{ full_name }}'
            install_flags: '/qn /norestart'
            installer: '{{ powershell_download_uri }}'
            msiexec: true
            uninstall_flags: '/qn /norestart'
    - makedirs: True
    - name: '{{ winrepo_file }}'
    - require:
      - file: 'Ensure Local Winrepo Directory Exists'

Refresh Minion Package Manager Database Cache:
  module.run:
    - name: pkg.refresh_db
    - onchanges:
      - module: 'Compile Local Winrepo Database'

  {%- else %}
Skip Winrepo Definition For Zip Deployment:
  test.nop: []
  {%- endif %}
{%- endif %}
