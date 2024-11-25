# Use an official WordPress image as a base
FROM bitnami/wordpress

# Copy your application files into the container
COPY ./plugin/wp-test-plugin/ /bitnami/wordpress/wp-content/plugins

ENV PHP_MEMORY_LIMIT=512m
