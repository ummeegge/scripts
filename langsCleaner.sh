#!/bin/bash -

#
# Script searches all IPFire language files for appropriate entries in
# /srv/web/ipfire/cgi-bin and it´s subdirectories but also for
# menu entries under /var/ipfire/menu.d/ .
# If no entries has been found, it will echo it to files for each language which
# will be used to delete them from the respective language file.
# All files can be found under /tmp .
# The script operates in working environment but it should be managable to
# generate all diffs by copying the new files to the building env which should
# then delivers applicable diffs.
#
# $Author: ummeegge ; $date: 02.05.2017
################################################################################
#

IFS=$'\n'

DIR="/tmp/strings_not_found";
LANGS="/var/ipfire/langs";
CGI="/srv/web/ipfire/cgi-bin"
MENU="/var/ipfire/menu.d";

# Add dir if not already presant
if [ ! -d "${DIR}" ]; then
    mkdir ${DIR};
fi

cd ${DIR};

## Main part
# Investigate unused entries

echo "You can easily go for a tankard of coffe now ;-) ... ";
echo;
sleep 3;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/en.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/en
    fi
done

echo "English has been checked... ";
echo "8 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/de.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/de
    fi
done

echo "German has been checked... ";
echo "7 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/es.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/es
    fi
done

echo "Spanish has been checked... ";
echo "6 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/fr.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/fr
    fi
done

echo "French has been checked... ";
echo "5 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/it.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/it
    fi
done

echo "Italian has been checked... ";
echo "4 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/nl.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/nl
    fi
done

echo "Dutch has been checked... ";
echo "3 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/pl.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/pl
    fi
done

echo "Polish has been checked... ";
echo "2 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/ru.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/ru
    fi
done

echo "Russian has been checked... ";
echo "1 language is left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/tr.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ]; then
        echo "$i" >> ${DIR}/tr
    fi
done

echo "---------------------------------------------------------------------------":
echo "Puhh lots of hastle here today :-| ... ";
echo "Need to strip the lost ones out... stay tuned ;-) "
sleep 3;
echo "---------------------------------------------------------------------------";
echo;

# Delete entries in langs dir from investigated lists
for l in $(cat en)
do
    sed -i "/${l}/d" ${LANGS}/en.pl;
done

echo "English is done... ";
echo;

for l in $(cat de)
do
    sed -i "/${l}/d" ${LANGS}/de.pl;
done

echo "German is done... ";
echo;

for l in $(cat es)
do
    sed -i "/${l}/d" ${LANGS}/es.pl;
done

echo "Spanish is done... ";
echo;

for l in $(cat fr)
do
    sed -i "/${l}/d" ${LANGS}/fr.pl;
done

echo "French is done... ";
echo;

for l in $(cat it)
do
    sed -i "/${l}/d" ${LANGS}/it.pl;
done

echo "Polish is done... ";
echo;

for l in $(cat nl)
do
    sed -i "/${l}/d" ${LANGS}/nl.pl;
done

echo "Dutch is done... ";
echo;

for l in $(cat ru)
do
    sed -i "/${l}/d" ${LANGS}/ru.pl;
done

echo "Russian is done... ";
echo;

for l in $(cat tr)
do
    sed -i "/${l}/d" ${LANGS}/tr.pl;
done

echo "Turkish is done... ";
echo;

update-lang-cache;

echo;
echo;
echo;
echo " If there are some 'sed: -e expression #1, char 1: unknown command' errors, you need to fix them manually by";
echo "deleting all strings with an slash '/' in it .";
echo "That´s it cheers and... Goodbye";


# End script
