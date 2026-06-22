# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set map_src = tplroot ~ "/map.jinja" %}
{%- from map_src import mapdata as powershell_7 with context %}
{%- set config_map = powershell_7.get('config') or {} %}

# Retrieve initial policy directive from parameter stack
{%- set enforce_hardening = config_map.get('enforce_hardening', true) %}

{%- if enforce_hardening %}
  # Query the highstate configuration top file definitions
  {%- set top_data = salt['state.show_top']() or {} %}
  {%- set assigned_states = [] %}
  {%- for environment, states in top_data.items() %}
    {%- do assigned_states.extend(states) %}
  {%- endfor %}

  # Evaluate the presence of targeted formulas in the top file blueprint
  {%- set ash_windows_in_top = false %}
  {%- for state in assigned_states %}
    {%- if state.startswith('ash-windows') %}
      {%- set ash_windows_in_top = true %}
    {%- endif %}
  {%- endfor %}

  # Inspect runtime context options to distinguish run types
  {%- set current_fun = opts.get('fun', '') %}
  {%- set current_args = opts.get('arg', []) %}

  # Identify if this transaction is a full, un-targeted highstate apply
  {%- set is_highstate_run = (current_fun == 'state.highstate') or
          (current_fun == 'state.apply' and not current_args) %}

  # Execute context-aware business logic routing
  {%- if ash_windows_in_top and is_highstate_run %}
    # Disable internal hardening if ash-windows runs concurrently
    {%- set enforce_hardening = false %}
  {%- else %}
    # Enable standalone hardening if powershell-7 is run individually
    {%- set enforce_hardening = true %}
  {%- endif %}
{%- endif %}

include:
  - {{ sls_package_install }}
{%- if grains.kernel == "Linux" %}
  - powershell-7.config.lin_file
{%- elif grains.kernel == "Windows" %}
  - powershell-7.config.win_file
  {%- if enforce_hardening %}
  - powershell-7.config.win_harden
  {%- endif %}
{%- endif %}

Avoid Being A Null Router Config File:
  test.nop: []
