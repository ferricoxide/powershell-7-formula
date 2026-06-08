# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}

powershell-7-service-clean-service-dead:
  service.dead:
    - name: {{ powershell_7.service.name }}
    - enable: False
