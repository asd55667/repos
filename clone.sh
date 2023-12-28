#! /bin/bash
source ./utils.sh

N_THREAD=$(echo $1 | awk '{ print tolower($1) }')

if [[ $N_THREAD == "" ]]; then
  N_THREAD=1
fi

echo_blue "CSV file is: $REPO_INFO_FILE"
echo_blue "Repo's Directory is: $REPOS_DIR"

# csv file's column: repo,remote
# load the repo column to array from csv file and drop column header
REPOS=($(cat $REPO_INFO_FILE | awk -F ',' '{ print $1 }' | sed '1d'))
# load the remote column to array from csv file and drop column header
REPOS_REMOTE=($(cat $REPO_INFO_FILE | awk -F ',' '{ print $2 }' | sed '1d'))


# the repo needed to clone where in REPOS but not in REPOS_DIR
REPOS_TO_CLONE=()
REMOTE_TO_CLONE=()

# check if the repo is in REPOS_DIR
for ((i=0; i<${#REPOS[@]}; i++)); do
  if [[ ! -d "$REPOS_DIR/${REPOS[$i]}" ]]; then
    REPOS_TO_CLONE+=(${REPOS[$i]})
    REMOTE_TO_CLONE+=(${REPOS_REMOTE[$i]})
  fi
done

# exit if no repo needed to clone
if [[ ${#REPOS_TO_CLONE[@]} == 0 ]]; then
  echo_green "No repo needed to clone"
  exit 0
fi

echo_blue "Repos to clone: ${REPOS_TO_CLONE[@]}"

# clone repos with --depth 1 with N_THREAD threads
for ((i=0; i<${#REPOS_TO_CLONE[@]}; i++)); do
  if [[ $((i % N_THREAD)) == 0 ]]; then
    wait
  fi
  repo=${REPOS_TO_CLONE[$i]}
  REMOTE=${REMOTE_TO_CLONE[$i]}
  echo_blue "Cloning $repo from $REMOTE"
  git clone --depth 1 $REMOTE $REPOS_DIR/$repo &
done


