# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../dromelib'

module Dromelib
  # Allow us to change the name of the environment variables used by the
  # library through the .dromelib.yml file.
  module Env
    module_function

    def name_for(variable)
      fail Dromelib::UninitializedError unless Dromelib.initialized?
      Dromelib::Config.environment_vars.send(variable)
    end

    def value_for(variable)
      (name = name_for(variable)) && ENV[name]
    end

    # ::set_value_for changes the value of the environment variable, useful 
    # while using the library in the console. For example, we can change the
    # the Dromelib::GMail.from without having to change our .dromelib.yml or
    # the shell env. variable, just typing:
    #
    #     > Dromelib::Env.set_value_for :gmail_from, 'friend@dromelib.org'
    #
    # Env values have precedence over the yaml ones, so GMail will look for
    # emails from that address.
    def set_value_for(variable, value)
      (name = name_for(variable)) && ENV[name] = value
    end
  end
end
