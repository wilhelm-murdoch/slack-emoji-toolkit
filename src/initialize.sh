set -eo pipefail

if ! command -v "jq" &> /dev/null; then
  echo "$(red_bold [ERR]) jq could not be located. Install using the relevant command:"
  echo "$(red_bold [ERR])   MacOS: $ brew update && brew install jq"
  echo "$(red_bold [ERR])   Linux: $ apt-get install jq"
  exit 1
fi