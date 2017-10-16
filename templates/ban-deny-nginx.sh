#!/bin/bash

HOST="/etc/nginx/conf.d/deny-hosts"
SLACK_HOOK_URL="{{ fail2ban_slack_hook }}"
SLACK_CHANNEL="{{ fail2ban_slack_channel }}"
SLACK_USERNAME="{{ fail2ban_slack_username }}"
SLACK_EMOJI="no_entry"

if [ $# -eq 0 ]
then
  echo "Usage: [un]ban <ip>"
  exit
fi

# Remove the banning IP to prevent duplicates
if [ $1 == "unban" ]
then
  if grep "$2" $HOST
  then
    sed -i "/deny $2;/d" $HOST
    /usr/sbin/service nginx reload
  else
    echo "Unbanning IP not exists!"
  fi
fi

# Add IP if `ban` action provided
if [ $1 == "ban" ]
then
  if grep "$2" $HOST
  then
    echo "Banning IP exists!"
  else
    echo "deny $2;" >> $HOST
    /usr/sbin/service nginx reload
    curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"[$3] $1 $2\", \"channel\": \"$SLACK_CHANNEL\", \"username\": \"$SLACK_USERNAME\", \"icon_emoji\": \":$SLACK_EMOJI:\"}" ${SLACK_HOOK_URL}
  fi
fi
