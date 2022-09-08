# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "territory"
require "json"

def load_geojson(name)
  JSON.parse(
    File.read(File.expand_path(name, __dir__)),
  )
end

require "minitest/autorun"
