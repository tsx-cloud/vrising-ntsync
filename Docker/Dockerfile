FROM tsxcloud/steamcmd-wine-ntsync:latest

COPY server/ defaults/server/
ENV ENABLE_PLUGINS=false

COPY hello_x64 /hello_x64
RUN chmod +x /hello_x64

COPY load_box64_env.sh /load_box64_env.sh
RUN chmod +x /load_box64_env.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT []
CMD ["/start.sh"]
