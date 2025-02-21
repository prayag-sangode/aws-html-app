# Use the official httpd image from the Docker Hub
FROM nginx:latest

WORKDIR /usr/share/nginx/html

# Copy the index.html file to the default directory of the Apache server
COPY ./index.html

# Expose port 80
EXPOSE 80

# Start the httpd server
CMD ["nginx", "-g", "daemon off;"]
