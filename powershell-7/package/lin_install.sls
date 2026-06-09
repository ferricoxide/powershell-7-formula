# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set config_map = powershell_7.get('config') or {} %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}
{%- set os_major = salt['grains.get']('osmajorrelease', '9') %}
{%- set default_repo_uri = (
      'https://packages.microsoft.com/config/rhel/' ~
      os_major ~ '/packages-microsoft-prod.rpm'
    )
%}
{%- set repo_rpm_name = config_map.get('repo_rpm_name') |
      default('packages-microsoft-prod', true)
%}
{%- set repo_rpm_uri = config_map.get('repo_rpm_uri') |
      default(default_repo_uri, true)
%}
{%- set base_root = pkg_map.get('install_root') |
      default('/opt/microsoft/powershell/7', true)
%}
{%- set powershell_download_uri = pkg_map.get('download_uri', '') %}
{%- set powershell_package_name = pkg_map.get('name') |
      default('powershell', true)
%}

{%- if powershell_download_uri and not
    powershell_download_uri.endswith('.rpm') %}
{%- set path_accumulator = [] %}

Ensure Executable Permission on Core Binaries:
  file.managed:
    - mode: 755
    - name: '{{ base_root }}/pwsh'
    - replace: False
    - require:
      - file: 'Ensure Global Read Permissions on Binaries'

Ensure Global Read Permissions on Binaries:
  file.directory:
    - dir_mode: 755
    - file_mode: 644
    - name: '{{ base_root }}'
    - recurse:
      - mode
    - require:
      - archive: 'Extract Powershell from Archive'

  {%- for path_segment in base_root.split('/') if path_segment %}
    {%- do path_accumulator.append(path_segment) %}
    {%- set current_parent_dir = '/' ~ path_accumulator | join('/') %}
    {%- if current_parent_dir != base_root %}
Ensure Parent Directory Permissions for {{ current_parent_dir }}:
  file.directory:
    - dir_mode: 755
    - name: '{{ current_parent_dir }}'
    - require_in:
      - archive: 'Extract Powershell from Archive'
    {%- endif %}
  {%- endfor %}

Extract Powershell from Archive:
  archive.extracted:
    - archive_format: 'tar'
    - enforce_toplevel: False
    - group: 'root'
    - keep_source: False
    - name: '{{ base_root }}'
    {%- if not pkg_map.get('download_sig') %}
    - skip_verify: True
    {%- endif %}
    - source: '{{ powershell_download_uri }}'
    {%- if pkg_map.get('download_sig') %}
    - source_hash: '{{ pkg_map.get('download_sig') }}'
    {%- endif %}
    - user: 'root'

Install PowerShell Dependencies:
  pkg.installed:
    - name: 'libicu'

Install PowerShell to Userland:
  file.symlink:
    - force: True
    - name: /usr/local/bin/pwsh
    - require:
      - file: 'Ensure Executable Permission on Core Binaries'
      - pkg: 'Install PowerShell Dependencies'
    - target: '{{ base_root }}/pwsh'

{%- else %}

  {%- if not powershell_download_uri %}
Activate Signing-Key for Installed Repo-def RPM:
  cmd.run:
    - name: |
        KEY_FILE=$(
          rpm -ql {{ repo_rpm_name }} | grep '^/etc/pki/rpm-gpg/'
        )
        if [[ -n "$KEY_FILE" ]]
        then
          rpm --import "$KEY_FILE"
        fi
    - onlyif: |
        KEY_FILE=$(
          rpm -ql {{ repo_rpm_name }} 2>/dev/null \
            | grep '^/etc/pki/rpm-gpg/'
        )
        [[ -z "$KEY_FILE" ]] && exit 1
        SIG_NAME=$(
          basename "$KEY_FILE" \
            | sed -e 's/RPM-GPG-KEY-//i' -e 's/-prod//i'
        )
        !
        rpm -q gpg-pubkey --qf '%{SUMMARY}\n' \
          | grep -qi "$SIG_NAME"
    - require:
      - pkg: 'Install Repo-def RPM'
  {%- endif %}

Install PowerShell to Userland:
  pkg.installed:
    {%- if powershell_download_uri %}
    - skip_verify: True
    - sources:
      - '{{ powershell_package_name }}': '{{ powershell_download_uri }}'
    {%- else %}
    - name: '{{ powershell_package_name }}'
    - pkg_verify: True
    - require:
      - cmd: 'Activate Signing-Key for Installed Repo-def RPM'
    {%- endif %}

  {%- if not powershell_download_uri %}
Install Repo-def RPM:
  pkg.installed:
    - skip_verify: True
    - sources:
      - '{{ repo_rpm_name }}': '{{ repo_rpm_uri }}'
  {%- endif %}

{%- endif %}
