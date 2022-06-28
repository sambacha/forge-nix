dsn="$GITHUB_REPOSITORY"
if [ -z "$dsn" ]; then
  dsn=$(git remote get-url origin)
  dsn=${dsn#"git@github.com:"}
  dsn=${dsn#"https://github.com/"}
  dsn=${dsn%".git"}
fi

set -e

CDPATH="" cd -- "$(dirname -- "$(dirname -- "$0")")"

pids=()

for dep in $(script/bindown dependency list); do
    script/bindown validate "$dep" &
    pids+=($!)
done

exit_code=0

for pid in "${pids[@]}"; do
  wait "$pid" || exit_code=1
done

exit $exit_code