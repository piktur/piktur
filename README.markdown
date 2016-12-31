# Piktur

[**Trello**](https://trello.com/b/rfyc6HpD/pikturapp-jan16)

[**Piktur.io**](http://piktur.io)

## [piktur [lib]](https://bitbucket.org/piktur/piktur)
`/piktur` Piktur | Common utilities for Piktur apps

[**Issues**](https://bitbucket.org/piktur/piktur/issues) | [**README**](https://bitbucket.org/piktur/piktur/src/master/README.markdown) | [![CircleCI](https://circleci.com/bb/piktur/piktur.svg?style=svg)](https://circleci.com/bb/piktur/piktur)

## [piktur_core [engine]](https://bitbucket.org/piktur/piktur_core)

`/piktur/piktur_core` Piktur | Rails engine providing core MVC objects and configuration for Piktur apps

[**Issues**](https://bitbucket.org/piktur/piktur_core/issues) | [**README**](https://bitbucket.org/piktur/piktur_core/src/master/README.markdown) | [![CircleCI](https://circleci.com/bb/piktur/piktur_core.svg?style=svg)](https://circleci.com/bb/piktur/piktur_core)

## [piktur-api [application]](https://bitbucket.org/piktur/piktur_api)

`/piktur/piktur_api` Piktur::Api | RESTful API serving JSONAPI v1 compliant JSON

[**Issues**](https://bitbucket.org/piktur/piktur_api/issues) | [**README**](https://bitbucket.org/piktur/piktur_api/src/master/README.markdown) | [![CircleCI](https://circleci.com/bb/piktur/piktur_api.svg?style=svg)](https://circleci.com/bb/piktur/piktur_api)

## [piktur_blog [application]](https://bitbucket.org/piktur/piktur_blog)

`/piktur/piktur_blog` Ghost | Blog

[**Issues**](https://bitbucket.org/piktur/piktur_blog/issues) | [**README**](https://bitbucket.org/piktur/piktur_blog/src/master/README.markdown) | [![CircleCI](https://circleci.com/bb/piktur/piktur_blog.svg?style=svg)](https://circleci.com/bb/piktur/piktur_blog)

## [piktur_store [engine]](https://bitbucket.org/piktur/piktur_store)

`/piktur/piktur_store` Piktur::Store | eCommerce

[**Issues**](https://bitbucket.org/piktur/piktur_store/issues) | [**README**](https://bitbucket.org/piktur/piktur_store/src/master/README.markdown) | [![CircleCI](https://circleci.com/bb/piktur/piktur_store.svg?style=svg)](https://circleci.com/bb/piktur/piktur_store)

## [piktur_admin [application]](https://bitbucket.org/piktur/piktur_admin)

`/piktur/piktur_admin` Piktur::Admin | Subscriber interface

[**Issues**](https://bitbucket.org/piktur/piktur_admin/issues) | [**README**](https://bitbucket.org/piktur/piktur_admin/src/master/README.markdown) | [![CircleCI](https://circleci.com/bb/piktur/piktur_admin.svg?style=svg)](https://circleci.com/bb/piktur/piktur_admin)

## [piktur_client [application]](https://bitbucket.org/piktur/piktur_client)

`/piktur/piktur_client` Piktur::Client | Site generator

[**Issues**](https://bitbucket.org/piktur/piktur_client/issues) | [**README**](https://bitbucket.org/piktur/piktur_client/src/master/README.markdown) | [![CircleCI](https://circleci.com/bb/piktur/piktur_client.svg?style=svg)](https://circleci.com/bb/piktur/piktur_client)

---

Application functionality is separated in to a multiple applications/engines.

```

    |-- /piktur
       |-- /piktur_core
       |-- /piktur_api
          |-- /lib
            |-- /v1
              |-- /client
              |-- /admin
       |-- /piktur_blog
       |-- /piktur_store
       |-- /piktur_admin
       |-- /piktur_client

```

---

**References**

  - [Rails Engines in the Wild](https://www.toptal.com/ruby-on-rails/rails-engines-in-the-wild-real-world-examples-of-rails-engines-in-action)
  - [Rails 4 Engines](http://tech.taskrabbit.com/blog/2014/02/11/rails-4-engines/)
  - [Monkey Patching](http://eng.rightscale.com/2014/11/25/safer-monkeypatching.html)
  - [Service Objects](https://blog.engineyard.com/2014/keeping-your-rails-controllers-dry-with-services)

## Style Guide

[Rubocop Settings](https://bitbucket.org/piktur/piktur_core/src/master/.rubocop.yml)

[Ruby 2.3.0 Frozen String Literal](https://bugs.ruby-lang.org/issues/11473)

```sh

    bundle exec rubocop --auto-correct --only FrozenStringLiteralComment

```

```sh

    # Freeze all string literals within a file
    # frozen_string_literal: true

    # Enable globally CAUTION: not all gems support this
    export RUBYOPT="--enable-frozen-string-literal"
    export RUBYOPT="--disable-frozen-string-literal"

    # Debug enabled by default
    # export RUBYOPT="--enable-frozen-string-literal --debug=frozen-string-literal"

```

---

**References**

  - [Airbnb StyleGuide](https://github.com/airbnb/ruby)
  - [Thoughbot Guides](https://github.com/thoughtbot/guides)
  - [Thoughtbot Best Practices](https://github.com/thoughtbot/guides/tree/master/best-practices)

## Documentation

> The key words **'MUST'**, **'MUST NOT'**, **'REQUIRED'**, **'SHALL'**, **'SHALL NOT'**, **'SHOULD'**, **'SHOULD NOT'**, **'RECOMMENDED'**, **'MAY'**, and **'OPTIONAL'** in this document are to be interpreted as described in **[RFC2119](https://tools.ietf.org/html/rfc2119)**.

---

Boot docs server

```

    yard server --server webrick --reload --port 8080

    yard server --docroot ./docs
                --multi-library  piktur .yardoc \
                  piktur_core ./piktur_core/.yardoc \
                  piktur_api ./piktur_api/.yardoc

```

**Generate symbolic link to nested README**

```ruby

    %w(api admin blog client core store).each do |app|
      f = Rails.root.join("../piktur_#{app}/README.markdown")
      destination = Pathname(File.join(*f.to_s.rpartition("piktur_#{app}").insert(1, 'docs')))
      FileUtils.mkdir_p(destination.parent) unless destination.parent.exist?
      File.symlink(f, destination)
    end

```

`{``include:Piktur``}` will include the docstring from the specified Ruby object.

### Annotations

Table schema is added to model documentation using `annotate_models` gem.

[Usage](https://bitbucket.org/snippets/piktur/bbrnx)

---
**References**

  - [Yard Cheatsheet](https://gist.github.com/chetan/1827484)

## CI

[CircleCI](https://circleci.com/bb/piktur)

[Prevent code from running on CI server](https://circleci.com/docs/dont-run/) using variables `ENV['CIRCLECI']` and `ENV['CI']` (return `'true'`) ie. to prevent loading secrets from untracked `.env` files.

## Development Environment

  1. [Install NGINX](https://kevinworthington.com/nginx-for-mac-os-x-el-capitan-in-2-minutes/)

  2. Add host names to `NGINX` configuration `/etc/nginx/sites-available/` `api.lvh.me`, `lvh.me`

  3. Install `rvm`

  4. Install foreman `gem install foreman`

  5. `rvm gemset create ruby-2.3.0@piktur`

  6. `rvm --default use piktur`

  7. Install `rails`

  8. Configure `pry` console `/Users/daniel/.pryrc`

  9. [Install `node.js`](https://gist.github.com/isaacs/579814)

  10. Install [`vips`](#VIPS)

### VIPS

[Official Guide](http://www.vips.ecs.soton.ac.uk/index.php?title=Build_onOfficial Guide]_Ubuntu)
[Heroku](https://github.com/alex88/heroku-buildpack-vips)

`cd /usr/local/` or where ever you wish to install `git clone git://github.com/jcupitt/libvips.git`

> `dzsave`    requires `libgsf-1-dev`
> `vips_edit` requires `libexif-dev`

```sh

    sudo apt-get install build-essential  libxml2-dev libfftw3-dev  \
    gettext libgtk2.0-dev python-dev liblcms1-dev liboil-dev \
    libmagickwand-dev libopenexr-dev libcfitsio3-dev gobject-introspection flex bison \
    libgsf-1-dev libexif-dev

    # Or from the git source
    sudo apt-get install automake libtool swig gtk-doc-tools libglib2.0-dev git
    ./bootstrap.sh

    # Build
    ./configure
    make
    sudo make install

```

Configure VIPSHOME in `sudo subl .bashrc`

```sh

    export VIPSHOME=/usr/local
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VIPSHOME/lib
    export PATH=$PATH:$VIPSHOME/bin
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$VIPSHOME/lib/pkgconfig
    export MANPATH=$MANPATH:$VIPSHOME/man
    export PYTHONPATH=$VIPSHOME/lib/python2.7/site-packages

```

Instal metadata libraries
**WEBP**[webpmux](http://www.webmproject.org/code/) `sudo apt-get install webp`
**JPEG** [exiftool] `sudo apt-get install libimage-exiftool-perl`

### Dependencies

Copy `piktur_core/Gemfile` to `Gemfile.core`.

```sh

    curl https://${BUNDLE_BITBUCKET__ORG}@bitbucket.org/piktur/piktur_core/raw/master/piktur_core/Gemfile -o Gemfile.core

```

```ruby

    eval_gemfile('Gemfile.core')

    # Add additional gems below
    # ...

```

Ruby/gem management handled with `rvm`. Create a single gemset and point each piktur gem to it.

Bundler also allows you to work against a git repository locally instead of using the remote version. This can be achieved by setting up a local override:

```

    # Gemfile
    gem 'piktur_core',
    git:    'https://bitbucket.org/piktur/piktur_core.git',
    branch: 'master'

    # $ bundle config --local local.piktur_core /Users/daniel/Documents/webdev/current_projects/piktur/piktur_core

    # $ bundle config --local local.piktur_store /Users/daniel/Documents/webdev/current_projects/piktur/piktur_store

```

Keep a local copy on hand to minimise time to `bundle install`.

```

    cd vendor/cache
    git clone https://github.com/lsegal/yard.git -b master
    git clone https://github.com/amoeba-rb/amoeba.git -b master
    git clone https://github.com/awesome-print/awesome_print.git -b master
    git clone https://github.com/noname00000123/annotate_models.git -b develop
    git clone https://bitbucket.org/piktur/knock.git -b master

```

### Boot

```sh

    # Boot app environment via "piktur/Procile"
    foreman start --env .env.common,.env.development

    foreman start --procfile Procfile.development --env .env.common,.env.development

```

`$ foreman start` will load variables defined in `.env.` additional files may be specified using `--env` or `-e` flag. Declared this way, variables **are visible to children of the parent process**.

## Repository Management

- [Erase History](http://stackoverflow.com/questions/13716658/how-to-delete-all-commit-history-in-github) Significant size reduction, up to 50% decrease on `piktur_api`

- [git prune vs repack](http://stackoverflow.com/questions/28720151/git-gc-aggressive-vs-git-repack)

- [git repack](http://stackoverflow.com/questions/14842127/how-to-use-git-repack-a-d-depth-250-window-250)

- [Sort branches by last commit, from earliest to latest](http://stackoverflow.com/questions/9236219/git-list-git-branches-sort-by-and-show-date#16961359)

- [Delete branch](http://stackoverflow.com/questions/2003505/how-to-delete-a-git-branch-both-locally-and-remotely#2003515)

```

    # Delete remote branch
    git push origin --delete <branch_name>
    # Delete local branch
    git branch -d <branch_name>

```

[Git Maintenance](http://stevelorek.com/how-to-shrink-a-git-repository.html)

```

    git for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'

```


```

    touch oversize.sh
    chmod +x oversize.sh

```

## Testing

> [Testing should assess expected behaviour not implementation](https://www.ruby-forum.com/topic/197346) A test suite is written so that changes to the codebase can be made without contradicting expected logic expressed within it.

---

```sh

    # Surely there is a more elegant way to run all specs with coverage?

    COVERAGE=true

    cd ~/[development]/piktur/piktur_core
    rspec spec

    cd ~/[development]/piktur/piktur_api
    rspec spec

    cd ~/[development]/piktur/piktur_blog
    rspec spec

    cd ~/[development]/piktur/piktur_store
    rspec spec

    cd ~/[development]/piktur/piktur_admin
    rspec spec

    cd ~/[development]/piktur/piktur_client
    rspec spec

```

---

**References**

  - [RSpec Style Guide](https://github.com/reachlocal/rspec-style-guide)
  - [RSpec Guide](http://betterspecs.org/)
  - [Another Rspec Guide](https://leanpub.com/everydayrailsrspec/read)
  - [Testing Modules](https://semaphoreci.com/community/tutorials/testing-mixins-in-isolation-with-minitest-and-rspec)

### DRYing specs with RSpec.shared_examples

`shared_examples` are included automatically when metadata matches

```ruby

    RSpec.shared_examples 'content', serializer: CatalogueSerializer

    RSpec.describe CatalogueController, type: :request do
      describe 'content', serializer: CatalogueSerializer
    end

```

#### Setup with `before(:all)` vs `before` and/or `let`

Refer to `piktur_api/spec/support/requests`. These examples utilise `before(:all)` hooks to prepare a request and store result as an instance variables.

The technique improves performance significantly. When triggered in a before(:all) block
all subsequent expectations can access `#request`, `#response` and `#controller` objects.

```ruby

    before(:all) do
      get '/api/v1/client/path', {}, { 'Authorization' => 'Bearer abc123' }
    end
    it { expect(response).to have_http_status 200 }
    it { expect(response.body).to eq {} }

```

Specs now serve as **living** API documentation.

**The technique must be used carefully!**

Instance variables defined in outer block are available to nested blocks. If modified in child scope be sure to **reset value** `after(:each)` or `after(:all)`.

Likewise modifications to the database aren't rolled back unless DatabaseCleaner triggered in the before block.

```ruby

    describe '' do
      before(:all) do
        DatabaseCleaner.start
        @account ||= FactoryGirl.create(:default_account)
      end

      after(:all) do
        DatabaseCleaner.clean
      end
    end

```

### Factories

Factories for common models/objects [available at](https://bitbucket.org/piktur/piktur_core/src/master/piktur_core/lib/piktur/spec/factories)

Try to limit DB queries when running unit tests. If persistence can be avoided use:

  - `Class.new`
  - `FactoryGirl.build_stubbed` or
  - `RSpec#double`

`build_stubbed` mocks persistence (an `id` is assigned to the instance). Calling an association accessor on the stubbed model will trigger a query, and fail. To avoid this set `id: nil`.

**Used only for quick prototyping**, `RSpec` mocks and doubles can be used to specify associations.

```ruby

    stub_data               = attributes_for(:artwork)
    stub_data[:provenances] = Array.new(1){ double(LineItem, attributes_for(:provenance)) }
    artwork_stub            = double(Catalogue::Item::Artwork, stub_data)
    participant             = FactoryGirl.build_stubbed(:participant, role: 'collaborator')

    FactoryGirl.build_stubbed(:artwork) do |artwork|
      artwork.id = nil
      artwork.participants << participant
    end

```

```ruby

    FactoryGirl.define do
      factory :factory, class: Factory do
        # ...

        after(:stub) do |factory|
          factory.id         = nil
          factory.new_record = true
          factory.children   = build_stubbed_list(:children, 2, factory: factory)
        end
      end
    end

```

Then, within RSpec examples

```ruby

    let(:item)     { FactoryGirl.build_stubbed(:item) }
    let(:children) { (1..3).map{ FactoryGirl.build_stubbed(:item) } }

    # Using FactoryGirl
    it 'tracks a relationship to child items' do
      item.id = nil
      item.children << children

      expect(item.children.length).to eq 3
    end

    # Using doubles to avoid database interaction
    it 'tracks a relationship to child items' do
      stub_data            = {}
      stub_data[:children] = (1..2).map{ instance_double(Catalogue::Item) }
      parent_stub          = instance_double(Catalogue::Item, stub_data)

      expect(parent_stub.children.length).to eq 2
    end

```

---

**References**

  - [Stubbing](http://stackoverflow.com/questions/17754770/factorygirl-build-stubbed-strategy-with-a-has-many-association)

### Benchmarks

[Don't rely on intuition, benchmark possible solutions!](spec/benchmark).

---

## Snippets

### File Size

```

    # require 'rake/file_list'

    Rake::FileList['**/*'].
      collect { |path| [File.file?(path) && File.new(path).size, path] }.
      select { |(size, path)| size != false }.
      sort.
      reverse

```

### [Class list](https://bitbucket.org/snippets/piktur/nn9r9)

