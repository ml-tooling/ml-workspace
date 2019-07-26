#!/bin/bash
#
# Simple script to restart jupyter (e.g. to install extensions)

# Just stop jupyter
jupyter notebook stop 8090
# Now jupyter will be spawned again by supervisor