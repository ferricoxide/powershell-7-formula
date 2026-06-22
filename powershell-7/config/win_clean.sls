# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set map_src = tplroot ~ "/map.jinja" %}
{%- from map_src import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}

# Extract path parameters safely from the merged dictionary layout
{%- set base_root = pkg_map.get('install_root') |
        default('C:/Program Files/PowerShell/7', true) %}
{%- set env_reg = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\' ~
        'Control\\Session Manager\\Environment' %}
{%- set public_desktop = 'C:/Users/Public/Desktop' %}
{%- set public_start_menu =
        'C:/ProgramData/Microsoft/Windows/Start Menu/Programs' %}

Remove Desktop Launcher Shortcut:
  file.absent:
    - name: '{{ public_desktop }}/PowerShell 7.lnk'

Remove Dotnet Cli Telemetry Tracking Key:
  reg.absent:
    - name: '{{ env_reg }}'
    - vname: 'DOTNET_CLI_TELEMETRY_OPTOUT'

Remove Global Enterprise Powershell Profile Script:
  file.absent:
    - name: '{{ base_root }}/Microsoft.PowerShell_profile.ps1'

Remove Powershell Core Telemetry Tracking Key:
  reg.absent:
    - name: '{{ env_reg }}'
    - vname: 'POWERSHELL_TELEMETRY_OPTOUT'

Remove Powershell Seven Update Notification Key:
  reg.absent:
    - name: '{{ env_reg }}'
    - vname: 'POWERSHELL_UPDATECHECK'

Remove Start Menu Launcher Shortcut:
  file.absent:
    - name: '{{ public_start_menu }}/PowerShell 7.lnk'

Remove System Execution Policy Configuration:
  file.absent:
    - name: '{{ base_root }}/powershell.config.json'
