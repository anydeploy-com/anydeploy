#!/bin/bash


##############################################################################
#                            Listen if vm is shutdown                        #
##############################################################################

# id must be called to run this script

# get pid of working job
# syntax : ps aux | grep "qemu-system" | grep "id" | awk '{print $2}'

capture() {
  echo "<h2>Running capture script</h2>"
  echo "dupa" > /deployment_done.txt
}


waitall() { # PID...
  ## Wait for children to exit and indicate whether all exited with 0 status.
  local errors=0
  while :; do
    debug "Processes remaining: $*"
    for pid in "$@"; do
      shift
      if kill -0 "$pid" 2>/dev/null; then
        debug "$pid is still alive."
        set -- "$@" "$pid"
      elif wait "$pid"; then
        debug "$pid exited with zero exit status."
        capture
      else
        debug "$pid exited with non-zero exit status."
        ((++errors))
        capture
      fi
    done
    (("$#" > 0)) || break
    # TODO: how to interrupt this sleep when a child terminates?
    sleep ${WAITALL_DELAY:-1}
   done
  ((errors == 0))
}

debug() { echo "DEBUG: $*" >&2; }

pids=$(ps aux | grep "qemu-system" | grep "Windows7_x64" | awk '{print $2}')

for t in 3 5 4; do
  sleep "$t" &
  pids="$pids"
done
waitall $pids
