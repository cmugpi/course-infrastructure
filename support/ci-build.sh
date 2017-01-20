#!/usr/bin/env bash

shopt -s globstar

error_exit() {
  local rc=$?
  local message="$*"

  echo "${cred}[FAIL]${cnone} $message"

  exit $rc
}

success() {
  local tag="$1"
  shift
  echo "${cgreen}[$tag]${cnone} $*"
}

cred="$(echo -ne '\033[0;31m')"
cgreen="$(echo -ne '\033[0;32m')"
cnone="$(echo -ne '\033[0m')"

get_shell_files() {
  echo "Finding shell files..." 1>&2

  for file in ./*lab/src/**/* ./shared/**/* ./support/**/*; do
    if [[ $file =~ ./shared/bask/* ]]; then continue; fi

    # check for .sh ending
    if [[ "$file" =~ \.sh$ ]]; then
      # Also report to stderr so we can get a log
      echo "$file" | tee /dev/fd/2
    # check if has bash in shebang on first line, and print if so
    elif [ -f "$file" ]; then
      # Also report to stderr so we can get a log
      awk '/#!\/.*bash/ && NR < 2 { print FILENAME; }' "$file" | tee /dev/fd/2
    fi
  done

  echo "Done finding shell files." 1>&2
}

run_lab_tests() {
  for lab in ./*lab; do
    pushd "$lab" &> /dev/null

    echo "--------------------------------------------------------------------------------"
    echo "Starting tests for '$lab'"

    ./Baskfile test || return

    popd &> /dev/null
  done
}

echo -e "\nLinting files with Shellcheck..."
if ( get_shell_files | xargs shellcheck ); then
  success "OK" "Lint checks passed."
else
  error_exit "Shellcheck finished with errors"
fi

echo -e "\nRunning tests on all labs..."
if run_lab_tests; then
  success "OK" "Tests on all labs passed."
else
  error_exit "Functional lab tests failed"
fi

success "SUCCESS" "All checks passed."
