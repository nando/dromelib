# Dromelib

Personal but transferable semantic closet library.

DISCLAIMER: I'm just starting to write Dromelib trying to build a library
with the important Auidrome's features tested. I'm trying to write this
README first, doing something that we could call RDD (Readme Driven
Development :)

So, be sure the specs test what you've read in the README if that fails.

## Usage example from the command line

    ~/src $ git clone http://github.com/nando/dromelib
    Clonar en «dromelib»...
    remote: Counting objects [...]
    ~/src $ cd dromelib
    ~/src/dromelib $ bundle install
    Fetching gem metadata from https://rubygems.org/.........
    [...]
    ~/src/dromelib $ irb
    irb(main):001:0> require './lib/dromelib'
    => true
    irb(main):002:0> Dromelib.initialized?
    => false
    irb(main):003:0> Dromelib.init!
    => true
    irb(main):004:0> Dromelib.initialized?
    => true
    irb(main):005:0> Dromelib::GMail.configured?
    => false
    irb(main):006:0> ^D
    ~/src/dromelib $ vim .dromelib.yml
    app:
      name: RailsOnDrome
    gmail:
      username: colgado
      password: nan.dog
    ~/src/dromelib $ irb
    irb(main):001:0> require './lib/dromelib'
    => true
    irb(main):002:0> Dromelib.init!
    => {"app"=>{"name"=>"RailsOnDrome"}, "gmail"=>{"username"=>"colgado", "password"=>"nan.dog"}}
    irb(main):003:0> Dromelib::Config.app.name
    => "RailsOnDrome"
    irb(main):004:0> Dromelib::GMail.configured?
    => true
    irb(main):005:0> Dromelib::GMail.username
    => "colgado"
    irb(main):006:0> Dromelib::GMail.from
    => nil
    irb(main):007:0> Dromelib::GMail.unread_count
    => 13
    irb(main):008:0> Dromelib::GMail.import!
    Dromelib::GMail::MissingFromError: Required to import only emails from there
    ==> TO BE CONTINUED <==

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dromelib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Dromelib is distributed under the CeCILL 2.1 license. Please see LICENSE.txt (or LICENCE.txt in french) for details.
