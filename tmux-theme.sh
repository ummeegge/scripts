#!/bin/bash -

#
# Script checks for /root/.tmux.conf file and installs it if not presant.
# Integrates tmux bash script for pane and window structure.
# Special layout of tmux will be executed by the script,
# which will be placed under /usr/bin with the name 'mux'.
# Uninstaller is meanwhile also available.
# Modification of the Bash prompt will also be provided by the script
#
# $author: ummeegge ; $date: 13.02.2015
#######################################################################
# mtr, iftop, bwm-ng and iptraf-ng and tmux will be used by the script,
# and will be installed if they are not presant.
# 3 windows with different structur and content will be created.
#

# Paths
CONF="${HOME}/.tmux.conf";
SCRIPT="/usr/bin/mux";
BASH="${HOME}/.bashrc";

# Needed Addons
BWM="/usr/bin/bwm-ng";
IFT="/usr/sbin/iftop";
MTR="/usr/sbin/mtr";
IPT="/usr/sbin/iptraf-ng";
TMUX="/usr/bin/tmux";

# Date
date=$(date +"%m-%d-%T");

## Functions
bashrc_funct() {
    # Modify Bash prompt so there is no need to display time in tmux statusbar
    clear;
    echo "Would you like to modify your Bash prompt to display also the current time in it ?";
    echo "The unsinstaller will remove this, but you need to logout and login again that changes takes affect.";
    echo;
    echo "You can also modify or delete the 'export PS1' line in ~/.bashrc which is responsible for that... ";
    echo;
    read -p "To modify your Bash prompt press 'y' and [ENTER]. If you don´t want this, press '"n"' and [ENTER]: " answer
    case $answer in
        y)
            echo;
            clear;
            echo "BackUP existing .bashrc... ";
            cp -v ${BASH} ${BASH}.bckOrig;
            echo;
            echo "Will change the Bash prompt under ${HOME}/.bashrc... ";
            echo;
            sleep 5;
            cat >> ${BASH} << "EOF"

# Tmux installer script entry to enter additional infos into the Bash prompt
export PS1="\e[1;37m[\[\e[0;36m\]\d \t\e[1;37m] \e[1;37m[\[\e[0;36m\]\u@\H\[\e[1;37m] \e[1;32m\] \w\[\e[0;32m\] \n-> "
EOF
        ;;

        n)
            echo;
            echo "Will go for further processing without modifying ${HOME}/.bashrc... ";
            echo;
            sleep 3;
        ;;
    esac
}

# Configuration function
config_funct() {
    # Check for conf and add it if not presant
if [[ -e "${CONF}" ]]; then
    clear;
    echo "Have found a Tmux configuration file... ";
    echo;
    read -p "If you want to backUP the existing tmux.conf press 'y' and [ENTER]. If you want to overwrite it press '"n"' and [ENTER]: " answer
        case $answer in
            y)
                echo;
                echo "Will backUP existing tmux.conf and copy new one to ${HOME}... ";
                echo;
                sleep 5;
                cp -v ${CONF} ${CONF}.bck_${date};
            ;;
                   
            n)
                echo;
                echo "Will overwrite .tmux.conf under ${HOME}... ";
                echo;
                sleep 5;
            ;;
                   
        esac
fi

# Copy tmux.conf into HOME dir
cat > ${CONF} << "EOF"
# tmux configuration file
# should takes place under ~/ as .tmux.conf
###########################################
# ummeegge 04.01.2014
#

# set defaults
set-option -g default-shell "/bin/bash"
set-option -g default-command "bash -l"
set-option -g default-terminal "screen-256color"
#

# remap prefix to Control + a
set -g prefix C-a
unbind C-b
bind C-a send-prefix
#

# reload config
bind r source-file ~/.tmux.conf \; display-message "Reload config file..."
#

# enable activity alerts
setw -g monitor-activity on
set -g visual-activity on
#

# Set scrollback to 10000 lines
set -g history-limit 10000
#

# Scroll, resize window and switch between the panes with the mouse
# The terminal.app in OS X needs simbl und MouseTerm
set-option -g mouse-utf8 on
set-option -g mouse-select-pane on
set-option -g mouse-select-window on
set-option -g mouse-resize-pane on
set-window-option -g mode-mouse on
#

# Status bar
# set color for status bar
set-option -g status-bg colour235 #base02
set-option -g status-fg yellow #yellow
set-option -g status-attr dim
# Show host name and IP address on left side of status bar
set -g status-left-length 70
set -g status-left "#[fg=green] #h - #[fg=brightred]#(curl -s ipecho.net/plain; echo) #[fg=green]|"

# Define right statusbar lenght
set -g status-right-length 60
# Show value of logged on users, how much RAM is free and clock currently activated
set -g status-right "#[fg=green]| #[fg=yellow]Users:#[fg=brightred]#(who | wc -l)#[fg=green] - #[fg=yellow]Mem:#[fg=brightred]#(free -m | awk '/Mem:/ {print $4}')#[fg=yellow]MB Free#[fg=green] - #[fg=yellow]Use:#[fg=brightred]#(df -m /var | tail -1 | awk '{print $5}')#[fg=yellow]in /var "
# Center window tabs
set -g status-justify centre
#

