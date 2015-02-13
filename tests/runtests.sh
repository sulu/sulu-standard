#!/bin/bash

SUITES=${BEHAT_SUITES:-""}
PROFILE=${BEHAT_PROFILE:-"selenium"}
LOGS_PATH=${LOGS_DIR:-"/tmp/sulu"}

source "$(dirname "$0")""/../vendor/sulu/sulu/bin/inc/runtestcommon.inc.sh"
if [ -e /tmp/failed.tests ]; then
    rm /tmp/failed.tests
fi
touch /tmp/failed.tests

logo

header "Sulu CMF Functional Test Suite"


info "Running Behat with profile \""$PROFILE"\" and suites: \"$SUITES\""

for SUITE in $SUITES; do
    comment "Running suite: "$SUITE
    NAME="Suite: "$SUITE

    if [ $PROFILE == 'sauce_labs' ]; then
        export BEHAT_PARAMS='{"extensions":{"Behat\\MinkExtension":{ "sessions":{ "default":{"sauce_labs":{"capabilities":{"name": "'$NAME'"}}}}}}}'
    else
        export BEHAT_PARAMS=
    fi

    php vendor/behat/behat/bin/behat --profile $PROFILE --suite="$SUITE"

    if [ $? -ne 0 ]; then
        echo $SUITE >> /tmp/failed.tests
    fi
    echo ""
done

check_failed_tests
