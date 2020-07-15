#!/bin/bash
##################################
# 【スクリプト説明】
#   スラック通知を行うスクリプト
# 【引数】
#   -c：sending channel
#   -m：sending massage
#   -i：sending icon
#   -u：sending user name
#   -h or --help：help
##################################

##################################
# define
##################################
# デフォルト値
URL='https://slack.com/api/chat.postMessage'
TOKEN="認証トークン"
username="通知bot"
channel="#10_solution"
massege="Botからの送信です。"

##################################
# function
##################################
usage() {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h or --help         Display help
  -c or --channel VALUE    Destination channel setting (default: #10_solution)
  -m or --massege VALUE    Destination massege setting (default: "Botからの送信です。")
  -i or --icon    VALUE    Destination icon setting
  -u or --user    VALUE    Destination user name setting (default: "通知bot")
EOM

  exit 2
}

##################################
# Main
##################################
# 引数別の処理定義
while getopts "h:c:m:u:i:-:" optkey; do
  optarg="$OPTARG"
  if [[ "$optkey" = - ]]; then
      optkey="-${OPTARG%%=*}"
      optarg="${OPTARG/${OPTARG%%=*}/}"
      optarg="${optarg#=}"

      if [[ -z "$optarg" ]] && [[ ! "${!OPTIND}" = -* ]]; then
          optarg="${!OPTIND}"
          shift
      fi
  fi

  case "$optkey" in
    'c'|'-channel')
      channel=$optarg
      ;;
    'm'|'-massege')
      massege=$optarg
      ;;
    'u'|'-user')
      username=$optarg
      ;;
    'i'|'-icon')
      icon_emoji=$optarg
      ;;
    '-h'|'-help'|* )
      usage
      ;;
  esac
done

# 問い合わせ
curl -XPOST "$URL" -d "token=$TOKEN" -d "channel=$channel" -d "text=$massege" -d "username=$username" -d "icon_emoji=$icon_emoji"
