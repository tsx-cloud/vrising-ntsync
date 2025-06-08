#!/bin/bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
l="${p}/logs"

term_handler() {
	echo "Shutting down Server"

	PID=$(pgrep -f "VRisingServer.exe" | sort -nr | head -n 1)
	if [[ -z $PID ]]; then
		echo "Could not find VRisingServer.exe pid. Assuming server is dead..."
	else
		kill -n SIGINT "$PID"
		#wait for VRisingServer.exe finish
		tail --pid=$PID -f /dev/null
	fi
	echo "Fin"
	exit
}

trap 'term_handler' SIGTERM SIGINT

if [ -z "$LOGDAYS" ]; then
	LOGDAYS=30
fi

if [ -z "$SERVERNAME" ]; then
	SERVERNAME="default_tsx_world"
fi

cleanup_logs() {
	echo "Cleaning up logs older than $LOGDAYS days"
	find "${l}" -name "*.log" -type f -mtime +$LOGDAYS -exec rm {} \;
}


echo "Checking if BepInEx files need to be copied"
mkdir -p "$s"
if [ ! -d "$s/BepInEx" ]; then
    echo "Copy BepInEx files"
	cp -r defaults/server/. "$s/"
else
    echo "The folder $s/BepInEx already exists, copying is not needed."
fi
echo " "

echo "Loading env vars for box64"
if [ "$TARGETARCH" = "arm64" ]; then
    box64=box64
elif [ "$TARGETARCH" = "amd64" ]; then
    box64=""
fi
source /load_box64_env.sh
echo " "

echo "Checking if x64 Linux programs can be executed"
echo "Value of box64 the variable is $box64"
echo "Value of TARGETARCH the variable is $TARGETARCH"
if $box64 /hello_x64; then
    echo "Test x64 program started successfully."
else
    echo "Test x64 program failed to start."
fi
echo " "

echo "Updating V-Rising Dedicated Server files by steamcmd"
echo " "
steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$s" +login anonymous +app_update 1829350 validate +quit
printf "steam_appid: "
cat "$s/steam_appid.txt"

echo " "
mkdir -p "$p/Settings"
if [ ! -f "$p/Settings/ServerGameSettings.json" ]; then
	echo "$p/Settings/ServerGameSettings.json not found. Copying default file."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/Settings/" 2>&1
fi
if [ ! -f "$p/Settings/ServerHostSettings.json" ]; then
	echo "$p/Settings/ServerHostSettings.json not found. Copying default file."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/Settings/" 2>&1
fi

# Checks if log file exists, if not creates it
mkdir -p $l
cleanup_logs
current_date=$(date +"%Y%m%d-%H%M")
logfile="$current_date-VRisingServer.log"
if ! [ -f "${l}/$logfile" ]; then
	echo "Creating ${l}/$logfile"
	touch "${l}/$logfile"
fi


echo "Trying to remove /tmp/.X0-lock"
rm -f /tmp/.X0-lock
echo " "

echo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &
sleep 5

echo " "
echo "Wine configuration"
winetricks sound=disabled
#reboot windows
wine wineboot

echo " "
echo "Checking NTSYNC"
echo "The NTSYNC module has been present in the Linux kernel since version 6.14 and is usually included only in the generic kernel versions."
echo "Kernel version on this machine is -- $(uname -r)"

/usr/bin/lsof /dev/ntsync
if /sbin/lsmod | grep -q ntsync; then
  if /usr/bin/lsof /dev/ntsync > /dev/null 2>&1; then
    echo "NTSYNC Module is present in kernel, ntsync is running."
  else
    echo "NTSYNC Module is present in kernel, but ntsync is NOT running. No problem — ntsync is not nessesary."
  fi
else
  echo "NTSYNC Module is NOT present in kernel. No problem — ntsync is not nessesary."
fi

cd "$s" || {
<------>echo "Failed to cd to $s"
<------>exit 1
}

# Turn on/off vrising plugins support
echo " "
sed -i "s/^enabled *=.*/enabled = ${ENABLE_PLUGINS}/" "$s/doorstop_config.ini"
if [ "$ENABLE_PLUGINS" = "true" ]; then
    echo "Plugins support is ENABLED"
    export WINEDLLOVERRIDES="winhttp=n,b"
else
    echo "Plugins support is DISABLED"
fi

echo " "
echo "Starting V Rising Dedicated Server with name $SERVERNAME"
start_server() {
	wine /mnt/vrising/server/VRisingServer.exe -serverName "$SERVERNAME" -persistentDataPath $p -logFile "${l}/$logfile" 2>&1 &
}
start_server
# Gets the PID of the last command (its Wine)
ServerPID=$!

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -f "$l/$logfile" &
wait $ServerPID
