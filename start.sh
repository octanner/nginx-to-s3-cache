#!/bin/sh
cat <<EOF > /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;
daemon off;
error_log  /dev/stderr warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
  default_type       text/html;
  access_log         /dev/stdout;
  sendfile           on;
  keepalive_timeout  65;
  proxy_cache_path   /tmp/ levels=1:2 keys_zone=s3_cache:10m max_size=500m
                     inactive=60m use_temp_path=off;
  server {
    listen 8080;
    location / {
      proxy_http_version 1.1;
      proxy_set_header Host $S3_BUCKET.s3.$S3_REGION.amazonaws.com;
      proxy_hide_header x-amz-id-2;
      proxy_hide_header x-amz-request-id;
      proxy_hide_header x-amz-meta-server-side-encryption;
      proxy_hide_header x-amz-server-side-encryption;
      proxy_hide_header x-amz-bucket-region;
      proxy_hide_header Set-Cookie;
      proxy_ignore_headers Set-Cookie;
      proxy_intercept_errors on;
      add_header Cache-Control max-age=31536000;
      proxy_ssl_server_name  on;
      proxy_ssl_name $S3_BUCKET.s3.$S3_REGION.amazonaws.com;
      proxy_pass https://$S3_BUCKET.s3.$S3_REGION.amazonaws.com/;
      client_max_body_size 100M;
    }
  }
}
EOF
cat /etc/nginx/nginx.conf
nginx