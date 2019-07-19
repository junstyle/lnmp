# .bashrc

# User specific aliases and functions

alias rm='rm -i'
#alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

PS1="\[\e[32m\][\u@\h \w]$\[\e[m\]"
export PS1
export HISTCONTROL=ignoredups:erasedups:ignorespace


# format history
# save in ~/.bashrc
# 解决不同session中history丢失的问题
USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`

export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  `whoami`@${USER_IP}: "
export HISTFILESIZE=20000 #history条数
export PROMPT_COMMAND="history -a; history -r;  $PROMPT_COMMAND"
shopt -s histappend
# bind '"\e[A": history-search-backward'
# bind '"\e[B": history-search-forward'
# ---------------------


#extract file
exfile () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1        ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1       ;;
      *.rar)       rar x $1     ;;
      *.gz)        gunzip $1     ;;
      *.tar)       tar xf $1        ;;
      *.tbz2)      tar xjf $1      ;;
      *.tgz)       tar xzf $1       ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1    ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

setp_mysql () {
    chown -R mysql:mysql $1
    chmod -R 660 $1
    chmod 700 $1
}

setp_www () {
    chown -R www:www $1
    if [ -z $2 ]; then
        chmod -R 644 $1
    else
        chmod -R $2 $1
    fi
}

togbk () {
    while read line ; do
        echo "$line" | iconv -f utf-8 -t gbk
    done
}

toutf8 () {
    while read line ; do
        echo "$line" | iconv -f gbk -t utf-8
    done
}

vstart () {
    systemctl start $*
    systemctl status $* &
}

vstart2 () {
    systemctl start $* && journalctl -fexu $*
}

vstop () {
    systemctl stop $*
    systemctl status $* &
}

vrestart () {
    if [ $1 = nginx ]; then
        nginx -t
        if [[ $? == 1 ]]; then
            exit 1
        fi
    fi
    systemctl restart $*
    systemctl status $* &
}

vreload () {
    systemctl reload $*
    systemctl status $* &
}

vstatus () {
    systemctl status $*
}


# mysql
# args:  username  pwd  database
create_mysql_user () {
    if [ x$4 != x ]; then
        client=$4  #有传入访问主机
    else
        client="localhost"
    fi
    mysql --verbose -uroot -p -e "create USER '$1'@'$4' IDENTIFIED WITH mysql_native_password BY '$2'; GRANT SELECT, INSERT, UPDATE, DELETE ON $3.* TO '$1'@'$4'; flush privileges;"
}

# args: keywords ...
keycolor () {
    while read line ; do
        for key in $*
        do
            # perl -pe 's/(关键词1)|(关键词2)|(关键词3)/\e[1;颜色1$1\e[0m\e[1;颜色2$2\e[0m\e[1;颜色3$3\e[0m/g'
            # perl -pe 's/(DEBUG)|(INFO)|(ERROR)/\e[1;34m$1\e[0m\e[1;33m$2\e[0m\e[1;31m$3\e[0m/g'
            line=`echo $line | perl -pe "s/($key)/\e[1;31m$key\e[0m/g"`
        done
        echo $line
    done
}

# block ip
# args: 121.0.0.0/8  8.3.3.3
blockip () {
    iptables -I INPUT -s $1 -j DROP
    service iptables save
}

# deblock ip
# args: 121.0.0.0/8  8.3.3.3
deblockip () {
    iptables -D INPUT -s $1 -j DROP
    service iptables save
}