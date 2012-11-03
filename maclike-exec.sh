set -o errexit
set -o pipefail

function get_running_apps {
    match=$1
    echo `wmctrl -lx | grep $match | cut -d" " -f1`
}

function launch_app {
    binary=$1
    binary_args=$2
    match=$3
    delay=$4
    workspace=$5
    fullscreen=$6
    maximize=$7

    # Running app: give it focus and exit
    apps_running=$(get_running_apps $match)
    if [ "x$apps_running" != "x" ]; then
	   wmctrl -ia $apps_running
	   exit
    fi

    # Launch a new app
    ${binary} ${binary_args} &

    n=0
    while [ $n -lt 4 ]; do
	   sleep $delay
	   app_running=$(get_running_apps $match)
	   if [ "x$app_running" != "x" ]; then
		  break
	   fi
	   n=$[$n+1]
    done

    app_running=$(get_running_apps $match)

    # Relocate the window to the workspace
    if [ "x$workspace" != "x" ]; then
	   wmctrl -ir ${app_running} -t ${workspace}
    fi

    # Maximize it
    if [ "x$fullscreen" != "x" ]; then
	   wmctrl -ir ${app_running} -b add,fullscreen
    fi

    if [ "x$maximize" != "x" ]; then
	   wmctrl -ir ${app_running} -b add,maximized_vert,maximized_horz
    fi

    # Activate the window
    wmctrl -ia ${app_running}
}

function launch {
    launch_app "$BINARY" "$BINARY_ARGS" "$MATCH" "$DELAY" "$WORKSPACE" "$FULLSCREEN" "$MAXIMIZE"
}
