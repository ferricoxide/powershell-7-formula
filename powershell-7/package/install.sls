# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}

include:
{%- if grains.kernel == "Linux" %}
  - powershell-7.package.lin_install
{%- elif grains.kernel == "Windows" %}
  - powershell-7.package.winrepo
  - powershell-7.package.win_install
{%- endif %}

Avoid being a null-router (package/install) - Powershell 7:
  test.nop: []
