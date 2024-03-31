#!/bin/bash

# 检查输入参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

# 检查文件是否存在
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found."
    exit 1
fi

if [ -f "./error.csv" ]; then
    echo "error.csv exist."
    exit 1
fi

# 读取CSV文件，并乱序保存
g_tmp_file="./tmp.csv"
cat ${1} | tail -n +2 | grep -E "^[0-9]*,"| sort -r > "${g_tmp_file}"

# 计算单词总数
g_total_words=$(cat ${g_tmp_file} | wc -l | sed "s/ //g")
# 计算单词剩余数
g_last=${g_total_words}

check_word()
{
    continent=${1}
    _english=$(echo "${continent}" | cut -d"," -f2)
    _chinese=$(echo "${continent}" | cut -d"," -f3)

    clear
    echo "剩余：${g_last}"
    if [ ! -z "${last_one}" ]; then
        echo "上一条：${last_one}"
    fi
    echo "中文释义：${_chinese}"
    read -p "请输入对应的英文单词：" input_word

    if [ "$input_word" == "${_english}" ]; then
        echo "正确！"
        last_one=${continent}
        return 0
    else
        if [ "$input_word" == "+1" ]; then
            echo "${last_one}" >> ./error.csv
            check_word ${1}
        fi
        echo "错误！正确答案是：${_english}"
        if [ "$input_word" != "" ]; then
            sleep 5
        fi
        return 1
    fi
}

# 乱序以防止肌肉记忆
g_error_flag=0
for _i in $(seq 1 ${g_total_words}); do
    line=$(cat "${g_tmp_file}" | head -n ${_i} | tail -n 1)
    while true; do
        check_word "${line}"
        if [ $? -eq 0 ]; then
            g_last=$((g_last-1))
            g_error_flag=0
            break
        else
            if [ ${g_error_flag} -eq 0 ]; then
                echo "${line}" >> ./error.csv
                g_error_flag=1
            fi
            continue
        fi
    done
done
