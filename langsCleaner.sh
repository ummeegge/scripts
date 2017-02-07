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
#

IFS=$'\n'

DIR="/tmp/strings_not_found";
LANGS="/var/ipfire/langs";
CGI="/srv/web/ipfire/cgi-bin"
MENU="/var/ipfire/menu.d";
PLS="/var/ipfire";
THEMES="/srv/web/ipfire/html/themes/*/*";
PAKFIRE="/opt/pakfire/lib";

# Add dir if not already presant
if [ ! -d "${DIR}" ]; then
    mkdir ${DIR};
fi

cd ${DIR};

## Main part
# Investigate unused entries

echo "You can easily go for a tankard of coffe now ;-) ... ";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/en.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/en;
    fi
done

echo "English has been checked... ";
echo "8 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/de.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/de;
    fi
done

echo "German has been checked... ";
echo "7 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/es.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/es;
    fi
done

echo "Spanish has been checked... ";
echo "6 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/fr.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/fr;
    fi
done

echo "French has been checked... ";
echo "5 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/it.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/it;
    fi
done

echo "Italian has been checked... ";
echo "4 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/nl.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/nl;
    fi
done

echo "Dutch has been checked... ";
echo "3 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/pl.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/pl;
    fi
done

echo "Polish has been checked... ";
echo "2 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/ru.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/ru;
    fi
done

echo "Russian has been checked... ";
echo "1 language is left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/tr.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/tr;
    fi
done

echo "Turkish has been checked... ";
echo;
echo "All languages has been compared and the lost strings has been printed to ${DIR} ."
echo;

echo "---------------------------------------------------------------------------";
echo "Puhh lots of hassle here today :-| ... ";
echo "Need to strip the lost ones out... stay tuned ;-) "
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

for l in $(cat pl)
do
    sed -i "/${l}/d" ${LANGS}/pl.pl;
done

echo "Polish is done... ";
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
echo "The language cache has been updated. From now on, all changes can be overviewed over the WUI. ";

echo "--------------------------------------------------------------------------------------------------";
echo;
echo " If there are some 'sed: -e expression #1, char 1: unknown command' errors, ";
echo "there might be variables with an slash '/' in it .";
echo "A test will now follow, so if the script has been finished, it will print the strings out for you.";
echo "You can also find all files under ${DIR} .";
echo;
echo "--------------------------------------------------------------------------------------------------";


for i in $(awk -F"'" '{ print $2 }' ${LANGS}/de.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/de_rest_entries;
    fi
done

echo "German has been tested... ";
echo "8 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/en.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/en_rest_entries;
    fi
done

echo "English has been tested... ";
echo "7 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/es.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/es_rest_entries;
    fi
done

echo "Spanish has been tested... ";
echo "6 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/fr.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/fr_rest_entries
    fi
done

echo "French has been tested... ";
echo "5 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/it.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/it_rest_entries;
    fi
done

echo "Italian has been tested... ";
echo "4 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/nl.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/nl_rest_entries;
    fi
done

echo "Dutch has been tested... ";
echo "3 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/pl.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/pl_rest_entries;
    fi
done

echo "Polish has been tested... ";
echo "2 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/ru.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/ru_rest_entries;
    fi
done

echo "Russian has been tested... ";
echo "1 languages are left";
echo;

for i in $(awk -F"'" '{ print $2 }' ${LANGS}/tr.pl)
do
    if [ -z "$(grep -FR "${i}" ${CGI}/*)" ] && [ -z "$(grep -FR "${i}" ${MENU}/*)" ] && [ -z "$(grep -FR "${i}" ${PLS}/*.pl)"] && [ -z "$(grep -FR "${i}" ${THEMES}/*.pl)"] && [ -z "$(grep -FR "${i}" ${PAKFIRE}/*.pl)"]; then
        echo "$i" >> ${DIR}/tr_rest_entries;
    fi
done

echo "Turkish has been tested... ";

echo;
echo;
echo "====================================================================================================";
echo "Show you all entries which has not been deleted, please delete them manually or try a better script.";
echo "                                All files can be found under ${DIR}                                ".;
echo "====================================================================================================";
echo;
head -n99999999 ${DIR}/*_rest_entries;
echo;
echo;

# End script
