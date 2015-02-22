#!/bin/bash

# Download and verify setup-vpn from GitHub
wget_sha1sum $TINC_CLUSTER_URL $TINC_LOCAL_FILE $TINC_SHA1SUM
