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

- langs-Cleaner(-addons)

	- Scripts searches all IPFire language files for appropriate entries in IPFires Git environment.
	- If no entries has been found, it will echo it to files for each language which will be used to delete them from the respective language file.
	- A check will processed which checks for missing deletions.
	(-addons)
	- Searches also for strings in the IPFire addons and will do pretty much the same then the script above.

- 'company_blocker.sh' blocks companies via IPTables

	- Modfied version from an IPFire project --> https://forum.ipfire.org/viewtopic.php?f=6&t=18542. Thanks to Shellshock for his ideas.
	- This script uses ASNs to block companies.
	- User needs to edit the company name only to block it via IPFire firewall.local.
	- IPset will be used to create also vast lists of CIDRs.
	- Script uses only CIDRs no IPs.
	- Uninstaller is included.
	- Menu point to display all blocked sets are integrated

- 'nfsen-installer.sh' is a in- and uninstaller for Nfsen, Nfdump and fprobe for IPFire 32 and 64 bit systems which includes

	Initscript and Vhost for NFsen will be installed too incl. symlinks.
	- Nfsen installation takes place under /var/nfsen.
	- Nfsen listens per default on port 54321 TCP.
	- Installer will include green subnet for Allow from access.
	- Nfsen listens only on green0 interface.
	- Nfsen initscript checks for fprobes port and adjusts it if needed.
	fprobe will send to localhost via port 65432 all probes.
	- fprobe chroots to /var/empty.
	- fprobe uses no promiscuous mode.
	- fprobe grabs 'any' interfaces.
	- fprobe configuration can be made over /etc/rc.d/init.d/fprobe.

- ovpn_cert_expiration_check.sh checks certificates expiring dates and delivers alarm (defaut is) 5 days before it expires.

    - Days before can be defined in the "ALERT=5" variable.
    - An own Email account should be presant for this since the Email account password are stored in cleartext in the script.
    - Script provides Email encryption via GPG. An howto setup can be found in here --> http://wiki.ipfire.org/en/optimization/scripts/gpg/start .
    - Email function is currently commented to check the script functionality.
    - Email credentials needs to be set.
    - Clean up /tmp dir is currently commented to investigate file results.
    - Script can be placed into /etc/fcron.daily . All paths has been set absolute so the fcron environment should find all binaries.


