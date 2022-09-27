curl_opts="-s"
[[ -n "${args[--debug]}" ]] && {
  set -x
  curl_opts="-v ${curl_opts}"
}

[[ -n "${args[--name]}" ]] && {
  confirm "$(yellow [???]) delete the emoji named $(bold :${args[--name]}:) from the target workspace $(bold ${args[--workspace-domain]})? [y/N]" || {
    exit 0
  }

  echo -n "$(green [INF]) removing $(bold :${args[--name]}:) from workspace ... "

  [[ -n ${args[--dry-run]} ]] && {
    echo 'skipping!'
    exit 0
  } 

  result=$(
    curl ${curl_opts} --compressed "https://${args[--workspace-domain]}.slack.com/api/emoji.remove" \
      -H 'content-type: multipart/form-data' \
      -H "cookie: d=${args[--cookie]};" \
      -F "name=${args[--name]}" \
      -F "token=${args[--token]}"
  )

  if [[ $(echo "${result}" | jq -r ".ok") == false ]]; then
    red ' error!'
    error=$(echo "${result}" | jq -r ".error")
    echo "$(red_bold [ERR]) delete failed: ${error}"
  else
    echo ' deleted!'
  fi

  echo "$(green [INF]) all done; exiting ..."
  exit 0
}

field_user_ids=
[[ -n "${args[--user-id]}" ]] && {
  user_ids=(${args[--user-id]})
  field_user_ids=$(join , "${user_ids[@]}")
}

field_queries=
[[ -n "${args[--query]}" ]] && {
  queries=(${args[--query]})
  field_queries=$(join , "${queries[@]}")
}

to_delete=()
page_current=1
while true; do
  result=$(
    curl ${curl_opts} "https://${args[--workspace-domain]}.slack.com/api/emoji.adminList" \
      -H 'content-type: multipart/form-data' \
      -H "cookie: d=${args[--cookie]};" \
      -F "token=${args[--token]}" \
      -F "page=${page_current}" \
      -F "count=${args[--count]}" \
      -F "user_ids=[${field_user_ids}]" \
      -F "queries=[${field_queries}]"
  )

  [[ $(echo "${result}" | jq -r ".ok") == false ]] && {
    error=$(echo "${result}" | jq -r ".error")
    echo "$(red_bold [ERR]) request could not be completed: ${error}"
    exit 1
  }

  page_total=$(echo "${result}" | jq -r '.paging.pages')

  echo -n "$(green [INF]) fetching emojis from page $(bold ${page_current}) of $(bold ${page_total})..."
  for emoji in $(echo "${result}" | jq -r '.emoji[] | select(.is_alias == 0) | .name'); do
    to_delete+=("${emoji}")
  done 

  echo ' done!'

  [[ "${page_current}" -ge "${page_total}" ]] && {
    echo "$(green [INF]) finished paging through results; moving on ..."
    break
  }

  ((page_current++))
done

[[ "${#to_delete[@]}" == 0 ]] && {
  echo "$(red_bold [ERR]) could not find any matching emojis; exiting ..."
  exit 1
}

confirm "$(yellow [???]) start deleting $(bold ${#to_delete[@]}) emoji(s) from the target workspace $(bold ${args[--workspace-domain]})? [y/N]" || {
  exit 0
}

for emoji in "${to_delete[@]}"; do
  [[ -z "${args[--nuke-from-orbit]}" ]] && {
    confirm "$(yellow [???]) are you sure you want to delete $(bold :${emoji}:) from the target workspace $(bold ${args[--workspace-domain]})? [y/N]" ]] || {
      continue
    }
  }

  echo -n "$(green [INF]) deleting $(bold :${emoji}:) ..."
  
  result=$(
    curl ${curl_opts} "https://${args[--workspace-domain]}.slack.com/api/emoji.remove" \
      -H "cookie: d=${args[--cookie]};" \
      -F "token=${args[--token]}" \
      -F "name=${emoji}"
  )

  if [[ $(echo "${result}" | jq -r ".ok") == false ]]; then
    red ' error!'
    error=$(echo "${result}" | jq -r ".error")
    echo "$(red_bold [ERR]) delete failed: ${error}"
  fi

  echo ' deleted!'
done

echo "$(green [INF]) all done; exiting ..."
exit 0