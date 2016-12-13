#!/bin/bash -

# 
# Script checks netstat of IPFire systems.
#
# $author: ummeegge & 5p9 ; $date: 29.03.13
#############################################
# Modified by ummeegge $date: 09.12.2016
 
# logs and infos
MESSAGES="/var/log/messages";
GUARDIAN="/var/log/guardian/guardian.log";
OVPN="/var/log/openvpn/ovpnserver.log";
PROFILE="/var/ipfire/fireinfo/profile"

# SSH, Guardian and ovpn variablen
ACCEPT="$(awk '/sshd/ && /Accepted/' ${MESSAGES})";
DENY="$(awk '/sshd/ && /Failed/' ${MESSAGES})";
GUARDLOG="$(tail -50 ${GUARDIAN})";
# Date and host infos
DATE="$(date)";
MACHINE="$(hostname)";
OS="$(awk -F'"' '/"release":/ { print $4 }' "${PROFILE}")";
IP="$(curl -s ipecho.net/plain; echo)";
STATS="State from: ${DATE} - from host with IP:${IP} - named: ${MACHINE} - with OS: ${OS}";
# Text and formatting functions
COLUMNS="$(tput cols)";

# Seperator functions
seperatorA(){ printf -v _hr "%*s" ${COLUMNS} && echo ${_hr// /${1-=}}; }
seperatorB(){ printf -v _hr "%*s" ${COLUMNS} && echo ${_hr// /${1-_}}; }
seperatorC(){ printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -; }

TITEL="IPFIRE SYSTEM INFORMATION SKRIPT";
UPTIME="Time, active time, how many users, CPU Load:";
DISK="Whats going on with my HDD:";
SMART="What says SMART ?:";
RAM="The RAM needs actual the following resources:";
LOGON="Who is logged on and what the hell he is doing there:";
TOPTENRAM="Top 10 RAM killer:";
TOPTENCPU="Top 10 CPU killer:";
IOSTAT="I/O CPU statistics for device and partition:";
NSTAT="NETSTAT SECTION";
NSTATCONPORTS="Which ports are open - which connections are up:";
LSOFAGAIN="IPv4 check with lsof:";
SSAGAIN="UDP und TCP check with ss:";
OVPNIFACE="OpenVPN Interfaces check:";
OVPNCLIENT="Actual Roadwarrior connections:";
SSHCHECK="SSH Login check:";
DDOS="DDos or not ?:";
GUARDIANLOG="What says guardian.log ?:"
LOG="What says /var/log/messages ?:";

# Main part
seperatorA;
echo;
seperatorB;
echo;
printf "%*s\n" $(((${#TITEL}+$COLUMNS)/2)) "${TITEL}";
echo;
printf "%*s\n" $(((${#STATS}+$COLUMNS)/2)) "${STATS}";
seperatorC;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#UPTIME}+$COLUMNS)/2)) "${UPTIME}";
seperatorC;
echo;
uptime;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#DISK}+$COLUMNS)/2)) "${DISK}";
seperatorC;
echo;
df -h;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#SMART}+$COLUMNS)/2)) "${SMART}";
seperatorC;
echo;
smartctl -A /dev/sda;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#RAM}+$COLUMNS)/2)) "${RAM}";
seperatorC;
echo;
free;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#LOGON}+$COLUMNS)/2)) "${LOGON}";
seperatorC;
echo;
w;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#TOPTENRAM}+$COLUMNS)/2)) "${TOPTENRAM}";
seperatorC;
echo;
ps auxf | sort -r -k 4 | head -10;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#TOPTENCPU}+$COLUMNS)/2)) "${TOPTENCPU}";
seperatorC;
echo;
ps auxf | sort -r -k 4 | head -10;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#IOSTAT}+$COLUMNS)/2)) "${IOSTAT}";
seperatorC;
echo;
iostat;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#NSTAT}+$COLUMNS)/2)) "${NSTAT}";
seperatorC;
echo;
netstat -tulpn;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#NSTATCONPORTS}+$COLUMNS)/2)) "${NSTATCONPORTS}";
seperatorC;
echo;
netstat -antpuew;
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#LSOFAGAIN}+$COLUMNS)/2)) "${LSOFAGAIN}";
seperatorC;
echo;
lsof -i -n | egrep 'COMMAND|LISTEN';
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#SSAGAIN}+$COLUMNS)/2)) "${SSAGAIN}";
seperatorC;
echo;
ss -u -a;
echo;
echo;

if [ -n "$(pgrep openvpn)" ]; then
	seperatorB;
	echo;
	printf "%*s\n" $(((${#OVPNIFACE}+$COLUMNS)/2)) "${OVPNIFACE}";
	seperatorC;
	echo;
	netstat -r | grep tun;
	echo;
	echo;

	seperatorB;
	echo;
	printf "%*s\n" $(((${#OVPNCLIENT}+$COLUMNS)/2)) "${OVPNCLIENT}";
	seperatorC;
	echo;
	cat ${OVPN};
	echo;
	echo;
fi

if [ -n "$(pgrep sshd)" ]; then
	seperatorB;
	echo;
	printf "%*s\n" $(((${#SSHCHECK}+$COLUMNS)/2)) "${SSHCHECK}";
	seperatorC;
	echo;
	# accepted SSH Logins
	if [ -n "${ACCEPT}" ]; then
		echo;
		echo "SSH got the following logins:"
		echo;
		awk '/sshd/ && /Accepted/' "${MESSAGES}";
		echo;
	else
		echo "There where no logins:"
	fi
	# Failed SSH logins
	if [ -n "${DENY}" ]; then
		echo;
		echo "The following SSH logins where incorrect:";
		echo;
		awk '/sshd/ && /Failed/' "${MESSAGES}";
		echo;
	else
		echo "There where no incorrect logins:";
	fi	
fi

seperatorB;
echo;
printf "%*s\n" $(((${#DDOS}+$COLUMNS)/2)) "${DDOS}";
seperatorC;
echo;
echo "Check ESTABLISHED connections and connections count"
netstat -ntu | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr;
echo;
echo "Count numbers of connections for each IP";
netstat -ntu | awk '{print $5}' | tail -n +3 | cut -d: -f1 | sort | uniq -c | sort -n
echo;
echo;

if [ -n $(pgrep guardian) ]; then
	seperatorB;
	echo;
	printf "%*s\n" $(((${#GUARDIANLOG}+$COLUMNS)/2)) "${GUARDIANLOG}";
	seperatorC;
	echo;
	# Guardian logs
	if [ -n ${GUARDIAN} ]; then
		echo;
		echo "Guardian got the following IP entries."
		echo;
		tail -50 ${GUARDIAN};
		echo;
	else
		echo "Guardian have no entries."
	fi
fi

seperatorB;
echo;
printf "%*s\n" $(((${#LOG}+$COLUMNS)/2)) "${LOG}";
seperatorC;
echo;
tail -50 ${MESSAGES};
echo;
echo;

seperatorB;
echo;
printf "%*s\n" $(((${#STATS}+$COLUMNS)/2)) "${STATS}";
seperatorB;
echo;
seperatorA;


# End script
