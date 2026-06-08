# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

{%- if not powershell_7.pkg.download_uri %}
Install Repository Definition:
  pkg.installed:
    - skip_verify: True
    - sources:
      - '{{ powershell_7.pkg.name }}': '{{ powershell_7.pkg.repository_uri }}'
{%- endif %}

