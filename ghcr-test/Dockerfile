# Use official nginx image
FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Add our custom page
RUN echo "<h1>Hello from GHCR 🚀</h1>" > /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80
