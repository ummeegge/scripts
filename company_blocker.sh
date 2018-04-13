#!/bin/bash -

#
# Modfied version from an IPFire project --> https://forum.ipfire.org/viewtopic.php?f=6&t=18542
# Thanks to Shellshock for his ideas.
#
# This script uses ASNs to block companies.
# User needs to edit the company name only to block it via IPFire firewall.local.
# IPset will be used to create also vast lists of CIDRs.
# Script uses only CIDRs no IPs.
# Uninstaller is included.
# Menu point to display all blocked sets are integrated.
#
# Modified by: ummeegge ; $date: 02.06.2017
################################################################################################
#


RAWAD="/tmp/address_pool";
SORTAD="/tmp/address_sorted";
ASN="/tmp/asn";
COMPANIES="/tmp/company_names";
# IPSet vars
SETCIDR="companies";
IPSETDIR="/etc/ipset";
CONF="${IPSETDIR}/ipset.conf";
COMPANYDIR="${IPSETDIR}/companyset_info";
COMPANYNAME="${COMPANYDIR}/company_names";
FWL="/etc/sysconfig/firewall.local";
RC="/etc/sysconfig/rc.local";

# Formattings and menu stuff
COLUMNS="$(tput cols)";
R=$(tput setaf 1);
B=$(tput setaf 6);
b=$(tput bold);
N=$(tput sgr0);
seperator(){ printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -; };
WELCOME="- Welcome to company block and unblocker -";

## FW functions
# firewall.local add rules
fwadd_funct() {
   sed -i '/# Used for private firewall rules/ a\IPSETCOMPANY="\/sbin\/iptables"' ${FWL};
   sed -i "/start)/ a\ \
       # --> Automatic generated IPSET COMPANY FW entries in start section BEGIN\n \
       \${IPSETCOMPANY} -I CUSTOMFORWARD -m set --match-set ${SETCIDR} dst -j REJECT\n \
       \${IPSETCOMPANY} -I CUSTOMOUTPUT -m set --match-set ${SETCIDR} dst -j REJECT\n \
       # --> Automatic generated IPSET COMPANY FW entries in start section END" ${FWL};
       # Add stop rules
   sed -i "/stop)/ a\ \
       # --> Automatic generated IPSET COMPANY FW entries in stop section BEGIN\n \
       \${IPSETCOMPANY} -F CUSTOMFORWARD\n \
       \${IPSETCOMPANY} -F CUSTOMOUTPUT\n \
       # --> Automatic generated IPSET COMPANY FW entries in stop section END" ${FWL};
}

# firewall.local delete rules
fwdel_funct() {
   sed -i -e "/\${IPSETCOMPANY}.*/d" -e "/IPSETCOMPANY.*/d" -e "/# --> Automatic generated IPSET COMPANY FW.*/d" ${FWL};
}

# Add info if companies are blocked



