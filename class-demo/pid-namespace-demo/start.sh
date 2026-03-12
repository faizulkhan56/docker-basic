#!/bin/sh

# Start nginx in foreground mode
# This will be PID 1 in the container
exec nginx -g "daemon off;"
