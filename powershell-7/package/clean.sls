# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

include:
  - {{ sls_config_clean }}
{%- if grains.kernel == "Linux" %}
  - powershell-7.package.lin_clean
{%- elif grains.kernel == "Windows" %}
  - powershell-7.package.win_clean
{%- endif %}

Avoid being a null-router (package/clean) - Powershell 7:
  test.nop: []
