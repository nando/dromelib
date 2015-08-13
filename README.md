# Dromelib

Personal but transferable semantic closet library.

DISCLAIMER: I'm just starting to write Dromelib trying to build a library
with the important Auidrome's features tested. I'm trying to write this
README first, doing something that we could call RDD (Readme Driven
Development :)

So, be sure the specs test what you've read in the README if that fails.

## Usage example from the command line

### Chapter 0: Prepare our console to drome...

    ~/src $ git clone http://github.com/nando/dromelib
    Clonar en «dromelib»...
    remote: Counting objects [...]
    ~/src $ cd dromelib
    ~/src/dromelib $ bundle install
    Fetching gem metadata from https://rubygems.org/.........
    [...]
    ~/src/dromelib $ ./bin/console
    irb(main):002:0> Dromelib.initialized?
    => false
    irb(main):003:0> Dromelib.init!
    => true
    irb(main):004:0> Dromelib.initialized?
    => true
    irb(main):005:0> Dromelib.drome
    => #<Dromelib::Drome:0xba574544>

### Chapter 1: GMail input channel

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

### Chapter 2: To drome (roadmap ready to suffer... :)

Dromelib.init!
Dromelib.drome
=> #<Dromelib::Drome:0xDOCUDROME>
docs = Dromelib.load_drome # Docudrome is the default drome
=> #<Dromelib::Drome:0xDOCUDROME>
humans = Dromelib.load_drome(:lovedrome)
=> #<Dromelib::Drome:0xLOVEDROME>

docs.cardinal_point
=> #<Dromelib::CardinalPoint:0xSOUTH>
docs.cardinal_point.drift
=> S
docs.cardinal_point.point
=> Document
docs.cardinal_point.dromename
=> docudrome

uncurated = docs.new_entry('Matz')
=> #<Dromelib::Entry:0xMATZ>

uncurated.cardinal_point.point
> Document

uncurated.source
> Console <Linux ragoaika 3.11.0-12-generic [...] i686 GNU/Linux> 
# Other possible sources:
# - Web <http://otaony.com/colgado>
# - Email <colgado@gmail.com>

uncurated.drome
=> #<Dromelib::Drome:0xDOCUDROME>

uncurated.drome.name
=> docudrome

uncurated.save!
=> true

uncurated.curated?
=> false

uncurated.move_to! humans
=> true

matz = uncurated.curated! # curated! returns self
=> #<Dromelib::Entry:0xMATZ>

uncurated.drome.name
=> lovedrome

matz.drome.name
=> lovedrome

matz.curated?
=> true

## Contributing

Way to go:

1. Fork it ( https://github.com/[my-github-username]/dromelib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Having in mind always that:

1. ´´rake´´ should never complain
2. Tests/specs are always welcome

## TODO

There's a TODO file!!! Thanks.

## License

Dromelib is distributed under the CeCILL 2.1 license. Please see LICENSE.txt (or LICENCE.txt in french) for details.
