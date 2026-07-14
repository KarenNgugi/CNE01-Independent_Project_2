# import specific nginx alpine image
FROM nginx:1.30.3-alpine-slim

# create nonroot group & user
RUN addgroup --gid 1001 nginxgroup && adduser -G nginxgroup -u 1001 -D nginxuser

# copy files
COPY --chown=nginxuser:nginxgroup ./grades-tracker.conf /etc/nginx/conf.d/default.conf
COPY --chown=nginxuser:nginxgroup ./src/index.html /usr/share/nginx/html/index.html

# expose port 80
EXPOSE 80

# give write access to dirs needed at runtime
RUN chown -R nginxuser:nginxgroup /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
	touch /var/run/nginx.pid && chown nginxuser:nginxgroup /var/run/nginx.pid

# switch to nonroot user
USER nginxuser

# entrypoint command
CMD ["nginx", "-g", "daemon off;"]
