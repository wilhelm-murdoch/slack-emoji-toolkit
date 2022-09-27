curl_opts="-s"
[[ -n "${args[--debug]}" ]] && {
  set -x
  curl_opts="-v ${curl_opts}"
}

payload=$(
  jq -nc \
    --arg     token "${args[--token]}" \
    --argjson count "${args[--count]}" \
    '{
      token: $token, 
      count: $count
    }'
)

while true; do
  result=$(
    curl ${curl_opts} --compressed "https://edgeapi.slack.com/cache/${args[--workspace-id]}/emojis/list?fp=97" \
      -H "cookie: d=${args[--cookie]};" \
      --data-raw "${payload}" 
  )

  [[ $(echo "${result}" | jq -r ".ok") == false ]] && {
    error=$(echo "${result}" | jq -r ".error")
    echo "$(red_bold [ERR]) request could not be completed: ${error}"
    exit 1
  }

  echo "${result}"  | jq -r '.results[] | select(.is_alias == null and (.value | type != "object")) | .value' | while read -r line; do 
    name=$(basename $(dirname "${line}"))
    path="${args[--destination]}/${name}.${line##*.}"
    echo -n "$(green [INF]) saving $(bold :${name}:) to $(bold ${path}) ..."
    [[ -n ${args[--dry-run]} ]] && {
      echo ' skipping!'
      continue
    }

    curl ${curl_opts} -o  "${path}" "${line}"  
    echo ' done!'
  done 

  marker=$(echo "${result}" | jq -r ".next_marker")
  [[ "${marker}" == "null" ]] && break

  payload=$(echo "${payload}" | jq --arg marker "${marker}" '. + { marker: $marker }')
done

echo "$(green [INF]) all done; exiting ..."
exit 0