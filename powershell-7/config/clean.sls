# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

include:
{%- if grains.kernel == "Linux" %}
  - postman-api.config.lin_clean
{%- elif grains.kernel == "Windows" %}
  - postman-api.config.win_clean
{%- endif %}

Avoid being a null-router (config/clean) - PowerShell 7:
  test.nop: []
