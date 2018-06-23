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