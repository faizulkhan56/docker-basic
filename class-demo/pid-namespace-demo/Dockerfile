FROM nginx:alpine

# Install ps command for process viewing
RUN apk add --no-cache procps

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Use custom startup script
CMD ["/start.sh"]
