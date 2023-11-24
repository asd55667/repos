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
REPOS_REMOTE=($(cat $REPO_INFO_FILE | awk -F ',' '{ print $2 }' | sed '1d'))
echo_blue "Length of recorded repos: ${#REPOS_REMOTE[@]}"

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
  if [[ ! " ${REPOS_REMOTE[@]} " =~ " ${REMOTE} " ]]; then
    echo "$repo,$REMOTE" >> $REPO_INFO_FILE
    ADDED_REPOS+=($repo)
  fi
done

# print all added repos line by line
for repo in ${ADDED_REPOS[@]}; do
  echo_green "$repo"
done
echo_green "Added repos count: ${#ADDED_REPOS[@]}"