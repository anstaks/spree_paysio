SpreePaysio
===========

Provides Pays.IO gateway support for Spree.

Installation
=======


In your Gemfile:

    gem 'spree'
    gem 'spree_paysio', :git => 'git@github.com:itima/spree_paysio.git' # make sure to include after spree

**Note:** *If you are not using the latest Spree, please consult the Versionfile at the
root of the repository to determine which branch to use.*

Then run from the command line:

    $ bundle install
    $ rails g spree_paysio:install

Finally, make sure to **restart your app**. Navigate to *Configuration > Payment Methods > New Payment Method*  in the admin panel and you should see PaysioCom PaymentMethod have been added to the list.


Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2013 [name of extension creator], released under the New BSD License
