require_relative '../lib/dromelib'

require 'minitest/spec'
require 'minitest/autorun'

require 'climate_control'

require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

class Dromelib::Minitest
  @@config_sections = {}

  def self.yaml_content
    @@config_sections
  end

  def self.add_config_section section, config
    @@config_sections[section] = config
    @@config_sections
  end
end
