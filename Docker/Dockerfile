FROM tsxcloud/steamcmd-wine-ntsync:latest

COPY server/ defaults/server/
ENV ENABLE_PLUGINS=false

COPY emulators.rc .

COPY --chmod=775 load_emulators_env.sh /load_emulators_env.sh

COPY --chmod=775 print_app_versions.sh /print_app_versions.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT []
CMD ["/start.sh"]
