#!/bin/bash -
 
#
# Update script example for blacklist update in IPset for IPFire platform.
# Includes FW rule integration,  configuration entries, and restore command for system restart.
# Investigates internal used addresses with automatic exclusion in the blacklists to
# prevent potential address conflicts.
# $author: ummeegge ; $date 01.01.2016
#######################################################################################################
#

## Locations
CONFDIR="/etc/ipset";
CONF="${CONFDIR}/ipset.conf";
COUNTER="${CONFDIR}/counterlist_ipset";
IPSET="/usr/sbin/ipset";
DIR="/tmp/ipset";
DWNLOG="/tmp/ipset/dwnload.log";
CIDRLIST="${DIR}/CIDRLIST";
IPLIST="${DIR}/IPLIST";
SETCIDR="cidrlist";
SETIP="iplist";
FWL="/etc/sysconfig/firewall.local";
SET="/var/ipfire/ethernet/settings";
OVPNSUB="/var/ipfire/ovpn/server.conf";
RC="/etc/sysconfig/rc.local";

#----------------------------------------------------------------------------------------------------------------

## Investigate system addresses to prevent potential blocks
# LAN, WLAN, DMZ, DNS and OpenVPN addresses
USEDADDRESSES=$(awk -F'=' '/GREEN_ADDRESS/ || /BLUE_ADDRESS/ || /RED_ADDRESS/ || /ORANGE_ADDRESS/ { print $2 }' \
${SET} | cut -d'.' -f1,2 && \
awk -F'=' '/DNS1=/ || /DNS2=/ { print $2 }' ${SET} && \
awk '/server / || /route / { print $2 }' ${OVPNSUB} | sed 's/.0$//g')
OWNAD=$(echo "${USEDADDRESSES}" | tr ' ' '\n' | sort -nu);

## FW functions
# Searcher
# Start
STARTFW=$(grep "\${IPSET}" ${FWL} | echo $?);
# Stop
STOPFW=$(grep "\${IPSET}" ${FWL} | echo $?);

fwadd_funct() {
  if [ "${STARTFW}" -eq 0 ]; then
   sed -i '/# Used for private firewall rules/ a\IPSET="\/sbin\/iptables"' ${FWL};
   sed -i "/## add your 'start' rules here/ a\ \
       # IPSET FW entries in start\n \
       # IPSET add rules for CIDR list\n \
       \${IPSET} -I CUSTOMFORWARD -m set --match-set ${SETCIDR} dst -j REJECT\n \
       \${IPSET} -I CUSTOMINPUT -m set --match-set ${SETCIDR} src -j REJECT\n \
       \${IPSET} -I CUSTOMOUTPUT -m set --match-set ${SETCIDR} dst -j REJECT\n \
       # IPSET rules for ip list\n \
       \${IPSET} -I CUSTOMFORWARD -m set --match-set ${SETIP} dst -j REJECT\n \
       \${IPSET} -I CUSTOMINPUT -m set --match-set ${SETIP} src -j REJECT\n \
       \${IPSET} -I CUSTOMOUTPUT -m set --match-set ${SETIP} dst -j REJECT" ${FWL};
       # Add stop rules
   sed -i "/## add your 'stop' rules here/ a\ \
       # IPSET flushing related chains\n \
       \${IPSET} -F CUSTOMFORWARD\n \
       \${IPSET} -F CUSTOMINPUT\n \
       \${IPSET} -F CUSTOMOUTPUT" ${FWL};
  fi
}

fwstop_funct() {
  if [ "${STOPFW}" -eq 0 ]; then
   # Delete IPset related entries
   sed -i -e "/\${IPSET}.*/d" -e "/# IPSET.*/d" -e "/IPSET.*/d" ${FWL};
  fi
}

#----------------------------------------------------------------------------------------------------------------

# Check for installation
if [[ ! -e "${IPSET}" ]]; then
   echo "Haven´t found an IPset installation on this system, need to quit... ";
   exit 1;
fi

