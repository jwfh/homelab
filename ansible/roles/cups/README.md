# CUPS Role

This Ansible role installs and configures a CUPS print server with Samba and AirPrint support.

## Features

- CUPS print server configuration
- Windows printer sharing via Samba
- iOS/macOS printer sharing via AirPrint
- Configurable printer settings via Ansible variables

## Requirements

- FreeBSD 12.0 or higher
- Ansible 2.9 or higher

### FreeBSD-specific Notes

This role is configured specifically for FreeBSD systems and uses:
- FreeBSD package names (cups, samba413, avahi-app, py39-cups)
- FreeBSD-specific paths (/usr/local/etc/cups/, /usr/local/etc/smb4.conf)
- FreeBSD service management via rc.conf
- FreeBSD group naming (wheel instead of root)

## Role Variables

All variables are defined in `defaults/main.yml`. Here are the key variables:

```yaml
cups_port: 631                      # CUPS server port
cups_interface: "*:631"             # Interface to listen on
cups_admin_group: lpadmin          # Admin group for CUPS
cups_allow_remote: true            # Allow remote access

# Samba configuration
cups_samba_workgroup: WORKGROUP
cups_samba_server_string: "CUPS Print Server"

# Define printers
cups_printers:
  - name: Office_Printer           # Printer name
    description: "Main Office Printer"
    uri: "ipp://192.168.1.100"    # Printer URI
    location: "Main Office"        # Physical location
    driver: "everywhere"          # Driver (using IPP everywhere)
    shared: true                  # Share the printer
    enabled: true                 # Enable the printer
    airprint: true               # Enable AirPrint
    options:                     # Printer-specific options
      media: A4
      sides: two-sided-long-edge
```

## Example Playbook

```yaml
- hosts: print_servers
  roles:
    - role: cups
      vars:
        cups_printers:
          - name: HP_LaserJet
            description: "HP LaserJet Pro"
            uri: "ipp://192.168.1.100"
            location: "Office"
            shared: true
            enabled: true
            airprint: true
```

## License

MIT
