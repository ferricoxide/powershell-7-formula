# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

powershell-7-package-install-pkg-installed:
  pkg.installed:
    - name: {{ powershell_7.pkg.name }}
