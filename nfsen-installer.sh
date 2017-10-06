#!/bin/bash -

#
# NFsen, NFdump and Fprobe installer for IPFire systems.
# Initscript and Vhost for NFsen will be installed too.
#	- Nfsen installation takes place under /var/nfsen.
# 	- Nfsen listens per default on port 54321 TCP.
# 	- Installer will include green subnet for Allow from access.
#	- Nfsen listens only on green0 interface.
# Installer gives a choice between softflowd and fprobe as network traffic analyzer:
# softflowd will send per default to localhost via 65432 all probes.
#	- softflowd was compiled with enabled chroot to /var/empty.
#	- softflowd grabs 'any' interfaces.
#	- Reduces permissions to nobody.
# 	- softflowd configuration can be done over /etc/rc.d/init.d/softflowd.
# fprobe will send to localhost via port 65432 all probes.
#	- fprobe chroots to /var/empty.
#	- fprobe uses no promiscuous mode.
#	- fprobe grabs 'any' interfaces.
#	- fprobe configuration can be made over /etc/rc.d/init.d/fprobe.
#
# $author: ummeegge web de ; $date: 07.07.2017
######################################################################################
#

# Download address
URL="http://people.ipfire.org/~ummeegge/Netflow/nfdump-fprob-nfsen/v2";
PACKAGEA="nfsen_package-32bit-v2.tar.gz";
PACKAGEB="nfsen_package-64bit-v2.tar.gz";
SUMA="db35f7e6b45132d79181b0540d3f1f03318fd41390b06e60eb6faf91c06832d8";
SUMB="5fbb54cce88796824694c4f29e46d3dfcf75f401add981ceb35e6d7f9326376d";
## Packages
FP="fprobe-1.1-*bit-1.ipfire";
ND="nfdump-1.6.13-*bit-1.ipfire";
NS="nfsen-1.3.8_ipfire-patched.tar.gz";
PS="perl-Socket6-0.19-*bit-1.ipfire";
SF="softflowd-0.9.9-*-1.ipfire";
# Directories
INIT="/etc/rc.d/init.d";
INSTDIR="/opt/pakfire/tmp";
VHOST="/etc/httpd/conf/vhosts.d";

# Platform check
TYPE=$(uname -m | tail -c 3);
# Green subnet check
GREENSUBN=$(awk -F"=" '/GREEN_NETADDRESS/ { print $2 }' /var/ipfire/ethernet/settings);
GREENMASK=$(awk -F"=" '/GREEN_NETMASK/ { print $2 }' /var/ipfire/ethernet/settings);
GREENADRR=$(awk -F"=" '/GREEN_ADDRESS/ { print $2 }' /var/ipfire/ethernet/settings);


# Formatting and Colors
COLUMNS="$(tput cols)";
R=$(tput setaf 1);
B=$(tput setaf 6);
b=$(tput bold);
N=$(tput sgr0);
seperator(){ printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -; };
# Text
WELCOME="-- Welcome to Nfsen on IPFire installation --";
WELCOME1="- This script includes an in- and unstaller of Nfsen, Nfdump and Fprobe -";
STATEREPORT="- Process status of Nfsen installation -"

