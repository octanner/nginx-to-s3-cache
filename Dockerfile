FROM nginx:1-bullseye
EXPOSE 8080
COPY start.sh start.sh
CMD "./start.sh"