```

    cd piktur_api
    heroku login
    heroku create

    subl .config/bundle

```

Set bitbucket credentials (`username` and `password`) in local bundler config. This allows fetching private repo from remote source.

```

    $ bundle config --local bitbucket.org username:password

```

Or set environment variable [](http://bundler.io/man/bundle-config.1.html#CONFIGURATION-KEYS)

```

    $ $BUNDLE_BITBUCKET__ORG=username:password

```

Set private gem source [Bundler Gemfile](http://bundler.io/v1.13/man/gemfile.5.html)

```

    # piktur/piktur_core/Gemfile
    gem 'piktur_store', '0.0.1', :git => 'https://bitbucket.org/piktur/piktur_store.git'

    # piktur/piktur_api/Gemfile
    gem 'piktur_core', '0.0.1', :git => 'https://bitbucket.org/piktur/piktur_core.git'


```

```

    $ heroku create --remote staging
    $ heroku create --remote production
    $ git remote add production git@heroku.com:piktur-api.git
    $ git remote add staging git@heroku.com:piktur-api-staging.git

```

Set environment variables to heroku

```

    $ heroku config:set $(cat ../.env.common ../.env)

```

Set ruby version in Gemfile. If this is not set Heroku provides default 2.2.6
`ruby '2.3.0'`.

```

    git push heroku master

```

Install addons

```

    heroku addons:create heroku-redis:hobby-dev

```

```

    heroku addons:create newrelic:wayne

```

Ensure admin user exists db/seeds.production.rb
Store credentials in ENV

```

    https://piktur-api.herokuapp.com/api/v1/token?auth[email]=ENV['EMAIL']&auth[password]=ENV['PASSWORD']

```

Ensure portfolios exist

```

    heroku run rails c

    > Catalogue::Portfolio.create

    https://piktur-api.herokuapp.com/api/v1/client/portfolios?token=

```

## Gem Hosting

~~[gems.piktur.io](http://gems.piktur.io)~~
[AWS Elastic Beanstalk](http://gem-server-env.q9742jmip7.ap-southeast-2.elasticbeanstalk.com/)
[BitBucket](https://bitbucket.org/piktur/gem_server)

[Geminabox](https://github.com/yuri-karpovich/geminabox)
~~[Heroku Docker](https://devcenter.heroku.com/articles/container-registry-and-runtime)~~

```

    cd ~/webev/current_projects/gem_server
    # Install AWS Elastic Beanstalk CLI
    brew install awsebcli
    eb init
    eb create
    eb deploy
    eb setenv $(cat .env)

    # Until domain alias resolved set Gemfile source with
    ENV['GEM_SOURCE']
    # => "http://<username>:<password>gem-server-env.q9742jmip7.ap-southeast-2.elasticbeanstalk.com"

    # git clone https://github.com/yuri-karpovich/geminabox.git
    # cd geminabox
    # heroku create
    # Store `GEMINABOX_USER` and `GEMINABOX_PASSWORD` in `./.env
    # touch .gitignore
    # echo .env >> .gitignore
    # heroku config:set $(cat .env)
    # heroku container:push web
    # heroku open

```

## CI

### CircleCI

Configure with `./circle.yml`

### Wercker

Ditching Wercker for CircleCI much easier to setup.

[wercker.yml](https://bitbucket.org/snippets/piktur/jjaa9)

[Install docker](https://docs.docker.com/docker-for-mac/)

[](http://www.wercker.com/cli/install/osx)

Install VirtualBox

```

    brew install Caskroom/cask/virtualbox

    brew install Caskroom/cask/virtualbox-extension-pack

    docker-machine create --driver virtualbox dev

    # Note that you will need to do this every time you start a new shell. Add this line to your
    # profile to circumvent this.
    eval '$(docker-machine env dev)''

```

[](http://devcenter.wercker.com/docs/quickstarts/deployment/heroku)

Login `wercker login`. Then create wercker.yml with `wercker detect`


## SSL

[**Backup**](/Volumes/MEDIA/.ssh)

[Purchased Comodo Positive Wildcard SSL 1YEAR 12/30/2016](https://store.ssl2buy.com/order/comodoorderdetail/2454532)
[Reseller Config](https://www.configuressl.com/?pin=5a7d5252-a95d-44b3-aa23-0c71678cf587)

[Generate CSR Guide](https://support.rackspace.com/how-to/generate-a-csr-with-openssl/)
```

    $ cd ~/.ssh
    $ openssl genrsa -out piktur.io.key 2048
    > ~/.ssh/piktur.io.key

    $ openssl req -new -sha256 -key piktur.io.key -out piktur.io.csr

    Country Name (2 letter code) [AU]:AU
    State or Province Name (full name) [Some-State]:New South Wales
    Locality Name (eg, city) []:Sydney
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:Piktur
    Organizational Unit Name (eg, section) []:IT
    Common Name (e.g. server FQDN or YOUR name) []:*.piktur.io
    Email Address []:admin@piktur.io

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:Piktur

    > ~/.ssh/piktur.io.csr

```

### AWS Certificate Manager Prep

> **TLDR** A CERTIFICATE MUST BE IMPORTED PER REGION. CHANGE THE REGION IN THE DROPDOWN AT TOP RIGHT OF DASHBOARD.
> ... certificates in ACM are regional resources. To use a certificate with Elastic Load Balancing for the same fully qualified domain name (FQDN) or set of FQDNs in more than one AWS region, you must request or import a certificate for each region. ... [ACM Regions](http://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html)

#### Import Certificate

1. Unzip certificate
2. Copy Certificate body `cat STAR_piktur_io.crt`
3. Copy Private Key `cat ~/.ssh/piktur.io.key`
4. Generate chain and copy chain

```

    cat COMODORSADomainValidationSecureServerCA.crt \
        COMODORSAAddTrustCA.crt \
        AddTrustExternalCARoot.crt

```

#### Enabling HTTPS

[Demonstration](http://stackoverflow.com/questions/35172506/using-aws-certificate-manager-acm-certificate-with-elastic-beanstalk)
Run `eb config` replace `<YOUR ARN>` and add before `aws:elb:listener:80`

```

    aws:elb:listener:443:
      InstancePort: '80'
      InstanceProtocol: HTTP
      ListenerEnabled: 'true'
      ListenerProtocol: HTTPS
      PolicyNames: null
      SSLCertificateId: <YOUR ARN>

```