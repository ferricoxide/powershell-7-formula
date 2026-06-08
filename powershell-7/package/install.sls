# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

include:
{%- if grains.kernel == "Linux" %}
  - postman-api.package.lin_install
{%- elif grains.kernel == "Windows" %}
  - postman-api.package.win_install
{%- endif %}

Avoid being a null-router (package/install) - Powershell 7:
  test.nop: []
