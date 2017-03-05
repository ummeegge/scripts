#!/bin/bash -

#
# Script checks for strings in all languages which do not exists
# compared to english language file.
# This method is not complete since there are also some english strings
# in the other language files.
#
# $author: ummeegge we de ; $date: 05.03.2017
########################################################################
#

# End of line is seperator
IFS=$'\n'

DIR="/tmp/langs_string_searcher";
NOENTRIES="${DIR}/no_entries_found";
LANGS="langs/*/cgi-bin/*";
VAR="${DIR}/langs_var";
TRANS="${DIR}/strings_to_translate";
LANGUAGES="en de es fr it nl pl ru tr";
LANGCOMPA="de es fr it nl pl ru tr";

# Check for correct working dir
if [ ! -d ../ipfire-2.x/ ]; then
    echo "Script can only be started from IPFire Source base directory 'ipfire-2.x'. Need to quit";
    exit 1;
fi

# Check if /tmp is presant
if [ ! -d /tmp ]; then
    echo "Could NOT find /tmp. Need to quit";
    exit 1;
fi

# Add workdir if not already presant and delete old if presant
if [ -d "${DIR}" ]; then
    rm -rvf ${DIR};
fi
if [ ! -d "${DIR}" ]; then
    mkdir -vp ${NOENTRIES} ${TRANS};
fi

# Filter variable field only
for l in $(echo ${LANGUAGES} | tr ' ' '\n'); do
	awk -F"'" '{ print $2 }' langs/${l}/cgi-bin/${l}.pl > ${DIR}/langs_var_${l};
done

for i in $(echo ${LANGCOMPA} | tr ' ' '\n'); do
	diff -u ${VAR}_en ${VAR}_${i} | grep '^-' | sed -e 's/^-//g' -e '1d'> ${NOENTRIES}/${i};
done

# Extract the strings
for l in $(cat ${NOENTRIES}/de); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/de;
done

for l in $(cat ${NOENTRIES}/es); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/es;
done

for l in $(cat ${NOENTRIES}/fr); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/fr;
done

for l in $(cat ${NOENTRIES}/it); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/it;
done

for l in $(cat ${NOENTRIES}/nl); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/nl;
done

for l in $(cat ${NOENTRIES}/pl); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/pl;
done

for l in $(cat ${NOENTRIES}/ru); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/ru;
done

for l in $(cat ${NOENTRIES}/tr); do
	grep -P "^\'${l}" langs/en/cgi-bin/en.pl >> ${TRANS}/tr;
done

# End script