# Create appropriate sets with counter if not already done
if [[ -z "$(ipset -n list | grep ${SETCIDR})" ]]; then
   ipset create ${SETCIDR} hash:net counters;
fi
if [[ -z "$(ipset -n list | grep ${SETIP})" ]]; then
   ipset create ${SETIP} hash:ip counters;
fi

## Check for file, rc.local entry, dirs and module
if [[ ! -d "${CONFDIR}" ]]; then
   mkdir ${CONFDIR};
elif [[ ! -e "${COUNTER}" ]]; then
   touch ${COUNTER};
elif [[ -z "$(lsmod | grep ip_set)" ]]; then
   modprobe ip_set;
elif [[ -z "$(grep 'ipset' ${RC})" ]]; then
      echo "${IPSET} restore < ${CONF} && /etc/sysconfig/firewall.local reload;" >> ${RC};
fi

#----------------------------------------------------------------------------------------------------------------

## Blacklist addresses
URLS="https://rules.emergingthreats.net/blockrules/emerging-botcc.rules \
https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1 \
https://danger.rulez.sk/projects/bruteforceblocker/blist.php \
https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist \
https://zeustracker.abuse.ch/blocklist.php?download=squidip \
https://www.spamhaus.org/drop/drop.lasso \
http://cinsscore.com/list/ci-badguys.txt \
https://www.openbl.org/lists/base.txt \
https://autoshun.org/files/shunlist.csv \
https://lists.blocklist.de/lists/all.txt \
https://feeds.dshield.org/top10-2.txt \
https://palevotracker.abuse.ch/blocklists.php?download=ipblocklist \
https://zeustracker.abuse.ch/blocklist.php?download=badips";

#----------------------------------------------------------------------------------------------------------------
# Start processing

# Check if entries exist
if [[ -n "$(ipset list | tail -1)" ]]; then
   # Prepare firewall.local
   fwstop_funct;
   ${FWL} reload;
   # Write to counter list before flushing the sets if packet counter ! 0
   if [[ -n $(ipset list | sed -e '/packets 0/d' -e '/^[^0-9]/d' -e '/^$/d') ]]; then
       echo -e "\e[31m$(date)\e[0m" >> ${COUNTER} \
       && ipset list | sed -e '/packets 0/d' -e '/^[^0-9]/d' -e '/^$/d' >> ${COUNTER};
   else
       echo -e "\e[31m$(date)\e[0m" >> ${COUNTER};
       echo "No entries today" >> ${COUNTER};
   fi
   # Flushing existing sets
   ipset flush ${SETCIDR};
   ipset flush ${SETIP};
fi

# Check for installation directory
if [ -d "${DIR}" ]; then
   rm -rf ${DIR};
   mkdir ${DIR};
else
   mkdir ${DIR};
fi

#################################################################################################################
# Donwload and process list(s)
cd ${DIR} || exit 1;
wget -S -N -t 3 -T 10 -o "${DWNLOG}" ${URLS} --no-check-certificate;
############################################ Get all IPs ########################################################
# grep IPs and sort and make them uniq
cat * | \
grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -nu > ${IPLIST};
########################################### Get all CIDRs #######################################################
# grep CIDRs and sort and make them uniq
cat * | \
grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}/[0-9]{1,2}" | \
sort -nu > ${CIDRLIST}
#################################################################################################################
# Clean up and sort LAN, WLAN, DNS and OpenVPN addresses out
sed -i -e 's/^M//g' -e '/#/d' -e '/0.0.0.0.*/d' ${CIDRLIST} ${IPLIST};
for i in ${OWNAD}; do
    sed -i "/${i}/d" ${CIDRLIST} ${IPLIST};
done

# Introduce new content to IPset and add downloaded lists if needed
for l in $(cat ${CIDRLIST}); do ipset --add ${SETCIDR} "${l}"; done;
for l in $(cat ${IPLIST}); do ipset --add ${SETIP} "${l}"; done;
# Save the new lists
ipset save > ${CONF};
logger -t ipset "IPset: has updated blacklist";

fwadd_funct;
${FWL} reload;

exit 0

# End script
