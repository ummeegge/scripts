#!/bin/bash -

#
# Script searches all IPFire language files for appropriate entries in
# /srv/web/ipfire/cgi-bin and it´s subdirectories , under /var/ipfire/menu.d/ ,
# under /opt/pakfire/lib , /srv/web/html/themes/*/* and under /var/ipfire all *.pl files .
# If no entries has been found, it will echo it to files for each language which
# will be used to delete them from the respective language file.
# A check will processed which checks for missing deletions.
# All files can be found under /tmp .
# The script operates in working environment but it should be managable to
# generate all diffs by copying the new files to the building env which should
# then delivers applicable diffs.
# Script will compute deleted lines in language files.
# Diffs after processing will be generated if desired.
#
# $Author: ummeegge ; $mail: $Author at web de ; $date: 01.03.2017
############################################################################################

# End of line is seperator
IFS=$'\n'

# Locations
WORKDIR="workdir_langs"
DIR="${WORKDIR}/langs_strings_not_found";
CGI="html/cgi-bin/*"
MENU="config/menu/*";
THEMES="html/html/themes/*/*/*";
PAKFIRE="src/pakfire/lib/*";
CFG="config/cfgroot/*.pl";
BCK="${DIR}/langs_orig_bck";
DIF="${DIR}/diffs";
LCB="${DIR}/LineCounter_before";
LCA="${DIR}/LineCounter_after";
LCR="${DIR}/deleted_lines_result";

