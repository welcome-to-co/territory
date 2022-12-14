# frozen_string_literal: true

module Territory
  def self.get_coord(coord)
    if !coord
      raise Error, "coord is required"
    end

    is_numeric = ->(i) { i.is_a? Numeric }
    if coord.is_a?(Array) && coord.length >= 2 && coord.all?(&is_numeric)
      return coord
    end

    if coord.is_a? Hash
      coord = deep_symbolize_keys(coord)

      is_feature = coord[:type] == "Feature"
      if is_feature && coord.fetch(:geometry, {})[:type] == "Point"
        return coord[:geometry][:coordinates]
      end

      if coord[:type] == "Point"
        return coord[:coordinates]
      end
    end

    raise Error, "coord must be GeoJSON Point or an Array of numbers"
  end

  def self.get_geom(geojson)
    return geojson[:geometry] if geojson[:type] == "Feature"

    geojson
  end
end
