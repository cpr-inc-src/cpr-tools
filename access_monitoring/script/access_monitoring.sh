#!/bin/bash
##################################
# 【スクリプト説明】
#   CPR内サイトのダウン監視スクリプト
# 【引数】
#   なし
##################################

##################################
# define
##################################
SCRIPT_DIR=$(cd $(dirname $0); pwd)
source $SCRIPT_DIR/../conf/access_monitoring_conf.sh

##################################
# function
##################################
function access_monitoring () {

  # 変数の初期化
  unset url
  unset error_massage

  # 引数に応じて問い合わせ先を変更する。
  case $1 in
  STDIO)
      url=$STDIO_URL
      ;;
  INC)
      url=$INC_URL
      ;;
  SOLUTION)
      url=$SOLUTION_URL
      ;;
  esac

  # 想定している引数ではない場合に返却
  if [ -z "$url" ]; then
    return 2
  fi

  # 問い合わせ
  status_code=`curl -LI -m 45 $url -o /dev/null -w '%{http_code}\n' -s`
#  if [ 200 -ne $status_code ]; then
    error_massage=`curl -LI -m 45 $url -sS -o /dev/null 2>&1`
    echo $error_massage
    massage=`echo "$SEND_MASSAGE_TMPLATE" | sed "s|url|$url|" | sed "s|status_code|$status_code|" | sed "s|error_massage|$error_massage|"`
    $NOTIFICATION_SCRIPT -c $SEND_CHANNEL -u $SEND_USER_NAME -m "$massage" -i $SEND_ICON_NAME
#    return 2
#  fi
  return 1
}

##################################
# Main
##################################
# スタジオの稼働確認
access_monitoring  'STDIO'
# incの稼働確認
access_monitoring 'INC'
# ソリューションの稼働確認
access_monitoring 'SOLUTION'
# 異常系テスト用
access_monitoring '異常系'
