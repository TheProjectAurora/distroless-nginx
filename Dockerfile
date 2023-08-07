# syntax=docker/dockerfile:1
FROM debian:11 as builder

ENV USER=nonroot
ENV UID=10001 

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

RUN apt update && apt -y install wget gnupg binutils && \
    wget "https://nginx.org/keys/nginx_signing.key" && \
    apt-key add nginx_signing.key && \
    echo "deb https://nginx.org/packages/mainline/debian/ bullseye nginx" >/etc/apt/sources.list.d/nginx.list && \
    echo "deb-src https://nginx.org/packages/mainline/debian/ bullseye nginx" >>/etc/apt/sources.list.d/nginx.list && \
    apt update && \
    apt install -y nginx && \
    apt install --download-only --reinstall nginx lsb-base  libgcc-s1 libc6 libcrypt1 libpcre2-8-0 libssl1.1 zlib1g && \
    apt install --download-only --reinstall libidn2-0 libnss-nis libnss-nisplus  debconf gcc-10-base && \
    for f in /var/cache/apt/archives/*.deb; do dpkg-deb -xv $f /packages; done && \
    rm -rf /packages/usr/share/bash-completion  \
        /packages/usr/share/debconf \
        /packages/usr/share/doc \
        /packages/usr/share/lintian	\
        /packages/usr/share/locale	\
        /packages/usr/share/man \
        /packages/usr/share/perl5  \
        /packages/usr/share/pixmaps \
        /packages/usr/bin \
        /packages/usr/bin/dpkg* \
        /packages/usr/bin/nginx-debug && \
        mkdir -p /packages/var/run

RUN chown -R nonroot:nonroot /var/cache /var/run

RUN touch /var/run/nginx.pid && \
    chown -R nonroot:nonroot /var/run/nginx.pid

FROM scratch
COPY --from=builder /packages /
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /var/cache /var/cache
COPY --from=builder /var/run /var/run

COPY nginx_configs/nginx.conf /etc/nginx/nginx.conf
COPY nginx_configs/default.conf /etc/nginx/conf.d/default.conf

RUN --mount=type=bind,from=builder,target=/mount ["/mount/bin/ln", "-sf", "/dev/stdout", "/var/log/nginx/access.log"]
RUN --mount=type=bind,from=builder,target=/mount ["/mount/bin/ln", "-sf", "/dev/stderr", "/var/log/nginx/error.log"]

EXPOSE 8000

USER nonroot

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
