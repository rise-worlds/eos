#!/usr/bin/env bats
load helpers/general

SCRIPT_LOCATION="scripts/eosio_uninstall.sh"
TEST_LABEL="[eosio_uninstall]"

mkdir -p $SRC_DIR
mkdir -p $OPT_DIR
mkdir -p $VAR_DIR
mkdir -p $BIN_DIR
mkdir -p $VAR_DIR/log
mkdir -p $ETC_DIR
mkdir -p $LIB_DIR
mkdir -p $MONGODB_LOG_DIR
mkdir -p $MONGODB_DATA_DIR

# A helper function is available to show output and status: `debug`

@test "${TEST_LABEL} > Usage is visible with right interaction" {
  run ./$SCRIPT_LOCATION -help
  [[ $output =~ "Usage ---" ]] || exit
  run ./$SCRIPT_LOCATION --help
  [[ $output =~ "Usage ---" ]] || exit
  run ./$SCRIPT_LOCATION help
  [[ $output =~ "Usage ---" ]] || exit
  run ./$SCRIPT_LOCATION blah
  [[ $output =~ "Usage ---" ]] || exit
}

@test "${TEST_LABEL} > Testing user prompts" {
  ## No y or no warning and re-prompt
  run bash -c "echo -e \"\nx\nx\nx\" | ./$SCRIPT_LOCATION"
  ( [[ "${lines[${#lines[@]}-1]}" == "Please type 'y' for yes or 'n' for no." ]] && [[ "${lines[${#lines[@]}-2]}" == "Please type 'y' for yes or 'n' for no." ]] ) || exit
  ## All yes pass
  run bash -c "printf \"y\n%.0s\" {1..100} | ./$SCRIPT_LOCATION"
  [[ "${output##*$'\n'}" == "[EOSIO Removal Complete]" ]] || exit
  ## First no shows "Cancelled..."
  run bash -c "echo \"n\" | ./$SCRIPT_LOCATION"
  [[ "${output##*$'\n'}" =~ "Cancelled EOSIO Removal!" ]] || exit
  ## What would you like to do?"
  run bash -c "echo \"\" | ./$SCRIPT_LOCATION"
  [[ "${output##*$'\n'}" =~ "What would you like to do?" ]] || exit
}

@test "${TEST_LABEL} > Testing executions" {
  run bash -c "printf \"y\n%.0s\" {1..100} | ./$SCRIPT_LOCATION"
  ### Make sure deps are loaded properly
  [[ "${output}" =~ "Executing: rm -rf" ]] || exit
  [[ $ARCH == "Darwin" ]] && ( [[ "${output}" =~ "Executing: brew uninstall cmake --force" ]] || exit )
}


@test "${TEST_LABEL} > --force" {
  run ./$SCRIPT_LOCATION --force
  # Make sure we reach the end
  [[ "${output##*$'\n'}" == "[EOSIO Removal Complete]" ]] || exit
}

@test "${TEST_LABEL} > --force + --full" {
  run ./$SCRIPT_LOCATION --force --full
  ([[ ! "${output[*]}" =~ "Library/Application\ Support/eosio" ]] && [[ ! "${output[*]}" =~ ".local/share/eosio" ]]) && exit
  [[ "${output##*$'\n'}" == "[EOSIO Removal Complete]" ]] || exit
}

rm -rf $SRC_DIR
rm -rf $OPT_DIR
rm -rf $VAR_DIR
rm -rf $BIN_DIR
rm -rf $VAR_DIR/log
rm -rf $ETC_DIR
rm -rf $LIB_DIR
rm -rf $MONGODB_LOG_DIR
rm -rf $MONGODB_DATA_DIR