## Base information
The goal of this build is to enable running V Rising on Wine with all the latest features: staging-tkg-ntsync-wow64, with or without plugins, on both arm64 and amd64 platforms.

In the logs folder, you can find startup logs of V Rising with plugins (BepInEx) on the arm64 platform (Google Axion CPU).
The docker-compose-example folder contains a quickstart setup to launch with all features enabled.

Important note! ntsync support is available only in the latest Ubuntu version — 25.04, and even then it must be manually enabled.
The build works perfectly fine without ntsync — the only thing you need to do is comment out the following two lines in your docker-compose file:
```yaml
    #devices:
    #  - /dev/ntsync:/dev/ntsync
```
Autosave works correctly when using docker stop.

## ARM
You can set your custom Box64 configuration in  
```yaml
./vrising/server/BepInEx/addition_stuff/box64.rc  
```
These settings will be used when launching V Rising.  
A list of available environment variables can be found here:  
https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md

This build includes a slightly modified version of BepInEx, since the original one doesn't run under the x86-64 emulator (e.g., Box64).
https://github.com/tsx-cloud/Il2CppInterop/commits/v-rising_1.1_arm_friendly/

## Environment variables


| Variable   | Key                    | Description                                                                       |
| ------------ | ------------------------ | ----------------------------------------------------------------------------------- |
| TZ         | Europe/Kyiv            | timezone for ntpdate                                                              |
| SERVERNAME | published servername   | mandatory setting that overrules the ServerHostSettings.json entry                |
| LOGDAYS    | optional lifetime of logfiles | overrule default of 30 days |
| ENABLE_PLUGINS | false | Enables or disables support for BepInEx-based plugins.
Place your plugins in the ./vrising/server/BepInEx/plugins folder. |

## Volumes


| Volume             | Container path              | Description                             |
| -------------------- | ----------------------------- | ----------------------------------------- |
| steam install path | /mnt/vrising/server         | path to hold the dedicated server files |
| world              | /mnt/vrising/persistentdata | path that holds the world files         |


## docker-compose.yml

```yaml
services:
  vrising:
    image: tsxcloud/vrising-ntsync:latest
    environment:
      - TZ=Europe/Kyiv
      - SERVERNAME=vrising-ntsync
      - ENABLE_PLUGINS=false
    volumes:
      - ./vrising/server:/mnt/vrising/server
      - ./vrising/persistentdata:/mnt/vrising/persistentdata
    ports:
      - '9876:9876/udp'
      - '9877:9877/udp'
      - '25575:25575/tcp' #for Rcon:Enabled
      - '9099:9090/tcp'   #127.0.0.1:9099/metrics for API:Enabled (prometeus)
    restart: unless-stopped
    network_mode: bridge
    #This is required for ntsync to work inside Docker.
    #If ntsync support is not enabled in your Linux kernel, comment out this section, otherwise Docker Compose won't start.
    #devices:
    #  - /dev/ntsync:/dev/ntsync
```


## Links
https://hub.docker.com/r/tsxcloud/vrising-ntsync

This Docker image is based on TrueOsiris/docker-vrising and is largely compatible with it. For more detailed information, please also refer to:
https://github.com/TrueOsiris/docker-vrising/blob/main/README.md


## Acknowledgments
https://github.com/Kron4ek/Wine-Builds  
https://github.com/gogoout/vrising-server-arm64  
https://github.com/steamcmd/docker  
https://github.com/TrueOsiris/docker-vrising  

## 
Enjoying the project? A ⭐ goes a long way!


