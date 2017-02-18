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
#
# $Author: ummeegge ; $date: 07.02.2017
############################################################################################

# End of line is seperator
IFS=$'\n'

# Locations
DIR="/tmp/addon_strings_not_found";
LANGS="/var/ipfire/addon-lang";
CGI="/srv/web/ipfire/cgi-bin"
MENU="/var/ipfire/menu.d";
PLS="/var/ipfire";
THEMES="/srv/web/ipfire/html/themes/*/*";
PAKFIRE="/opt/pakfire/lib";
LCB="LineCounter_before";
LCA="LineCounter_after";

# Formatting functions
COLUMNS="$(tput cols)";
R=$(tput setaf 1);
G=$(tput setaf 2);
B=$(tput setaf 6);
b=$(tput bold);
N=$(tput sgr0);
# Text
TITEL="Clean up script for dead addon language file strings - You can easily go for a cup of coffe now ;-)";
END="That´s it, all work has been done, will go for a beer now. Tschüssle";
HASSLEA="NIce work here today :-) ...";
HASSLE="Need to strip the lost ones out... stay tuned ;-) ";
ERROR="If there are some 'sed: -e expression #1, char 1: unknown command' errors, ";
ERRORA="there might be variables with an slash '/' in it .";
ERRORB="A test will now follow, so if the script has been finished, it will print the strings out for you if something exists.";
ERRORC="You can find all files under ${DIR} .";
COPY="All languages has been compared and the lost strings has been printed to ${DIR} ."
LANG="The language cache has been updated. From now on, all changes can be overviewed over the WUI. ";
RESULT="Show you all entries which has not been deleted, please delete them manually or try a better script.";
RESULTA="All files can be found under ${DIR} .";
RESULTB="This count of deleted lines can also be found under '${DIR}/deleted_lines_result' if there has been something deleted.";
RESULTC="Count of all deleted lines per language";
# Seperator functions
seperator(){ printf -v _hr "%*s" ${COLUMNS} && echo ${_hr// /${1-=}}; }


## Main part
clear;
echo;
printf "%*s\n" $(((${#TITEL}+$COLUMNS)/2)) "${TITEL}";
echo;
seperator;
echo;
echo;

# Add dir if not already presant and change working place
if [ ! -d "${DIR}" ]; then
    mkdir ${DIR};
fi
cd ${DIR};

# Backup of existing files
cp -R ${LANGS} ${DIR}/addon-lang_orig

# Count lines before processing
wc -l ${LANGS}/*.pl >> ${DIR}/${LCB};

# Status bar
while true; do echo -n .; sleep 1; done &
trap 'kill $!' SIGTERM SIGKILL

# Investigate unused entries

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*en.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/en;
    fi
done

echo -e "${B}English has been checked... ${N}";
echo;
echo -e "${R}8 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*de.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/de;
    fi
done

echo -e "${B}German has been checked... ${N}";
echo;
echo -e "${R}7 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*es.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/es;
    fi
done

echo -e "${B}Spanish has been checked... ${N}";
echo;
echo -e "${R}6 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*fr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/fr;
    fi
done

echo -e "${B}French has been checked... ${N}";
echo;
echo -e "${R}5 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*it.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/it;
    fi
done

echo -e "${B}Italian has been checked... ${N}";
echo;
echo -e "${R}4 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*nl.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/nl;
    fi
done

echo -e "${B}Dutch has been checked... ${N}";
echo;
echo -e "${R}3 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*pl.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/pl;
    fi
done

echo -e "${B}Polish has been checked... ${N}";
echo;
echo -e "${R}2 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*ru.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/ru;
    fi
done

echo -e "${B}Russian has been checked... ${N}";
echo;
echo -e "${R}1 language is left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*tr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/tr;
    fi
done

echo -e "${B}Turkish has been checked${N}";
echo;

echo;
echo;
seperator;
printf "%*s\n" $(((${#COPY}+$COLUMNS)/2)) "${COPY}";
printf "%*s\n" $(((${#HASSLE}+$COLUMNS)/2)) "${HASSLE}";
printf "%*s\n" $(((${#HASSLEA}+$COLUMNS)/2)) "${HASSLEA}";
seperator;
echo;
echo;

# Delete entries in langs dir from investigated lists
for l in $(cat en)
do
    sed -i "/${l}/d" ${LANGS}/*en.pl;
done

echo -e "${B}English is done... ${N}";
echo;

for l in $(cat de)
do
    sed -i "/${l}/d" ${LANGS}/*de.pl;
done

echo -e "${B}German is done... ${N}";
echo;

for l in $(cat es)
do
    sed -i "/${l}/d" ${LANGS}/*es.pl;
done

echo -e "${B}Spanish is done... ${N}";
echo;

for l in $(cat fr)
do
    sed -i "/${l}/d" ${LANGS}/*fr.pl;
done

echo -e "${B}French is done... ${N}";
echo;

for l in $(cat it)
do
    sed -i "/${l}/d" ${LANGS}/*it.pl;
done

echo -e "${B}Italian is done... ${N}";
echo;

for l in $(cat nl)
do
    sed -i "/${l}/d" ${LANGS}/*nl.pl;
done

echo -e "${B}Dutch is done... ${N}";
echo;

for l in $(cat pl)
do
    sed -i "/${l}/d" ${LANGS}/*pl.pl;
done

echo -e "${B}Polish is done... ${N}";
echo;

for l in $(cat ru)
do
    sed -i "/${l}/d" ${LANGS}/*ru.pl;
done

echo -e "${B}Russian is done... ${N}";
echo;

for l in $(cat tr)
do
    sed -i "/${l}/d" ${LANGS}/*tr.pl;
done

echo -e "${B}Turkish is done${N}";
echo;

update-lang-cache > /dev/null 2>&1
echo;
echo;
printf "%*s\n" $(((${#LANG}+$COLUMNS)/2)) "${LANG}";
echo;
echo;

seperator;
echo;
printf "%*s\n" $(((${#ERROR}+$COLUMNS)/2)) "${ERROR}";
printf "%*s\n" $(((${#ERRORA}+$COLUMNS)/2)) "${ERRORA}";
printf "%*s\n" $(((${#ERRORB}+$COLUMNS)/2)) "${ERRORB}";
printf "%*s\n" $(((${#ERRORC}+$COLUMNS)/2)) "${ERRORC}";
echo;
seperator;


for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*de.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/de_rest_entries;
    fi
done

echo -e "${B}German has been tested... ${N}";
echo;
echo -e "${R}8 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*en.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/en_rest_entries;
    fi
done

echo -e "${B}English has been tested... ${N}";
echo;
echo -e "${R}7 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*es.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/es_rest_entries;
    fi
done

echo -e "${B}Spanish has been tested... ${N}";
echo;
echo -e "${R}6 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*fr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/fr_rest_entries
    fi
done

echo -e "${B}French has been tested... ${N}";
echo;
echo -e "${R}5 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*it.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/it_rest_entries;
    fi
done

echo -e "${B}Italian has been tested... ${N}";
echo;
echo -e "${R}4 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*nl.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/nl_rest_entries;
    fi
done

echo -e "${B}Dutch has been tested... ${N}";
echo;
echo -e "${R}3 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*pl.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/pl_rest_entries;
    fi
done

echo -e "${B}Polish has been tested... ${N}";
echo;
echo -e "${R}2 languages are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*ru.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/ru_rest_entries;
    fi
done

echo -e "${B}Russian has been tested... ${N}";
echo;
echo -e "${R}1 language are left${N}";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/*tr.pl); do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && \
        [ -z "$(grep -FR "${i}" ${PLS}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)" ] && \
        [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)" ]; then
        echo "$i" >> ${DIR}/tr_rest_entries;
    fi
done

echo "${B}Turkish has been tested${N}";

kill $!

echo;
echo;
seperator;
printf "%*s\n" $(((${#RESULT}+$COLUMNS)/2)) "${RESULT}";
printf "%*s\n" $(((${#RESULTA}+$COLUMNS)/2)) "${RESULTA}";
seperator;
echo;
echo;
head -n99999999 ${DIR}/*_rest_entries > /dev/null 2>&1;
echo;
echo;

# Numbers of deletion
seperator;
printf "%*s\n" $(((${#RESULTC}+$COLUMNS)/2)) "${RESULTC}";
seperator;
echo;
echo;
# Count lines after processing
wc -l ${LANGS}/*.pl >> ${DIR}/${LCA};
# Processing number of deletion
paste {$DIR/$LCB,$DIR/$LCA} | awk '{ print $1-$3,"\tLines has been deleted in     "$2 }' > ${DIR}/deleted_lines_result;
cat ${DIR}/deleted_lines_result;
echo;
printf "%*s\n" $(((${#RESULTB}+$COLUMNS)/2)) "${RESULTB}";
echo;
echo;
printf "%*s\n" $(((${#END}+$COLUMNS)/2)) "${END}";
echo;
echo;

# End script
