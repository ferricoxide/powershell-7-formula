# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

powershell-7-config-file-file-managed:
  file.managed:
    - name: {{ powershell_7.config }}
    - source: {{ files_switch(['example.tmpl'],
                              lookup='powershell-7-config-file-file-managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: {{ powershell_7.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        powershell_7: {{ powershell_7 | json }}