# Colorize active pane
set-option -g pane-active-border-fg blue
#

## End tmux.conf

EOF
}

## Start installer
# Installer menu
while true
do

    # Choose installation
    clear;
    echo "+----------------------------------------------------------------------+                 ";
    echo "|               Welcome to Tmux on IPFire installation                 |                 ";
    echo "+----------------------------------------------------------------------+                 ";
    echo;
    echo -e "    If you want to install network template press    \033[1;36m'n'\033[0m and [ENTER] ";
    echo -e "    If you want to install hardware template press   \033[1;36m'h'\033[0m and [ENTER] ";
    echo -e "    If you want to uninstall Tmux installation press \033[1;36m'u'\033[0m and [ENTER] ";
    echo;
    echo    "+----------------------------------------------------------------------+";
    echo -e "      If you want to quit this installation press    \033[1;36m'q'\033[0m and [ENTER] ";
    echo    "+----------------------------------------------------------------------+";
    echo;
    read choice
    clear;

    case ${choice} in
        n*|N*)

            ## Start installer
            clear;
            echo "Check for needed Addons... ";
            echo;
            sleep 3;
            if [[ ! -e ${BWM} || ! -e ${IFT} || ! -e ${MTR} || ! -e ${IPT} || ! -e ${TMUX} ]]; then
                pakfire install bwm-ng iftop mtr iptraf-ng tmux;
            fi

            # Check for session, pane and window arranger script
            if [[ -e "${SCRIPT}" ]]; then
                echo;
                read -p "If you want to backUP your existing mux script press 'y' and [ENTER]. If you want to overwrite it press '"n"' and [ENTER]: " answer
                case $answer in
                    y)
                        echo;
                        clear;
                        echo "Will backUP existing mux script under /usr/bin... ";
                        echo;
                        cp -v ${SCRIPT} ${SCRIPT}.bck_${date};
                    ;;
       
                    n)
                        echo;
                        echo "Will overwrite mux script under /usr/bin... ";
                        echo;
                        sleep 5;
                    ;;
                esac
            fi

            # Copy script into file
            cat > ${SCRIPT} << "EOF"
#!/bin/bash -

#
# Example script has been taken from ubuntu wiki
# http://wiki.ubuntuusers.de/tmux
####################################################
# With a litle modification from ummeegge 17.01.2014
#

SESSION=main
tmux="tmux -f /root/.tmux.conf"

# if the session is already running, just attach to it.
$tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
       echo "Session $SESSION already exists. Attaching."
       sleep 1
       $tmux attach -t $SESSION
       exit 0;
fi
                                 
# create a new session, named $SESSION, and detach from it
$tmux new-session   -d -s $SESSION
# Window 0
$tmux new-window    -t $SESSION:0
$tmux rename-window 'TrafficCheck'

# Window 1
$tmux split-window -d -t 0 -v
$tmux split-window -d -t 1 -h

$tmux send-keys -t 0 'iftop' enter C-1
$tmux send-keys -t 1 'mtr 8.8.8.8' enter C-1
$tmux send-keys -t 2 'bwm-ng' enter C-1

# Window 2
$tmux new-window    -t $SESSION:1
$tmux rename-window 'TmuxYourself;-)'

$tmux split-window -d -t 0 -v
$tmux split-window -d -t 1 -h
$tmux split-window -d -t 0 -h

# Window 3
$tmux new-window    -t $SESSION:2
$tmux rename-window 'IPTraf-ng'
$tmux send-keys -t $SESSION:2 'iptraf-ng' enter C-1

# Select entry window
$tmux select-window -t $SESSION:0
$tmux attach -t $SESSION

## End of tmux script

EOF

            # Make mux executable
            chmod +x ${SCRIPT};
            # bashrc entry
            bashrc_funct;
            # add config
            config_funct;
            rm -rf /tmp/tmux-0;
            echo "Installer is finished now... ";
            echo;
            # Start if you´d like
            read -p "To start now mux press [ENTER] . To quit use [CTRL-c] ."
            mux;
            exit 0;
        ;;
       
        h*|H*)

            # Start hardware monitoring installer
            echo;
            echo "This is currently under development may by you ;-) ?... ";
            echo;
            sleep 3;
        ;;
       
        u*|U*)

            # Start uninstaller
            tmux kill-server;
            rm -rfv \
            "${SCRIPT}" \
            "${CONF}" \
            /tmp/tmux-*;
            mv -v ${BASH}.bckOrig ${BASH};
            read -p "To remove related Addons press 'r' and [ENTER]. To leave them in place press '"l"' and [ENTER]: " answer
                case $answer in
                    r)
                        pakfire remove iptraf-ng bwm-ng iftop mtr tmux;
                    ;;
                   
                    l)
                        echo;
                        echo "Will leave related Addons in place... ";
                        echo;
                    ;;
                   
                esac
            echo;
            echo "Uninstaller has been finished... ";
            echo;
            echo "Goodbye";
            echo;
            exit 0;
           
        ;;
       
        q*|Q*)
            echo;
            echo "Goodbye";
            echo;
            exit 0;
        ;;
       
        *)
            echo;
            echo "This option does not exist... ";
            echo;
            sleep 3;
        ;;
       
    esac
done

## End of Tmux script and config installer
