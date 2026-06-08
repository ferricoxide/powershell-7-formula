# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

{%- if not download_uri %}
Install Repository Definition:
  pkg.installed:
    - name: 'packages-microsoft-prod'
    - skip_verify: True
    - source: '{{ powershell_7.pkg.repository_uri }}'
{%- endif %}
