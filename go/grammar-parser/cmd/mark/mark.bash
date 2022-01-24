#!/bin/bash

export black=$'\e[30m'
export red=$'\e[31m'
export green=$'\e[32m'
export yellow=$'\e[33m'
export blue=$'\e[34m'
export magenta=$'\e[35m'
export cyan=$'\e[36m'
export white=$'\e[37m'
export reset=$'\e[0m'

export md_strongem=$red       #  ***strongem***
export md_strong=$yellow      #  **strong**
export md_emphasis=$magenta   #  *emphasis*
export md_code=$cyan          #  `code`
export md_plain=''            #  plain

mark () {
  declare inemphasis instrong instrongem incode indquote inquote inlink i

  # The main content is almost always within single quotes to prevent
  # shell expansions, but we'll combine the remaining arguments anyway for
  # convenience (like echo does).

  declare buf=$*

  # Recursive descent parser

  for (( i=0; i<${#buf}; i++ )); do 

    if [[ -z "$instrongem" &&
          -z "$instrong" && 
          -z "$inemphasis" &&
          -z "$incode" ]]; then
      echo -n "$reset"
    fi

    # ***strongem***

    if [[ "${buf:$i:3}" = '***' ]]; then
      if [[ -z "$instrongem" ]]; then
        echo -n "$md_strongem"
        #echo -n '<strongem>'
        instrongem=1
      else
        #echo -n '</strongem>'
        echo -n $defsol
        instrongem=''
      fi
      i=$[i+2]
      continue
    fi

    # **strong**

    if [[ "${buf:$i:2}" = '**' ]]; then
      if [[ -z "$instrong" ]]; then
        echo -n "$md_strong"
        #echo -n '<strong>'
        instrong=y
      else
        #echo -n '</strong>'
        echo -n $defsol
        instrong=''
      fi
      i=$[i+1]
      continue
    fi

    # *emphasis*

    if [[ "${buf:$i:1}" = '*' ]]; then
      if [[ -z "$inemphasis" ]]; then
        echo -n "$md_emphasis"
        #echo -n '<emphasis>'
        inemphasis=y
      else
        #echo -n '</emphasis>'
        echo -n $defsol
        inemphasis=''
      fi
      continue
    fi

    # `code`

    if [[ "${buf:$i:1}" = '`' ]]; then
      if [[ -z "$incode" ]]; then
        echo -n "$md_code"
        #echo -n '<code>'
        incode=y
      else
        #echo -n '</code>'
        echo -n $defsol
        incode=''
      fi
      continue
    fi

    # "

    if [[ "${buf:$i:1}" = '"' ]]; then
      if [[ -z "$indquote" ]]; then
        echo -n '“'
        indquote=y
      else
        echo -n '”'
        indquote=''
      fi
      continue
    fi

    # ' 

    if [[ "${buf:$i:1}" = "'" ]]; then
      if [[ -z "$inquote" ]]; then
        echo -n '‘'
        inquote=y
      else
        echo -n '’'
        inquote=''
      fi
      continue
    fi

    # <-

    if [[ "${buf:$i:4}" = ' <- ' ]]; then
      echo -n " ← "
      i=$[i+3]
      continue
    fi

    # ->

    if [[ "${buf:$i:4}" = ' -> ' ]]; then
      echo -n " → "
      i=$[i+3]
      continue
    fi

    # ...
    
    if [[ "${buf:$i:3}" = '...' ]]; then
      echo -n "…"
      i=$[i+2]
      continue
    fi

    # <link>

    if [[ "${buf:$i:1}" = '<' ]]; then
      if [[ -z "$inlink" ]]; then
        echo -n $md_code${buf:$i:1}
        #echo -n '<link>'
        inlink=y
      fi
      continue
    fi
    if [[ "${buf:$i:1}" = '>' ]]; then
      if [[ -n "$inlink" ]]; then
        #echo -n '</link>'
        echo -n ${buf:$i:1}$defsol
        inlink=''
      fi
      continue
    fi

    echo -n "${buf:$i:1}"
  done
  echo -n $reset
}

mark "$@"
