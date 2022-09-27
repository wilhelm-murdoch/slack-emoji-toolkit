curl_opts="-s"
[[ -n "${args[--debug]}" ]] && {
  set -x
  curl_opts="-v ${curl_opts}"
}

images=$(find "${args[--source]}" -iname \*.gif -o -iname \*.png -o -iname \*.png -maxdepth 1)
[[ "${images}" == "" ]] && {
  echo "$(red_bold [ERR]) the specified directory ${args[--source]} contains no images; exiting ..."
  exit 0
}

images_count=$(echo "${images}" | wc -l | tr -d ' ')
confirm "Upload $(bold ${images_count}) image(s) to the target workspace $(bold ${args[--workspace-domain]})? [y/N]" || {
  exit 0
}

echo "${images}" | while read -r path; do 
  name=$(basename "${path%.*}")

  echo -n "$(green [INF]) uploading $(bold ${path}) as $(bold :${args[--prefix]}${name}${args[--suffix]}:) ... "

  [[ -n ${args[--dry-run]} ]] && {
    echo 'skipping!'
    continue
  } 

  result=$(
    curl ${curl_opts} --compressed "https://${args[--workspace-domain]}.slack.com/api/emoji.add" \
      -H 'content-type: multipart/form-data' \
      -H "cookie: d=${args[--cookie]};" \
      -F "token=${args[--token]}" \
      -F "name=${args[--prefix]}${name}${args[--suffix]}" \
      -F mode=data \
      -F "image=@${path}" 
  )

  if [[ $(echo "${result}" | jq -r ".ok") == false ]]; then
    red "error!"
    error=$(echo "${result}" | jq -r ".error")
    echo "$(red_bold [ERR]) upload failed: ${error}"
  else
    echo 'done!'
  fi
done

echo "$(green [INF]) all done; exiting ..."
exit 0