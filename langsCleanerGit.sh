#!/bin/bash -

#
# Script searches all IPFire language files for appropriate entries in
# IPFires Git environment.
# If no entries has been found, it will echo it to files for each language which
# will be used to delete them from the respective language file.
# A check will processed which checks for missing deletions.
# A work directory will be created where all files can be found.
# Script needs to be executed under ipfire-2.x .
# Script will compute deleted lines in language files and
# it delivers diffs after processing from old to new files if desired.
#
# $Author: ummeegge ; $mail: $Author at web de ; $date: 02.03.2017
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
LANGUAGES="en de es fr it nl pl ru tr";

# Formatting functions
COLUMNS="$(tput cols)";
R=$(tput setaf 1);
B=$(tput setaf 6);
N=$(tput sgr0);
# Text
TITEL="Clean up script for dead language file strings - You can easily go for a tankard of coffe now ;-)";
TITELA="9 languages needs to be processed, so stay tuned... "
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
printf "%*s\n" $(((${#TITELA}+COLUMNS)/2)) "${TITELA}";
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
for l in $(echo ${LANGUAGES} | tr ' ' '\n'); do
    for i in $(awk -F"'" '{ print $2 }' langs/${l}/cgi-bin/${l}.pl); do
        if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
            echo "$i" >> ${DIR}/${l};
        fi
    done
    echo -e "${B}${l} has been checked... ${N}";
    echo;
done

# Delete entries in langs dir from investigated lists
echo;
seperator;
printf "%*s\n" $(((${#COPY}+COLUMNS)/2)) "${COPY}";
printf "%*s\n" $(((${#HASSLE}+COLUMNS)/2)) "${HASSLE}";
printf "%*s\n" $(((${#HASSLEA}+COLUMNS)/2)) "${HASSLEA}";
seperator;
echo;
echo;
for l in $(echo ${LANGUAGES} | tr ' ' '\n'); do
    for i in $(cat ${DIR}/${l}); do
        sed -i "\#${i}#d" langs/${l}/cgi-bin/${l}.pl;
    done
    echo -e "${B}${l} is done... ${N}";
    echo;
done

# Check if investigated lines are left
seperator;
echo;
printf "%*s\n" $(((${#ERROR}+COLUMNS)/2)) "${ERROR}";
printf "%*s\n" $(((${#ERRORA}+COLUMNS)/2)) "${ERRORA}";
printf "%*s\n" $(((${#ERRORB}+COLUMNS)/2)) "${ERRORB}";
printf "%*s\n" $(((${#ERRORC}+COLUMNS)/2)) "${ERRORC}";
echo;
seperator;
echo;
echo;
for l in $(echo ${LANGUAGES} | tr ' ' '\n'); do
    for i in $(awk -F"'" '{ print $2 }' langs/${l}/cgi-bin/${l}.pl); do
        if [ -z "$(grep -FR "${i}" ${CGI} ${MENU} ${THEMES} ${PAKFIRE} ${CFG})" ]; then
            echo "$i" >> ${DIR}/${l}_rest_entries;
        fi
    done
    echo -e "${B}${l} has been checked... ${N}";
    echo;
done
# Kill status bar process
kill $!

# Check if invested strings are deleted, otherwise they will be displayed
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
fi
echo;
echo;

# Count and compare number of deleted string lines
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
        for l in $(echo ${LANGUAGES} | tr ' ' '\n'); do
            diff --side-by-side --suppress-common-lines ${BCK}/${l}/cgi-bin/${l}.pl langs/${l}/cgi-bin/${l}.pl > ${DIF}/${l}.pl.diff;
        done
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
