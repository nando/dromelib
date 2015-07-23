# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../dromelib'

module Dromelib
  # Allow us to change the name of the environment variables used by the
  # library through the .dromelib.yml file.
  module Env
    extend self

    def name_for(variable)
      raise Dromelib::UninitializedError unless Dromelib.initialized?
      Dromelib::Config.environment_vars.send(variable)
    end

    def value_for(variable)
      (name = name_for(variable)) && ENV[name]
    end
  end
end
