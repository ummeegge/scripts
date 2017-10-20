#!/bin/bash -x

# ovpn_cert_expiration_check.sh
#
# $author: ummeegge ipfire org ; $date: 20.10.2017 - 15:24:08
#########################################################################
# This script checks OpenVPNs index.txt for how much time is left
# until a client certificate will be expired.
# Certificats with OpenSSL maximum (999999) are excluded.
# Time should be configured by the individual needs,
# but is currently configured to 5 days.
#
# Days before can be defined in the "ALERT=5" variable.
# An own Email account should be presant for this since the Email account
#     password are stored in cleartext in the script.
# Script provides Email encryption via GPG.
#     An howto setup can be found in here --> http://wiki.ipfire.org/en/optimization/scripts/gpg/start .
# Email function is currently commented to check the script functionality.
# Own Email credentials needs to be set in the script (section herefor are marked).
# Clean up $WORKDIR in /tmp is currently commented to investigate file results.
# Script can be placed e.g. into /etc/fcron.daily .
#     All paths has been set absolute so the fcron environment should find all binaries.
#

## Paths, dirs and files
INDEX="/var/ipfire/ovpn/certs/index.txt";
WORKDIR="/tmp/ovpn_cert_alert";
CERTLIST="${WORKDIR}/certlist";
COUNTERLIST="${WORKDIR}/counterlist";
MERGED="${WORKDIR}/merged";
MAIL="${WORKDIR}/mailalert";
MAILCRYPTED="${WORKDIR}/mailalert.asc";
# Needed binary locations
SENDMAIL="/usr/local/bin/sendEmail";
GPG="/usr/bin/gpg";

# Email text
DATELIST="List of OpenVPN certificate expiration dates from $(hostname) - $(date)";
DATELISTA="Already revoked certificates and such with OpenSSL maximum are not listed in here.";
DATELISTB="You will deliver mails also for '0 days left' certificates. If they are presant you should clean them up.";

## Check for needed dependencies
# sendEmail check
if [ ! -e "${SENDMAIL}" ]; then
   /bin/echo -e "Can´t find needed sendEmail binary. Please install it via Pakfire first.";
   exit 1;
fi
# index.txt check
if [ -s "${FILE}" ]; then
   /bin/echo -e "The certificate index is empty or not presant, please add first clients.";
   exit 1;
fi
# Check for workdir otherwise create it
if [ -e "${WORKDIR}" ]; then
    /bin/rm -rf ${WORKDIR};
    /bin/mkdir ${WORKDIR};
else
    /bin/mkdir ${WORKDIR}
fi


############################### ADD HERE YOUR INDIVIDUAL DATA ##########################################################
# ----- How much days should be left until an alert should be fired -----
#
ALERT="5";
#
# ----- Please configure here your specific Email data ------
#
MAILPASS="YourEmailPassword";
MAILADDRESS="example@web.de";
MAILNAME="example";
SMTPADDRESS="smtp.web.de:587";
MESSAGE="From $(date)";
SUBJECT="From $(date) OVPN expiring date has been reached";
PUBKEYID="2F033721";
#
########################################################################################################################

#################################################### Main part #########################################################
## Searcher
certs_date=$(/usr/bin/awk '/^V/ {print $2}' ${INDEX} | cut -c1-6 | grep -E '^1|^2');

## Time values
NOW=$(date +%s);
# 24 hours in seconds
DAY="86400";

## Mail preparation
# Copy CNs from index.txt to counter list.
# Without already revoked certificates but also no host certificate
/usr/bin/awk '/^V/ { print $2" ",$3" ",$5}' ${INDEX} | sed '/^4.*Z/d' | /usr/bin/awk -F'/' '{ print $4 }' > ${CERTLIST};

## Calculation
for i in ${certs_date}; do
    # Convert index.txt time to UNIX time
    UNTIL=$(date -d "${i}" +%s);
    # Calculate differences
    DIFF=$(( ${UNTIL} - ${NOW} ));
    # Convert UNIX time to days
    REST=$(( ${DIFF} / ${DAY} ));
    # Text with integrated result
    echo "${REST} days are left for user with the common name - ";
done >> ${COUNTERLIST};

# Merge lists withanother
/usr/bin/paste {$COUNTERLIST,$CERTLIST} > ${MERGED};

# Check for alert and prepare mail
/usr/bin/awk -v var="$ALERT" '$1<=var' ${MERGED} | sed 's/^-//g' > ${MAIL};

# Check if alert should be fired
if [ $(/bin/ls -l ${MAIL} | /usr/bin/awk '{print $5}') -ne 0 ]; then
    sed -i -e "1s/^/$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;)\n\n/" \
    -e "1s/^/${DATELIST}\n/" \
    -e "1s/^/$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;)\n/" ${MAIL};
    # Next line can be deleted if Email as been set up. Line is only for testing pruposes
    /bin/echo "Will fire an alert... ";
    /bin/echo -e "\n\n${DATELISTA}\n" >> ${MAIL};
    /bin/echo -e "${DATELISTB}\n" >> ${MAIL};
    # Send alert via sendEmail encrypted with GPG
    #${GPG} --encrypt -a --recipient "${PUBKEYID}" "${MAIL}";
    #${SENDMAIL} -f "${MAILADDRESS}" -t "${MAILADDRESS}" \
    #-s "${SMTPADDRESS}" \
    #-u "${SUBJECT}" \
    #-m "${MESSAGE}" \
    #-xu "${MAILNAME}" \
    #-xp "${MAILPASS}" \
    #-a "${MAILCRYPTED}";
    #logger -t OpenVPN-cert-check "Warning: One or more OpenVPN certificates has been expired. Email alert has been send... ";
fi

# Clean up workdir
#/bin/rm -rf ${WORKDIR};

# EOF