## Menu
while true; do
  CURRENTCOMPS=$(if [ -e "${COMPANYNAME}" ]; then tr '\n' ' ' < ${COMPANYNAME}; else echo "No companies are blocked"; fi);
  clear;
  echo ${N};
  clear;
  seperator;
  printf "%*s\n" $(((${#WELCOME}+COLUMNS)/2)) "${WELCOME}";
  seperator;
  echo;
  echo -e "    To block companies Use            ${B}${b}'a'${N} and [ENTER] ";
  echo -e "    To unblock all companies use      ${B}${b}'d'${N} and [ENTER] ";
  echo -e "    To list all added networks use    ${B}${b}'l'${N} and [ENTER] ";
  echo;
  seperator;
  echo -e "    Currently blocked companies = ${B}${b}${CURRENTCOMPS}${N}     ";
  seperator;
  echo -e "    To quit this use                  ${B}${b}'q'${N} and [ENTER] ";
  seperator;
  echo;
  read what;
  # Main part
  case $what in
    a*|A*)
      clear;
      # Go to working directory
      cd /tmp || exit 1;
      # Clean up existing files if presant
      if [[ -f "${RAWAD}" || -f "${ASN}" || -f "${COMPANIES}" || -f "${SORTAD}" ]]; then
        rm -f ${RAWAD} ${ASN} ${COMPANIES} ${SORTAD} > /dev/null 2>&1;
      fi
      # Ask for companies
      printf "%b" "${B}${b}Please enter company names which you want to block seperated by blank space. Example: ${R}${b}google facebook twitter${N}\n";
      echo "To quit use [CTRL]-c"
      echo;
      read what;
      echo "${what}" | tr ' ' '\n' >> ${COMPANIES};
      # Get ASNs
      clear;
      echo -e "${B}${b}Checkout ASNs (be patient)... ${N}";
      while read c; do
        curl --silent "https://www.ultratools.com/tools/asnInfoResult?domainName=${c}" | \
        grep -Eo 'AS[0-9]+' >> ${ASN};
      done < ${COMPANIES};
      echo;
      if [ ! -s "${ASN}" ]; then
        echo -e "${R}${b}There is no ASN available, need to quit... ${N}";
        exit 1;
      fi
      # Add directory for specific infos if not already there
      if [ ! -e "${COMPANYDIR}" ]; then
        mkdir ${COMPANYDIR}
      fi
      # Copy company names to dir
      cat ${COMPANIES} > ${COMPANYNAME};

      # Get CIDRs from ASN
      echo -e "${B}${b}Checkout networks from ASNs (be patient)... ${N}";
      while read a; do
        curl --silent "https://stat.ripe.net/data/announced-prefixes/data.json?preferred_version=1.1&resource=${a}" | \
        grep -Eo "([0-9.]+){4}/[0-9]+" >> ${RAWAD}
        whois -h whois.radb.net -- "-i origin ${a}" | grep -Eo "([0-9.]+){4}/[0-9]+" >> ${RAWAD}
      done < ${ASN};
      echo;
      # Sort address list and make it uniq
      sort -u ${RAWAD} > ${SORTAD};
      echo -e "All CIDRs has been investigated, will add them now to IPSet to firewall them... ";

      ## IPSet section
      # Create appropriate sets with counter if not already done
      if [ -z "$(ipset -n list | grep ${SETCIDR})" ]; then
        ipset create ${SETCIDR} hash:net counters;
      fi
      # Flushing existing set and prepare for potential updates
      ipset flush ${SETCIDR};
      # Introducing content to IPSet
      for l in $(cat ${SORTAD}); do ipset --add ${SETCIDR} "${l}"; done;
      # Save new set
      ipset save > ${CONF};
      ${FWL} stop;
      fwdel_funct;
      fwadd_funct;
      ${FWL} start;
      # Add IPset entry to reactivate configuration after reboot
      if [ -z "$(grep 'ipset' ${RC})" ]; then
        echo "ipset restore < ${CONF} && ${FWL} reload;" >> ${RC};
      fi
      echo;
      echo -e "All has been done.";
      # Clean up
      rm -rf ${COMPANIES} ${RAWAD} ${SORTAD} ${ASN};
      sleep 3;
    ;;

    d*|D*)
      clear;
      # Flushing existing set and delete it
      echo;
      echo -e "Will flush now the IPSet sets and delete them accordingly... ";
      ipset flush ${SETCIDR};
      echo;
      echo -e "Will delete now the FW rules from ${FWL} and restart it... ";
      ${FWL} stop;
      fwdel_funct;
      ${FWL} start; 
      ipset destroy ${SETCIDR};
      ipset save > ${CONF};
      # Delete company directory
      rm -rf ${COMPANYDIR};
      echo;
      echo -e "Thats it.";
      echo;
      sleep 5;
    ;;

  l*|L*)
    clear;
    echo -e "To quit hit ${b}${R}'q'${N}";
    sleep 5;
    ipset list ${SETCIDR} | less;
    echo;
  ;;

    q*|Q*)
      exit 0;
    ;;

    *)
      echo;
      echo -e "${R}Sorry this option does not exist... ${N}";
      sleep 3;
      echo;
    ;;
  esac
done

# EOF
