#!/bin/bash
##################################
# 【スクリプト説明】
#   CPR内サイトのダウン監視スクリプトの定義ファイル
# 【引数】
#   なし
##################################
# 各種パス
NOTIFICATION_SCRIPT=$SCRIPT_DIR/slack_notification.sh
LOGGER_SCRIPT=$SCRIPT_DIR/logger.sh

# ログ出力先
TAGET_LOG_FILE=$SCRIPT_DIR/../log/access_monitoring_conf.log

# 各種URL
STDIO_URL='https://cpr-studio.jp/'
INC_URL='https://www.cpr-inc.jp/'
SOLUTION_URL='https://www.cpr-inc.jp/solution/'

# 通知関連
NOW_TIME_HOUR=`date +%k`
NOTIFICATION_START_OFF_HOUR_TIME=22
NOTIFICATION_END_OFF_HOUR_TIME=8

SEND_CHANNEL="#access_monitoring"
SEND_ICON_NAME=":warning:"
SEND_USER_NAME="監視bot"
SEND_MENTION="@監視メンバー"
SEND_MASSAGE_TMPLATE=$(cat <<-EOD
下記サイトがサイトダウンしています。
状況確認並びに復旧対応をお願い致します。

■環境
url
■HTTPステータスコード
status_code
■エラーメッセージ
error_massage
EOD
)
