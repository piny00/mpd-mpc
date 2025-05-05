FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y mpd tzdata mpc netcat-openbsd inotify-tools

RUN ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime && echo "Europe/Budapest" > /etc/timezone

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
VOLUME ["/music"]

COPY wait-for-icecast.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-icecast.sh

CMD ["/usr/local/bin/wait-for-icecast.sh", "/usr/local/bin/entrypoint.sh"]
