# official perl image:
FROM perl:5.36

# Set working directory
WORKDIR /app

# COPY cpanfile and install dependencies
COPY cpanfile* /app/
RUN cpanm --installdeps .

# Also install Starman explicitly
RUN cpanm --notest Starman

# Copy the rest of your app
COPY . /app

# Expose the post Starman will listen on
EXPOSE 5001

# Command to run app
CMD ["starman", "--listen", ":5001", "bin/app.psgi"]