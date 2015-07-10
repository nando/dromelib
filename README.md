# Dromelib

Personal but transferable semantic closet library.

DISCLAIMER: I'm just starting to write Dromelib trying to build a library
with the important Auidrome's features tested. I'm trying to write this
README first, doing something that we could call RDD (Readme Driven
Development :)

So, be sure the specs test what you've read in the README if that fails.

## Installation

Add this line to your application's Gemfile:

    gem 'dromelib'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dromelib

## Usage

require 'rubygems'
require 'dromelib'
include Dromelib

> GMail.configured?
=> true
> GMail.username
=> 'fernan.dogs'
> GMail.from
=> 'movildenando@gmail.com'
> GMail.unread_count
=> 4
> GMail.subject_prefix
=> 'Dromo'
> GMail.import! # Returns imported auidos
=> ['PACA', 'DORA', 'TrabajosRails.com']
> GMail.unread_count
=> 0


## Contributing

1. Fork it ( https://github.com/[my-github-username]/dromelib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Dromelib is distributed under the CeCILL 2.1 license. Please see LICENSE.txt (or LICENCE.txt in french) for details.