# Check for symlinks for Nfsen initscript
symlinkadd_function() {
	BIN="nfsen";
	# Possible runlevel ranges
	SO="[7-9][0-9]";
	SA="[3-5][0-9]";
	RE="[7-9][0-9]";
	# Search free runlevel
	STOP=$(ls /etc/rc.d/rc0.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SO}" | head -1);
	START=$(ls /etc/rc.d/rc3.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SA}" | head -1);
	REBOOT=$(ls /etc/rc.d/rc6.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${RE}" | head -1);
	## Add symlinks
	ln -s ../init.d/${BIN} /etc/rc.d/rc0.d/K${STOP}${BIN};
	ln -s ../init.d/${BIN} /etc/rc.d/rc3.d/S${START}${BIN};
	ln -s ../init.d/${BIN} /etc/rc.d/rc6.d/K${REBOOT}${BIN};
}

# Fprobe, softflowd and Nfsen symlink deletion function
symlinkdel_function(){
	# Nfsen 
	ls /etc/rc.d/rc?.d | grep 'nfsen' > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		rm -rfv /etc/rc.d/rc?.d/*nfsen;
	fi
	# Fprobe
	ls /etc/rc.d/rc?.d | grep 'fprobe' > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		rm -rfv /etc/rc.d/rc?.d/*fprobe;
	fi
	# softflowd
	ls /etc/rc.d/rc?.d | grep 'softflowd' > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		rm -rfv /etc/rc.d/rc?.d/*softflowd;
	fi
}

download_function() {
	# Check for 64 bit installation
	if [[ ${TYPE} = "64" ]]; then
		clear;
		read -p "To install the Nfsen installation now press [ENTER] , to quit use [CTRL-c]... ";
		cd /tmp || exit 1;
		# Check if package is already presant otherwise download it
		if [[ ! -e "${PACKAGEB}" ]]; then
			echo;
			curl -O ${URL}/${PACKAGEB};
		fi
		# Check SHA256 sum
		CHECK=$(sha256sum ${PACKAGEB} | awk '{print $1}');
		if [[ "${CHECK}" = "${SUMB}" ]]; then
			echo;
			echo -e "SHA2 sum is        ${B}${b}${CHECK}${N} is correct… ";
			echo "will go to further processing :-) ...";
			echo;
			sleep 3;
		else
			echo;
			echo -e "SHA2 sum should be ${R}${b}${SUMB}${N}";
			echo -e "SHA2 sum is        ${R}${b}${CHECK}${N} and is not correct… ";
			echo;
			echo -e "\033[1;31mShit happens :-( the SHA2 sum is incorrect, please report this here\033[0m";
			echo "--> https://forum.ipfire.org/viewtopic.php?f=50&t=19022";
			echo;
			exit 1;
		fi
		# Unpack package
		tar xvfz ${PACKAGEB};
	elif [[ ${TYPE} = "86" ]]; then
		# 32 bit installation
		clear;
		read -p "To install the Nfsen installation now press [ENTER] , to quit use [CTRL-c]... ";
		cd /tmp || exit 1;
		# Check if package is already presant otherwise download it
		if [[ ! -e "${PACKAGEA}" ]]; then
			echo;
			curl -O ${URL}/${PACKAGEA};
		fi
		# Check SHA256 sum
		CHECK=$(sha256sum ${PACKAGEA} | awk '{print $1}');
		if [[ "${CHECK}" = "${SUMA}" ]]; then
			echo;
			echo -e "SHA2 sum is        ${B}${b}${CHECK}${N} is correct… ";
			echo "will go to further processing :-) ...";
			echo;
			sleep 3;
		else
			echo;
			echo -e "SHA2 sum should be ${B}${b}${SUMA}${N}";
			echo -e "SHA2 sum is        ${R}${b}${CHECK}${N} and is not correct… ";
			echo;
			echo -e "\033[1;31mShit happens :-( the SHA2 sum is incorrect, please report this here\033[0m";
			echo "--> https://forum.ipfire.org/viewtopic.php?f=50&t=19022";
			echo;
			exit 1;
		fi
		# Unpack package
		tar xvfz ${PACKAGEA};
	else
		echo;
		echo "Sorry this platform is currently not supported, need to quit... ";
		echo;
fi
}

# Install function
install_function() {
	cd /tmp || exit 1;
	# Install initsctip
	cp -v nfsen-init.sh ${INIT}/nfsen;
	chmod 754 ${INIT}/nfsen;
	chown root:root ${INIT}/nfsen;
	symlinkdel_function;
	symlinkadd_function;
	# Install Nfsen Vhost configuration
	cp -v nfsen-vhost.conf ${VHOST}/nfsen.conf;
	chmod 644 ${VHOST}/nfsen.conf;
	chown root:root ${VHOST}/nfsen.conf;
	# Add green subnet and grenn IPFire ip for Nfsen vhost
	sed -i "s/VirtualHost.*:/VirtualHost\ ${GREENADRR}:/" ${VHOST}/nfsen.conf;
	sed -i "s/Require\ ip.*/Require\ ip\ ${GREENSUBN}\/${GREENMASK}/g" ${VHOST}/nfsen.conf;
	## Install all packages
	# Fprobe
	cp -v ${FP} ${INSTDIR};
	cd ${INSTDIR};
	tar xvf ${FP};
	./install.sh;
	cd /tmp;
	# Softflowd
	cp -v ${SF} ${INSTDIR};
	cd ${INSTDIR};
	tar xvf ${SF};
	./install.sh;
	cd /tmp;
	# Nfdump
	cp -v ${ND} ${INSTDIR};
	cd ${INSTDIR};
	tar xvf ${ND};
	./install.sh;
	cd /tmp;
	# Socket6
	cp -v ${PS} ${INSTDIR};
	cd ${INSTDIR};
	tar xvf ${PS};
	./install.sh;
	cd /tmp;
	# Install Nfsen
	tar xvfz ${NS};
	cd nfsen-1.3.8;
	./install.pl etc/nfsen.conf;
	/etc/init.d/apache restart;
	# Add Meta files
	touch /opt/pakfire/db/installed/meta-fprobe;
	touch /opt/pakfire/db/installed/meta-nfsen;
	touch /opt/pakfire/db/installed/meta-softflowd;
	# CleanUP
	echo "Clean up /tmp";
	rm -rf /opt/pakfire/tmp/* /tmp/${FP} /tmp/${ND} /tmp/${NS} /tmp/${PS} /tmp/${SF} /tmp/nfsen-init.sh /tmp/nfsen-vhost.conf /tmp/nfsen-1.3.8/;
}

delete_function() {
	rm -rvf \
	/etc/rc.d/init.d/fprobe \
	/usr/sbin/fprobe \
	/opt/pakfire/db/installed/meta-fprobe \
	/etc/rc.d/init.d/softflowd \
	/usr/sbin/softflowctl \
	/usr/sbin/softflowd \
	/opt/pakfire/db/installed/meta-softflowd \
	/opt/pakfire/db/installed/meta-nfsen \
	/usr/bin/ft2nfdump \
	/usr/bin/nfanon \
	/usr/bin/nfcapd \
	/usr/bin/nfdump \
	/usr/bin/nfexpire \
	/usr/bin/nfpcapd \
	/usr/bin/nfprofile \
	/usr/bin/nfreplay \
	/usr/bin/nftrack \
	/usr/bin/sfcapd \
	/var/netflow \
	/srv/web/nfsen \
	/var/nfsen \
	/etc/rc.d/init.d/fprobe \
	/etc/rc.d/init.d/nfsen \
	/etc/httpd/conf/vhosts.d/nfsen.conf \
	/var/log/httpd/nfsen-*.log \
	/usr/lib/perl5/site_perl/5.12.3/*/Socket6.pm \
	/usr/lib/perl5/site_perl/5.12.3/*/auto/Socket6;
	userdel netflow;
}

######################################## Installer Menu ##############################################
while true
do
	# Choose installation
	clear;
	echo ${N}
	seperator;
	printf "%*s\n" $(((${#WELCOME}+COLUMNS)/2)) "${WELCOME}";
	printf "%*s\n" $(((${#WELCOME1}+COLUMNS)/2)) "${WELCOME1}";
	seperator;
	echo;
	echo -e "    If you want to install Nfsen installation press      ${B}${b}'i'${N} and [ENTER] ";
	echo -e "    If you want to uninstall Nfsen installation press    ${B}${b}'u'${N} and [ENTER] ";
	echo;
	seperator;
	echo;
	echo -e "    To check the Nfsen status press                      ${B}${b}'p'${N} and [ENTER] ";
	echo -e "    To start Nfsen press                                 ${B}${b}'s'${N} and [ENTER] ";
	echo -e "    To stop Nfsen press                                  ${B}${b}'k'${N} and [ENTER] ";
	echo;
	seperator;
	echo -e "    If you want to quit this installation press          ${B}${b}'q'${N} and [ENTER]  ";
	seperator;
	echo;
	read choice
	clear;
	# Install Server
	case $choice in
		i*|I*)
			if [ ! -e /srv/web/nfsen ]; then
				download_function;
				install_function;
				printf "%b" "${B}${b}Which flow collector would you like to use? To use fprobe type '${R}${b}f-ENTER${N}' - ${B}${b}To use softflowd type '${R}${b}s -ENTER${N}'\n";
				read what;
				case $what in
					f*|F*)
						echo;
						echo "OK will use fprobe... ";
						echo;
						/etc/init.d/softflowd stop 2>/dev/null;
						rm -rf /etc/init.d/softflowd /usr/sbin/softflowctl /usr/sbin/softflowd;
						/etc/init.d/fprobe start 2>/dev/null;
						rm -rf /etc/rc.d/rc?.d/*softflowd;
					;;

					s*|S*)
						echo;
						echo "OK will use softflowd... ";
						echo;
						rm -rf /etc/init.d/fprobe /usr/sbin/fprobe;
						/etc/init.d/softflowd start 2>/dev/null;
						rm -rf /etc/rc.d/rc?.d/*fprobe;

					;;

					*)
						echo;
						echo "This option does not exist. Since we need one analyzer will activate neverthless softflowd then... ";
						/etc/init.d/fprobe stop 2>/dev/null;
						rm -rf /etc/init.d/fprobe /usr/sbin/fprobe;
						/etc/init.d/softflowd start 2>/dev/null;
						rm -rf /etc/rc.d/rc?.d/*fprobe;
						echo;
					;;

				esac
				/etc/init.d/nfsen start 2>/dev/null;
				echo "Installation is done, happy testing....";
				echo;
				seperator;
				echo "Your Nfsen webinterface is reachable over  ------------------ ${R}${b}https://${GREENADRR}:54321/nfsen.php${N} ." ;
				echo "You can reach Nfsen ONLY over ------------------------------- ${R}${b}${GREENSUBN}/${GREENMASK}${N} .";
				echo "and Nfsen is only listening on your green IPFire interface -- ${R}${b}${GREENADRR}${N} .";
				seperator;
				echo;
				echo "${b}Please be patient and wait some minutes that some data can be collected.${N}"
				echo "${b}The flow collector collects data from 'any' interfaces, to change this checkout the appropriate script under ${INIT}${N} ."
				echo;
				read -p "To go back to the menu press [ENTER]";
			else
				echo "Nfsen is already installed";
				sleep 2;
			fi
		;;

		u*|U*)
			if [ -e /srv/web/nfsen ]; then
				/etc/init.d/nfsen stop 2>/dev/null;
				if pgrep fprobe > /dev/null; then
					/etc/init.d/fprobe stop 2>/dev/null;
				fi
				if pgrep softflowd > /dev/null; then
					/etc/init.d/softflowd stop 2>/dev/null;
				fi
				#/var/nfsen/bin/nfsen stop;
				sleep 2;
				symlinkdel_function;
				delete_function;
				echo;
				echo "Uninstallation is done, thanks for testing... Goodbye.";
				sleep 2;
				kill $(pgrep nfsen);
			else
				echo;
				echo "Nfsen is NOT installed on this system... ";
				sleep 2;
			fi
		;;

		p*|P*)
			echo
			printf "%*s\n" $(((${#STATEREPORT}+COLUMNS)/2)) "${STATEREPORT}";
			if [ -e "${INIT}/nfsen" ]; then
				echo;
				seperator;
				if pgrep fprobe > /dev/null; then
					ps aux | grep -v grep | grep fprobe;
				fi
				if pgrep softflowd > /dev/null; then
					ps aux | grep -v grep | grep softflowd;
				fi
				echo;
				ps aux | grep -v grep | grep nfsen;
				echo;
				seperator;
				echo;
				read -p "To return to the menu press [ENTER]";
			else
				echo "No installation detected... ";
				sleep 2;
			fi
		;;

		s*|S*)
			if [ ! -e "${INIT}/nfsen" ]; then
				echo "No installation detected... ";
				sleep 2;
			else
				if ! pgrep nfsen > /dev/null; then
					if [ -e "${INIT}/fprobe" ]; then
						if ! pgrep fprobe > /dev/null; then
							echo "Will start Nfsen and the netflow tools... ";
							/etc/init.d/fprobe start 2>/dev/null;
							/etc/init.d/nfsen start 2>/dev/null;
							echo;
							seperator;
							ps aux | grep -v grep | grep fprobe;
							echo;
							ps aux | grep -v grep | grep nfsen;
							seperator;
							echo;
							read -p "To return to the menu press [ENTER]";
						else
							echo;
							echo "Process is already started";
							echo;
							sleep 2;
						fi
					else
						if [ -e "${INIT}/softflowd" ]; then
							if ! pgrep softflowd > /dev/null; then
								echo "Will start Nfsen and the netflow tools... ";
								/etc/init.d/softflowd start 2>/dev/null;
								/etc/init.d/nfsen start 2>/dev/null;
								echo;
								printf "%*s\n" $(((${#STATEREPORT}+COLUMNS)/2)) "${STATEREPORT}";
								seperator;
								ps aux | grep -v grep | grep softflowd;
								echo;
								ps aux | grep -v grep | grep nfsen;
								seperator;
								echo;
								read -p "To return to the menu press [ENTER]";
							else
								echo;
								echo "Process is already started... ";
								echo;
								sleep 2;
							fi
						fi
					fi
				else
					echo;
					echo "Nfsen is already running";
					echo;
					sleep 2;
				fi
			fi
		;;

		k*|K*)
			if [ -e "${INIT}/nfsen" ]; then
				if pgrep nfsen > /dev/null; then
					if pgrep fprobe > /dev/null; then
						echo "Will stop Nfsen and the netflow tools... ";
						/etc/init.d/nfsen stop 2>/dev/null;
						/etc/init.d/fprobe stop 2>/dev/null;
						echo;
						seperator;
						ps aux | grep -v grep | grep fprobe;
						echo;
						ps aux | grep -v grep | grep nfsen;
						seperator;
						echo;
						read -p "To return to the menu press [ENTER]";
					fi
					if pgrep softflowd > /dev/null; then
						echo "Will stop Nfsen and the netflow tools... ";
						/etc/init.d/nfsen stop 2>/dev/null;
						/etc/init.d/softflowd stop 2>/dev/null;
						echo;
						printf "%*s\n" $(((${#STATEREPORT}+COLUMNS)/2)) "${STATEREPORT}";
						seperator;
						ps aux | grep -v grep | grep softflowd;
						echo;
						ps aux | grep -v grep | grep nfsen;
						seperator;
						echo;
						read -p "To return to the menu press [ENTER]";
					fi
				else
					echo;
					echo "Nfsen is already stopped";
					echo;
					sleep 2;
				fi
			else
				echo "No installation detected... ";
				sleep 2;
			fi
		;;

		q*|Q*)
			echo;
			echo "Will quit. Goodbye... ";
			echo;
			exit 0;
		;;

		*)
			echo;
			echo "This Option does not exist... ";
			echo;
		;;
	esac
done

# EOF