# Formatting functions
COLUMNS="$(tput cols)";
R=$(tput setaf 1);
B=$(tput setaf 6);
N=$(tput sgr0);
# Text
TITEL="Clean up script for dead language file strings - You can easily go for a tankard of coffe now ;-)";
END="That´s it, all work has been done, will go for a beer now. Tschüssle";
HASSLE="Need to strip the lost ones out... stay tuned ;-) ";
HASSLEA="Puhh lots of hassle here today :-| ...";
ERROR="A test will now follow if the script have deleted all strings, ";
ERRORA="so if the script has been finished, it will print the strings out for you if something exists.";
ERRORB="If some strings appear, you will need to delete them manually";
ERRORC="You can find all files under ${DIR} .";
COPY="All languages has been compared and the lost strings has been printed to ${DIR} ."
RESULT="Show you all entries which has not been deleted, please delete them manually or try a better script.";
RESULTA="All files can be found under ${DIR} if something has been done there.";
RESULTB="This count of deleted lines can also be found under '${LCR}' if there has been something deleted.";
RESULTC="Count of all deleted lines per language";
DIFF="DIFF section if needed";
# Seperator functions
seperator(){ printf -v _hr "%*s" ${COLUMNS} && echo ${_hr// /${1-=}}; }

# Check for correct working dir
if [ ! -d ../ipfire-2.x/ ]; then
    echo "Script can only be started from IPFire Source base directory 'ipfire-2.x'. Need to quit";
    exit 1;
fi

# Add dir if not already presant and change working place
if [ -d "${DIR}" ]; then
    rm -rvf ${DIR};
fi
if [ ! -d "${DIR}" ]; then
    mkdir -vp ${DIR};
fi

# Backup of existing files
cp -R langs/ ${BCK}/;

## Main part
clear;
echo;
printf "%*s\n" $(((${#TITEL}+COLUMNS)/2)) "${TITEL}";
echo;
seperator;
echo;
echo;

# Count lines before processing
wc -l langs/*/cgi-bin/*.pl >> ${LCB};

# Status bar
while true; do echo -n .; sleep 1; done &
trap 'kill $!' SIGTERM

# Investigate unused entries

for i in $(awk -F"'" '{ print $2 }' langs/en/cgi-bin/en.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/en;
    fi
done

echo -e "${B}English has been checked... ${N}";
echo;
echo -e "${R}8 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/de/cgi-bin/de.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/de;
    fi
done

echo -e "${B}German has been checked... ${N}";
echo;
echo -e "${R}7 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/es/cgi-bin/es.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/es;
    fi
done

echo -e "${B}Spanish has been checked... ${N}";
echo;
echo -e "${R}6 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/fr/cgi-bin/fr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/fr;
    fi
done

echo -e "${B}French has been checked... ${N}";
echo;
echo -e "${R}5 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/it/cgi-bin/it.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/it;
    fi
done

echo -e "${B}Italian has been checked... ${N}";
echo;
echo -e "${R}4 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/nl/cgi-bin/nl.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/nl;
    fi
done

echo -e "${B}Dutch has been checked... ${N}";
echo;
echo -e "${R}3 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/pl/cgi-bin/pl.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/pl;
    fi
done

echo -e "${B}Polish has been checked... ${N}";
echo;
echo -e "${R}2 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/ru/cgi-bin/ru.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/ru;
    fi
done

echo -e "${B}Russian has been checked... ${N}";
echo;
echo -e "${R}1 language is left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/tr/cgi-bin/tr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/tr;
    fi
done

echo -e "${B}Turkish has been checked... ${N}";
echo;

echo;
echo;
seperator;
printf "%*s\n" $(((${#COPY}+COLUMNS)/2)) "${COPY}";
printf "%*s\n" $(((${#HASSLE}+COLUMNS)/2)) "${HASSLE}";
printf "%*s\n" $(((${#HASSLEA}+COLUMNS)/2)) "${HASSLEA}";
seperator;
echo;
echo;

# Delete entries in langs dir from investigated lists
for l in $(cat ${DIR}/en); do
    sed -i "\#${l}#d" langs/en/cgi-bin/en.pl;
done

echo -e "${B}English is done... ${N}";
echo;

for l in $(cat ${DIR}/de); do
    sed -i "\#${l}#d" langs/de/cgi-bin/de.pl;
done

echo -e "${B}German is done... ${N}";
echo;

for l in $(cat ${DIR}/es); do
    sed -i "\#${l}#d" langs/es/cgi-bin/es.pl;
done

echo -e "${B}Spanish is done... ${N}";
echo;

for l in $(cat ${DIR}/fr); do
    sed -i "\#${l}#d" langs/fr/cgi-bin/fr.pl;
done

echo -e "${B}French is done... ${N}";
echo;

for l in $(cat ${DIR}/it); do
    sed -i "\#${l}#d" langs/it/cgi-bin/it.pl;
done

echo -e "${B}Italian is done... ${N}";
echo;

for l in $(cat ${DIR}/nl); do
    sed -i "\#${l}#d" langs/nl/cgi-bin/nl.pl;
done

echo -e "${B}Dutch is done... ${N}";
echo;

for l in $(cat ${DIR}/pl); do
    sed -i "\#${l}#d" langs/pl/cgi-bin/pl.pl;
done

echo -e "${B}Polish is done... ${N}";
echo;

for l in $(cat ${DIR}/ru); do
    sed -i "\#${l}#d" langs/ru/cgi-bin/ru.pl;
done

echo -e "${B}Russian is done... ${N}";
echo;

for l in $(cat ${DIR}/tr); do
    sed -i "\#${l}#d" langs/tr/cgi-bin/tr.pl;
done

echo -e "${B}Turkish is done${N}";
echo;

seperator;
echo;
printf "%*s\n" $(((${#ERROR}+COLUMNS)/2)) "${ERROR}";
printf "%*s\n" $(((${#ERRORA}+COLUMNS)/2)) "${ERRORA}";
printf "%*s\n" $(((${#ERRORB}+COLUMNS)/2)) "${ERRORB}";
printf "%*s\n" $(((${#ERRORC}+COLUMNS)/2)) "${ERRORC}";
echo;
seperator;
echo;


for i in $(awk -F"'" '{ print $2 }' langs/de/cgi-bin/de.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/de_rest_entries;
    fi
done

echo -e "${B}German has been tested... ${N}";
echo;
echo -e "${R}8 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/en/cgi-bin/en.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/en_rest_entries;
    fi
done

echo -e "${B}English has been tested... ${N}";
echo;
echo -e "${R}7 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/es/cgi-bin/es.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/es_rest_entries;
    fi
done

echo -e "${B}Spanish has been tested... ${N}";
echo;
echo -e "${R}6 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/fr/cgi-bin/fr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/fr_rest_entries
    fi
done

echo -e "${B}French has been tested... ${N}";
echo;
echo -e "${R}5 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/it/cgi-bin/it.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/it_rest_entries;
    fi
done

echo -e "${B}Italian has been tested... ${N}";
echo;
echo -e "${R}4 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/nl/cgi-bin/nl.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/nl_rest_entries;
    fi
done

echo -e "${B}Dutch has been tested... ${N}";
echo;
echo -e "${R}3 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/pl/cgi-bin/pl.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/pl_rest_entries;
    fi
done

echo -e "${B}Polish has been tested... ${N}";
echo;
echo -e "${R}2 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/ru/cgi-bin/ru.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/ru_rest_entries;
    fi
done

echo -e "${B}Russian has been tested... ${N}";
echo;
echo -e "${R}1 language are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' langs/tr/cgi-bin/tr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
        echo "$i" >> ${DIR}/tr_rest_entries;
    fi
done

echo "${B}Turkish has been tested${N}";

kill $!

echo;
echo;
seperator;
printf "%*s\n" $(((${#RESULT}+COLUMNS)/2)) "${RESULT}";
printf "%*s\n" $(((${#RESULTA}+COLUMNS)/2)) "${RESULTA}";
seperator;
echo;
echo;
if test -n "$(find "${DIR}" -name '*rest_entries')"; then
    head -n99999999 ${DIR}/*_rest_entries;
else
    echo -e "${B}All located strings has been deleted... ${N}";
echo;
echo;

# Numbers of deletion
seperator;
printf "%*s\n" $(((${#RESULTC}+COLUMNS)/2)) "${RESULTC}";
seperator;
echo;
echo;
# Count lines after processing
wc -l langs/*/cgi-bin/*.pl >> ${LCA};
# Processing number of deletion
paste {$LCB,$LCA} | awk '{ print $1-$3,"\tLines has been deleted in     "$2 }' > ${LCR};
cat ${LCR};
echo;
printf "%*s\n" $(((${#RESULTB}+COLUMNS)/2)) "${RESULTB}";
echo;
echo;
# Ask for diffs
seperator;
printf "%*s\n" $(((${#DIFF}+COLUMNS)/2)) "${DIFF}";
seperator;
echo;
echo;
printf "%b" "If you´d like to have a list of all deleted lines, press ${R}'Y'${N}[ENTER] - To skip it press ${R}'N'${N}[ENTER]: ";
read what;
case "$what" in
    y*|Y*)
        mkdir ${DIF};
        echo;
        diff --side-by-side --suppress-common-lines ${BCK}/en/cgi-bin/en.pl langs/en/cgi-bin/en.pl > ${DIF}/en.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/de/cgi-bin/de.pl langs/de/cgi-bin/de.pl > ${DIF}/de.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/es/cgi-bin/es.pl langs/es/cgi-bin/es.pl > ${DIF}/es.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/fr/cgi-bin/fr.pl langs/fr/cgi-bin/fr.pl > ${DIF}/fr.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/it/cgi-bin/it.pl langs/it/cgi-bin/it.pl > ${DIF}/it.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/nl/cgi-bin/nl.pl langs/nl/cgi-bin/nl.pl > ${DIF}/nl.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/pl/cgi-bin/pl.pl langs/pl/cgi-bin/pl.pl > ${DIF}/pl.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/ru/cgi-bin/ru.pl langs/ru/cgi-bin/ru.pl > ${DIF}/ru.pl.diff;
        diff --side-by-side --suppress-common-lines ${BCK}/tr/cgi-bin/tr.pl langs/tr/cgi-bin/tr.pl > ${DIF}/tr.pl.diff;
        echo;
        echo -e "${B}You can find the lists under '${DIF}'${N}";
        echo;
    ;;
    n*|N*)
        echo;
        echo -e "${B}You want no lists/diffs OK... ${N}";
        echo;
    ;;
esac
echo;
echo;
printf "%*s\n" $(((${#END}+COLUMNS)/2)) "${END}";
echo;
echo;

# End script
