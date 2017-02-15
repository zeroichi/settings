# vim: set filetype=sh :
# remove duplicated PATH entries
# src: http://ja.stackoverflow.com/questions/28268
PATH=$(echo "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')
