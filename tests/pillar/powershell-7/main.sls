postman-api:
  lookup:
    {%- if grains.os_family == "RedHat" %}
    pkg:
      download_uri: 'https://github.com/PowerShell/PowerShell/releases/download/v7.6.2/powershell-7.6.2-1.rh.x86_64.rpm'
      install_root: '/apps/microsoft/powershell/7.6.2'
    config:
      install_root: ''
    {%- elif grains.os_family == "Windows" %}
    {%- endif %}
