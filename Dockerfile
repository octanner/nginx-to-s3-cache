FROM nginx:latest
EXPOSE 8080
COPY start.sh start.sh
CMD "./start.sh"