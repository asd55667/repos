#! /bin/bash
set -e

function echo_blue {
  echo -e "\033[36m $* \033[0m"
}
function echo_green {
  echo -e "\033[32m $* \033[0m"
}
function echo_red {
  echo -e "\033[31m $* \033[0m"
}

function assert {
  if [[ $1 != $2 ]]; then
    echo_red $3
  fi
}

ENV_FILE=".env.local"
if [[ $1 != "" ]]; then
  ENV_FILE=".env.$1"
fi
source $ENV_FILE