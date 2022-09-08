require 'test_helper'

class TerritoryCentroidTest < Minitest::Test

  # feature-collection
  # linestring
  # point
  # imbalanced-polygon
  %w[
    polygon
  ].each do |name|
    define_method "test_centroid_#{name}" do
      geojson = load_geojson "centroid/in/#{name}.geojson"
      out = load_geojson "centroid/out/#{name}.geojson"
      centered = Territory.centroid geojson, properties: { "marker-symbol": "circle" }
      results = Territory.feature_collection [centered]
      Territory.feature_each geojson do |feature|
        results[:features].push feature
      end
      assert_equal(
        Territory.send(:deep_symbolize_keys, out),
        results,
      )
    end
  end


end