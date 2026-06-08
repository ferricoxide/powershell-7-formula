# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set repo_rpm_name = powershell_7.config.repo_rpm_name %}
{%- set repo_rpm_uri = powershell_7.config.repo_rpm_uri %}

{%- if not powershell_7.pkg.download_uri %}
Activate Signing-Key for Installed Repo-def RPM:
  cmd.run:
    - name: |
        KEY_FILE=$(
          rpm -ql {{ repo_rpm_name }} | grep '^/etc/pki/rpm-gpg/'
        )
        if [ -n "$KEY_FILE" ]; then
          rpm --import "$KEY_FILE"
        fi
    - onlyif: |
        KEY_FILE=$(
          rpm -ql {{ repo_rpm_name }} 2>/dev/null | grep '^/etc/pki/rpm-gpg/'
        )
        [ -z "$KEY_FILE" ] && exit 1
        SIG_NAME=$(
          basename "$KEY_FILE" | sed -e 's/RPM-GPG-KEY-//i' -e 's/-prod//i'
        )
        ! rpm -q gpg-pubkey --qf '%{SUMMARY}\n' | grep -qi "$SIG_NAME"
    - require:
      - pkg: 'Install Repo-def RPM'

Install Powershell RPM:
  pkg.installed:
    - name: '{{ powershell_7.pkg.name }}'
    - pkg_verify: True
    - require:
      - cmd: 'Activate Signing-Key for Installed Repo-def RPM'

Install Repo-def RPM:
  pkg.installed:
    - skip_verify: True
    - sources:
      - '{{ repo_rpm_name }}': '{{ repo_rpm_uri }}'
{%- elif not powershell_7.pkg.download_uri.endswith('.rpm') %}
Extract Powershell from Archive:
  archive.extracted:
    - archive_format: 'tar'
    - enforce_toplevel: False
    - group: 'root'
    - keep_source: False
    - name: '{{ powershell_7.pkg.install_root }}'
    {%- if not powershell_7.pkg.download_sig %}
    - skip_verify: True
    {%- else %}
    - source_hash: '{{ powershell_7.pkg.download_sig }}'
    {%- endif %}
    - source: '{{ powershell_7.pkg.download_uri }}'
    - user: 'root'
{%- elif powershell_7.pkg.download_uri.endswith('.rpm') %}
NO-OP Message:
  test.show_notification:
    - text: |-
        ---------------------------------------------
        TBD: logic for installing from a self-hosted
        RPM that has no associated repository-
        definition file
        ---------------------------------------------
{%- endif %}
