# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set config_map = powershell_7.get('config') or {} %}
{%- set theme_map = config_map.get('theme') or {} %}

# Extract configuration values directly from the combined map stack
{%- set base_root = pkg_map.get('install_root') |
        default('C:/Program Files/PowerShell/7', true) %}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set is_zip = powershell_download_uri.endswith('.zip') %}

# Extract individual theme configurations from the parameters dictionary object
{%- set bg_color = theme_map.get('bg_color', '') %}
{%- set fg_color = theme_map.get('fg_color', '') %}
{%- set greeting = theme_map.get('greeting', '') %}
{%- set prefix = theme_map.get('prefix', '') %}

{%- set has_theme = bg_color or fg_color or greeting or prefix %}

# Standardize path environments to keep lines safely under 80 columns
{%- set target_binary = base_root ~ '/pwsh.exe' %}
{%- set public_desktop = 'C:/Users/Public/Desktop' %}
{%- set public_start_menu =
        'C:/ProgramData/Microsoft/Windows/Start Menu/Programs' %}

Ensure Global Profile Directory Exists:
  file.directory:
    - makedirs: True
    - name: '{{ base_root }}'

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

{%- if has_theme %}
  {%- set profile_content = [] %}
  {%- set comment_str = '# Managed by SaltStack - ' ~
          'Corporate Theme Customization' %}
  {%- do profile_content.append(comment_str) %}
  {%- if greeting %}
    {%- set greeting_cmd = 'Write-Host "' ~ greeting ~ '"' %}
    {%- if fg_color %}
      {%- set greeting_cmd = greeting_cmd ~
              ' -ForegroundColor ' ~ fg_color %}
    {%- endif %}
    {%- if bg_color %}
      {%- set greeting_cmd = greeting_cmd ~
              ' -BackgroundColor ' ~ bg_color %}
    {%- endif %}
    {%- do profile_content.append(greeting_cmd) %}
  {%- endif %}
  {%- if prefix or fg_color or bg_color %}
    {%- do profile_content.append('') %}
    {%- do profile_content.append('function prompt {') %}
    {%- if prefix %}
      {%- set prompt_cmd = '    Write-Host "' ~ prefix ~ ' " -NoNewline' %}
      {%- if fg_color %}
        {%- set prompt_cmd = prompt_cmd ~
                ' -ForegroundColor ' ~ fg_color %}
      {%- endif %}
      {%- if bg_color %}
        {%- set prompt_cmd = prompt_cmd ~
                ' -BackgroundColor ' ~ bg_color %}
      {%- endif %}
      {%- do profile_content.append(prompt_cmd) %}
    {%- endif %}
    {%- do profile_content.append('    Write-Host (Get-Location) -NoNewline') %}
    {%- do profile_content.append('    return "> "') %}
    {%- do profile_content.append('}') %}
  {%- endif %}

Manage Global Enterprise Powershell Profile Script:
  file.managed:
    - contents: |
{{ profile_content | join('\n') | indent(8, true) }}
    - makedirs: True
    - name: '{{ base_root }}/Microsoft.PowerShell_profile.ps1'
    - require:
      - file: 'Ensure Global Profile Directory Exists'

{%- endif %}

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
