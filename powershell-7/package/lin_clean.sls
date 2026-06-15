# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set config_map = powershell_7.get('config') or {} %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set base_root = pkg_map.get('install_root') |
        default('/opt/microsoft/powershell/7', true)
%}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set powershell_package_name = pkg_map.get('name') |
        default('powershell', true)
%}
{%- set repo_rpm_name = config_map.get('repo_rpm_name') |
        default('packages-microsoft-prod', true)
%}

{%- if powershell_download_uri and not
       powershell_download_uri.endswith('.rpm')
%}

Remove PowerShell Custom Installation Tree:
  file.absent:
    - name: '{{ base_root }}'

Remove PowerShell Symlink From Userland:
  file.absent:
    - name: '/usr/local/bin/pwsh'

{%- else %}

Remove PowerShell Core Package:
  pkg.removed:
    - name: '{{ powershell_package_name }}'

Remove PowerShell Repo Definition Package:
  pkg.removed:
    - name: '{{ repo_rpm_name }}'

{%- endif %}
