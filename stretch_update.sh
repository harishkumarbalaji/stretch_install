#!/bin/bash
./stretch_install_system.sh |& tee ~/stretch_system_update.log
./stretch_install_user.sh |& tee ~/stretch_user_update.log

