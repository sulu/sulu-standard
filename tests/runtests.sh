#!/bin/bash

PROFILE=${BEHAT_PROFILE:-"selenium"}
LOGS_PATH=${LOGS_DIR:-"/tmp/sulu"}

if [ -e /tmp/failed.tests ]; then
    rm /tmp/failed.tests
fi
touch /tmp/failed.tests

export BEHAT_PARAMS=
php bin/behat --profile $PROFILE
