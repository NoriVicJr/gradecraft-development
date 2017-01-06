# Gradecraft web application Docker image
#
# VERSION       1.0
# ENVIRONMENT   beta
# ~~~~ Image base ~~~~
FROM quay.io/gradecraft/secrets:beta.gradecraft.com
MAINTAINER Shekhar Patil <shekhar@venturit.com>
ENV DOCKER_FIX random
RUN gem install -v 1.10.6 bundler
RUN mkdir /gradecraft
WORKDIR /gradecraft/
ADD Gemfile /gradecraft/Gemfile
ADD Gemfile.lock /gradecraft/Gemfile.lock
RUN bundle install
COPY . /gradecraft
RUN cp /intermidiate/gradecraft_saml_idp.pem /gradecraft/gradecraft_saml_idp.pem
RUN cp /intermidiate/gcsha256.key /gradecraft/gcsha256.key
RUN cp /intermidiate/gcsha256.crt /gradecraft/gcsha256.crt
RUN cp /intermidiate/app.gradecraft.com.key /gradecraft/app.gradecraft.com.key
RUN cp /intermidiate/app.gradecraft.com.crt /gradecraft/app.gradecraft.com.crt
RUN cp /intermidiate/database.yml /gradecraft/config/database.yml
RUN cp /intermidiate/mongoid.yml /gradecraft/config/mongoid.yml
RUN cp /intermidiate/puma.rb /gradecraft/config/puma.rb
RUN cp /intermidiate/Procfile /gradecraft/Procfile
RUN printf  "if [ \$WEBRESQUE = 'WEB' ]\nthen \n RAILS_ENV=beta  bundle exec rake resque:scheduler &\n/mounts3.sh\nservice nginx stop\ncertbot-auto certonly --verbose --noninteractive  --standalone --agree-tos --email=\"shekhar@venturit.com\" -d \"beta.gradecraft.com\" --force-renew\nservice nginx start\ncrontab -r\ncrontab -l | { cat; echo \"30 2 * * * certbot-auto renew \"; } | crontab - \npuma\nelse \n RAILS_ENV=beta bundle exec rake resque:scheduler & \nbundle exec rake resque:work >> resque.log\nfi" > /gradecraft/start.sh
RUN chmod +x /gradecraft/start.sh
RUN RAILS_ENV=beta bundle exec rake assets:precompile
RUN RAILS_ENV=beta bundle exec rake db:migrate
ENTRYPOINT /gradecraft/start.sh
