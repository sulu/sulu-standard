#!/bin/bash

PROFILE=${BEHAT_PROFILE:-"selenium"}
LOGS_PATH=${LOGS_DIR:-"/tmp/sulu"}

source "$(dirname "$0")""/../vendor/sulu/sulu/bin/inc/runtestcommon.inc.sh"
if [ -e /tmp/failed.tests ]; then
    rm /tmp/failed.tests
fi
touch /tmp/failed.tests

logo

header "Sulu CMF Functional Test Suite"


info "Running Behat with profile \""$PROFILE"\""

export BEHAT_PARAMS=

php vendor/behat/behat/bin/behat --profile $PROFILE

if [ $? -ne 0 ]; then
    echo $SUITE >> /tmp/failed.tests
fi
echo ""

check_failed_tests
