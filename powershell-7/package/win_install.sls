# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set base_root = pkg_map.get('install_root') | default('C:/Program Files/PowerShell/7', true) %}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set powershell_package_name = pkg_map.get('name') | default('PowerShell', true) %}

{%- if powershell_download_uri and powershell_download_uri.endswith('.zip') %}

Extract PowerShell from Zip Archive:
  archive.extracted:
    - name: '{{ base_root }}'
    - source: '{{ powershell_download_uri }}'
    {%- if pkg_map.get('download_sig') %}
    - source_hash: '{{ pkg_map.get('download_sig') }}'
    {%- else %}
    - skip_verify: True
    {%- endif %}
    - archive_format: zip
    - enforce_toplevel: False

{%- else %}

Install PowerShell via Winrepo Package Manager:
  pkg.installed:
    - name: '{{ powershell_package_name }}'

{%- endif %}
