#!/bin/bash
##################################
# 【スクリプト説明】
#   スラック通知を行うスクリプト
# 【引数】
#   -h or --help            Display help
#   -f or --file   VALUE    Output target file
#   -t or --text   VALUE    Output text
##################################

##################################
# function
##################################
usage() {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h or --help            Display help
  -f or --file   VALUE    Output target file
  -t or --text   VALUE    Output text
EOM

  exit 2
}

##################################
# Main
##################################
# 引数別の処理定義
while getopts "hf:t:-:" optkey; do
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
    'f'|'-file')
      target_file=$optarg
      ;;
    't'|'-text')
      text=$optarg
      ;;
    '-h'|'-help'|* )
      usage
      ;;
  esac
done

# 引数チェック
if [[ -z "$target_file" ]] || [[ -z "$text" ]]; then
  usage
fi

# パス,ファイル名を分解する。
file=`basename $target_file`
dir=`dirname $target_file`

# 出力先のディレクトリへ移動する
cd $dir

#ファイルの存在チェック
if [[ ! -e $file ]]; then
  # 該当ファイルが存在しない場合には新規で作成する。
  echo -e "["`date "+%Y/%m/%d %H:%M:%S"`"] $text" > $file
  exit 1
fi



# ログは1日分のみテキストとして保持し、2日分を圧縮ファイルとして保持する。
lastUpDate=`date "+%Y%m%d" -r $file`
nowDate=`date "+%Y%m%d"`
if [[ "$lastUpDate" -ne "$nowDate" ]]; then
  # 最終更新日時と現在日時が異なる場合
  tar cvzf $lastUpDate"_"$file".tar.gz" $file >> /dev/null
  echo -e "["`date "+%Y/%m/%d %H:%M:%S"`"] $text" > $file
  find $dir -mtime +2 -depth 1 -name "*"$file"*"| xargs rm
else
  # 最終更新日時と現在日時が同じ場合
  echo -e "["`date "+%Y/%m/%d %H:%M:%S"`"] $text" >> $file
fi
