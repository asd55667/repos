#! /bin/bash
source ./utils.sh

# print env file
echo_blue "Env file is: $ENV_FILE"
echo_blue "Repo's Directory is: $REPOS_DIR"

# parse IGNORES to array
IGNORES_ARR=(${IGNORES//,/ })
echo_blue "Ignored repos array: ${IGNORES_ARR[@]}, length: ${#IGNORES_ARR[@]}"

# Get all repo names
REPOS=$(ls $REPOS_DIR)

# Get all repo names except ignored ones
REPOS_EXCEPT_IGNORES=()
for repo in $REPOS; do
  # if repo is not a directory, then continue
  if [[ ! -d $REPOS_DIR/$repo ]]; then
    continue
  fi

  # if repo is not in IGNORES_ARR, then add it to REPOS_EXCEPT_IGNORES
  if [[ ! " ${IGNORES_ARR[@]} " =~ " ${repo} " ]]; then
    REPOS_EXCEPT_IGNORES+=($repo)
  fi
done


# csv file's column: repo,remote
# load the remote column to array from csv file and drop column header
REPO_REMOTES=($(cat $REPO_INFO_FILE | awk -F ',' '{ print $2 }' | sed '1d'))
REPO_NAMES=($(cat $REPO_INFO_FILE | awk -F ',' '{ print $1 }' | sed '1d'))
echo_blue "Length of recorded repos: ${#REPO_REMOTES[@]}"


REPO_TO_REMOVE=()

# get each repo's remote and check whether it already exists in csv file
# if not, then add it to csv file, print the number of added repos
ADDED_REPOS=()
for repo in ${REPOS_EXCEPT_IGNORES[@]}; do
  cd $REPOS_DIR/$repo || continue
  REMOTE=$(git remote -v | grep fetch | awk '{ print $2 }')

  # only accpet remote from github.com
  if [[ $REMOTE != *"github.com"* ]]; then
    continue
  fi

  # if repo's remote not exists in csv file, then add it to csv file
  if [[ ! " ${REPO_REMOTES[@]} " =~ " ${REMOTE} " ]]; then
    # mark the repo whose remote changed
    if [[ " ${REPO_NAMES[@]} " =~ " ${repo} " ]]; then
      echo_green "Repo $repo already exists in csv file, delete it"
      REPO_TO_REMOVE+=($repo)
    fi
    
    # add the repo to csv file
    echo "$repo,$REMOTE" >> $REPO_INFO_FILE
    ADDED_REPOS+=($repo)
  fi
done

echo_blue "Repos to remove: ${REPO_TO_REMOVE[@]}"
# delete repo from csv file
CSV=$(cat $REPO_INFO_FILE)
for (( i = 0; i < ${#REPO_TO_REMOVE[@]}; i++ )); do
  repo=${REPO_TO_REMOVE[$i]}
  echo_green "delete repo $repo from csv file"
  # get the first line number of the line that repo start with in csv file
  line=$(echo "$CSV" | grep -n "^$repo" | awk -F ':' '{ print $1 }' | head -n 1)
  # echo "line: $line"
  # susbstitute the line with empty string with sed
  CSV=$(echo "$CSV" | sed "$line s/.*//g")
done
# replace \n\n with \n in $CSV
CSV=$(echo "$CSV" | sed '/^$/d')

# write csv file
echo "$CSV" > $REPO_INFO_FILE

# print all added repos line by line
for repo in ${ADDED_REPOS[@]}; do
  echo_green "$repo"
done
echo_green "Added repos count: ${#ADDED_REPOS[@]}"