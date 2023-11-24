SUFFIX=$(echo $1 | awk '{ print tolower($1) }')

ENV_FILE=".env.local"
if [[ $SUFFIX != "" ]]; then
  ENV_FILE=".env.$SUFFIX"
fi
source $ENV_FILE

function echo_blue {
  echo "\033[36m$*\033[0m"
}
function echo_green {
  echo "\033[32m$*\033[0m"
}

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

# get each repo's info which include git remote,
# and then write to file with column: repo,remote
echo_blue "Start to write repo info to file: $REPO_INFO_FILE"
echo "Repo,Remote" > $REPO_INFO_FILE
for repo in ${REPOS_EXCEPT_IGNORES[@]}; do
  cd $REPOS_DIR/$repo || continue
  REMOTE=$(git remote -v | grep fetch | awk '{ print $2 }')

  # only accpet remote from github.com
  if [[ $REMOTE != *"github.com"* ]]; then
    continue
  fi
  echo "$repo,$REMOTE" >> $REPO_INFO_FILE
done

echo_green "Write repo info to file: $REPO_INFO_FILE successfully"