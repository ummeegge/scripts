Standalone scripts for IPFire
=================================

This scripts are developed on IPFire platforms which should work without installation of additional 3rd party software.

This repo contains currently:

- 'ipset_update.sh' is an example script to provide some individual blacklists to IPTables IPSet framework. Script serves the following possibilities:

	- automatic detection of the internal used addresses which will be excluded from the blacklists (e.g. 192.168 addresses if used)
	- adds and deletes also appropriate firewall rules in individual firewall script for CIDRs and IPs
	- creates hash:net or hash:ip tables
	- checks for installation
	- activates ip_set kernel module if not already done
	- downloads the defined lists and stripes/sorts IPs and CIDRs in different sets
	- writes counter lists if blacklisted addresses has been used
	- saves configuration and restores it after an reboot but flushes also before the IPset chains (fcron, cron ready).


- 'tmux-theme.sh' is a installer for tmux themes (currently only network theme). Script serves the following possibilities:

	- changes command line prompt if wanted, so current path and time will be displayed over the prompt and do not need to be displayed in tmux interface
	- serves a tmux configuration file under ~/.tmux.conf 
	- adds a theme for network overview which will install bwm-ng, iftop, iptraf-ng, mtr and tmux if not already install over IPFires packagemanager Pakfire
	- uninstaller is also integrated.

- 'netstat_formatted.sh' is a script that stats the current network state. Scripts checks the following:

	- how long the machine is up, how many users and CPU load
	- disk space and smart status
	- actual RAM resources
	- who is logged on
	- top ten RAM and CPU killer
	- statistics for device and partitions
	- netstats from different points of view
	- if used, list if OpenVPN routing and current OpenVPN clients
	- SSHd logins and denied login attempts
	- possible DDOS
	- Guardian logs if activated and not empty
	- syslog entries of tha last 50 lines.
