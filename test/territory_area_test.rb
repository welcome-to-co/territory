require 'test_helper'

class TerritoryAreaTest < Minitest::Test

  def test_area
    [
      ["polygon", 7_766_240_997_209],
      ["polygon_holes", 101_998_969_915],
      ["multi_polygon", 20_310_537_131],
    ].each do |name, area|
      input = load_geojson "area/#{name}.geojson"
      assert_equal area, Territory.area(input).round
    end
  end

end