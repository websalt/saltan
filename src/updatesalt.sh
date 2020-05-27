#!/bin/bash
# A script for updating my periodic database
set -euf -o pipefail

elements=$(curl -sL 'https://raw.githubusercontent.com/Bowserinator/Periodic-Table-JSON/master/PeriodicTableJSON.json')
# elements=$(cat ~/elements.json)
polyions=$(cat polyions.json)

echo "$elements" "$polyions" | jq -s '.[0].polyatomics=.[1]|.[0]' > periodic.json
# echo "$elements" "$polyions" | jq -s '.[0].polyatomics=.[1]|.[0]'
