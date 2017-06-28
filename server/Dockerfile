FROM phusion/passenger-ruby22:0.9.18

# Set correct environment variables.
ENV HOME /root

# Enable nginx and Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Create virtual host
COPY conf/vhost.conf /etc/nginx/sites-enabled/app.conf

# Prepare folders
RUN mkdir /home/app/webapp

# Run Bundle in a cache efficient way
WORKDIR /tmp
COPY app/Gemfile /tmp/
COPY app/Gemfile.lock /tmp/
RUN bundle install

# Add our app
COPY app /home/app/webapp
RUN chown -R app:app /home/app

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# This is the only way to load environment variables before starting things up
COPY run.sh  /usr/local/sbin/
CMD ["/usr/local/sbin/run.sh"]
