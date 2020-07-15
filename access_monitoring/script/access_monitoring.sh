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
logger() {
  $LOGGER_SCRIPT -f $TAGET_LOG_FILE -t "$1"
}

access_monitoring () {

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
  logger "Start http request to $1"
  status_code=`curl -LI -m 60 $url -o /dev/null -w '%{http_code}\n' -s`
  logger "End http request to $1"

  if [ 200 -ne $status_code ]; then
    # 接続不良が多々あるためリクエストのリトライを行う。
    logger "Retry HTTP request to $1"
    # curlのステータスコードではなくレスポンスヘッダのステータスコードを取得する。
    retry_result=`curl -m 60 -sS -v -o /dev/null $url 2>&1`
    status_code=`echo "$retry_result" | grep -e '^HTTP' | awk '{print $2}'`

    if [[ -z "$status_code" ]] || [[ 200 -ne $status_code ]]; then
      error_header=`echo "$retry_result" | sed '$d'`
      error_massage=`echo "$retry_result" | grep -e "curl: ("`
      error_netstat=`netstat -nap|grep 443`
      error_traceroute=`traceroute -p 443 $url`
      logger "error occurred in $1"
      logger "error response header \n $error_massage\n$error_header"
      logger "netstat \n $error_netstat"
      logger "traceroute \n $error_traceroute"

      # 深夜〜朝までは通知時にメンションを行わない（深夜開始時刻 > now && now > 朝の終了時刻）
      massage=`echo "$SEND_MASSAGE_TMPLATE" | sed "s|url|$url|" | sed "s|status_code|$status_code|" | sed "s|error_massage|$error_massage|"`
      if [[ $NOTIFICATION_START_OFF_HOUR_TIME -gt $NOW_TIME_HOUR ]] && [[ $NOW_TIME_HOUR -gt $NOTIFICATION_END_OFF_HOUR_TIME ]]; then
        massage=`echo -e "$SEND_MENTION \n$SEND_MASSAGE_TMPLATE" | sed "s|url|$url|" | sed "s|status_code|$status_code|" | sed "s|error_massage|$error_massage|"`
      fi

      # 通知条件は当日の1時間前後以内にエラーが発生していた場合に通知を行う。
      before_hour=`date "+%Y/%m/%d %H" -d '1 hour ago'`
      now_hour=`date "+%Y/%m/%d %H"`
      is_error=`grep -n "error occurred in $1" $TAGET_LOG_FILE | grep -e "$before_hour" -e "$now_hour"`
      if [[ -n $is_error ]]; then
        $NOTIFICATION_SCRIPT -c $SEND_CHANNEL -u $SEND_USER_NAME -m "$massage" -i $SEND_ICON_NAME
        return 2
      fi
    fi
  fi
  return 1
}

##################################
# Main
##################################
logger 'Start access monitoring process'
# スタジオの稼働確認
access_monitoring  'STDIO'
# incの稼働確認
access_monitoring 'INC'
# ソリューションの稼働確認
access_monitoring 'SOLUTION'
# 異常系テスト用
access_monitoring '異常系'
logger 'End access monitoring process'
