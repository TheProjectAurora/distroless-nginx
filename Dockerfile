FROM debian:11 as builder
RUN apt update && apt -y install wget gnupg binutils && wget "https://nginx.org/keys/nginx_signing.key" && apt-key add nginx_signing.key
RUN echo "deb https://nginx.org/packages/mainline/debian/ bullseye nginx" >/etc/apt/sources.list.d/nginx.list && \
    echo "deb-src https://nginx.org/packages/mainline/debian/ bullseye nginx" >>/etc/apt/sources.list.d/nginx.list && \
    apt update
RUN apt install -y nginx
RUN apt install --download-only --reinstall nginx lsb-base  libgcc-s1 libc6 libcrypt1 libpcre2-8-0 libssl1.1 zlib1g
RUN apt install --download-only --reinstall libidn2-0 libnss-nis libnss-nisplus  debconf gcc-10-base
RUN for f in /var/cache/apt/archives/*.deb; do dpkg-deb -xv $f /packages; done
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log
FROM gcr.io/distroless/static-debian11:latest
COPY --from=builder /packages /
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]