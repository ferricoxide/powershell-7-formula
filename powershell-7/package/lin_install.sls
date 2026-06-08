# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

{%- if not powershell_7.pkg.download_uri %}
Activate Signing-Key for Installed Repo-def RPM:
  cmd.run:
    - name: |
        KEY_FILE=$(rpm -ql {{ powershell_7.pkg.name }} | grep '^/etc/pki/rpm-gpg/')
        if [ -n "$KEY_FILE" ]; then
          rpm --import "$KEY_FILE"
        fi
    - onlyif: |
        KEY_FILE=$(rpm -ql {{ powershell_7.pkg.name }} 2>/dev/null | grep '^/etc/pki/rpm-gpg/')
        [ -z "$KEY_FILE" ] && exit 1
        SIG_NAME=$(basename "$KEY_FILE" | sed -e 's/RPM-GPG-KEY-//i' -e 's/-prod//i')
        ! rpm -q gpg-pubkey --qf '%{SUMMARY}\n' | grep -qi "$SIG_NAME"
    - require:
      - pkg: 'Install Repository Definition'

Install Repository Definition:
  pkg.installed:
    - skip_verify: True
    - sources:
      - '{{ powershell_7.pkg.name }}': '{{ powershell_7.pkg.repository_uri }}'
{%- endif %}

