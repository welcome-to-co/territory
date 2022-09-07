require 'bigdecimal'
require 'bigdecimal/util'

module Territory

  class SphericalMercator

    attr_accessor :Bc, :Cc, :zc, :Ac

      @@cache = {

      }

      EPSLN =  1.0e-10, 
      D2R = Math::PI / 180.0, 
      R2D = 180.0 / Math::PI, 
      A = 6378137.0, 
      MAXEXTENT = 20037508.342789244

      def initialize(options = {})
        @size = options[:size] || 256.0
        if !@@cache[@size]
          c = {}
          c[:Bc] = []
          c[:Cc] = []
          c[:zc] = []
          c[:Ac] = []

          size = @size
          30.times do 
            c[:Bc].push(size / 360.0)
            c[:Cc].push(size / (2*Math::PI))
            c[:zc].push(size / 2.0)
            c[:Ac].push(size)
            size = size*2.0
          end
          @@cache[@size] = c
        end

        self.Bc = @@cache[@size][:Bc]
        self.Cc = @@cache[@size][:Cc]
        self.zc = @@cache[@size][:zc]
        self.Ac = @@cache[@size][:Ac]
      end

      def xyz(bbox, zoom, tms_style = false)
        ll = [bbox[0], bbox[1]]
        ur = [bbox[2], bbox[3]]

        px_ll = px(ll, zoom)
        px_ur = px(ur, zoom)

        x = [(px_ll[0] / @size).floor, ((px_ur[0]-1.0) / @size).floor]
        y = [(px_ur[1] / @size).floor, ((px_ll[1]-1.0) / @size).floor]

        bounds = {
          minX: ((x.min < 0) ? 0 : x.min),
          minY: ((y.min < 0) ? 0 : y.min), 
          maxX: x.max, 
          maxY: y.max
        }

        if tms_style
          tms = {
            minY: ((2.0**zoom) - 1) - bounds[:maxY], 
            maxY: ((2.0**zoom) - 1) - bounds[:minY]
          }
          bounds[:minY] = tms[:minY]
          bounds[:maxY] = tms[:maxY]
        end

        bounds
      end

      def bbox(x, y, zoom, tms_style = false)
        y = ((2**zoom) - 1) - y if tms_style
        _ll = [x * @size, (y + 1)*@size]
        _ur = [(x+1)*@size, y*@size]
        bbox = ll(_ll, zoom).concat(ll(_ur, zoom))
        bbox
      end

      def ll(px, zoom)
        if zoom.is_a?(Float)
          size = @size * (2.0**zoom)
          bc = size / 360.0
          cc = (size / (2.0*Math::PI))
          zc = size / 2.0
          g = (px[1] - zc) / -cc
          lon = (px[0] - zc) / bc
          lat = R2D * (2.0 * Math.atan(Math.exp(g)) - (0.5 * Math::PI)) 
          [lon ,lat]
        else
          g = (px[1] - self.zc[zoom]) / (-self.Cc[zoom])
          lon = (px[0] - self.zc[zoom]) / self.Bc[zoom]
          lat = R2D * (2.0 * Math.atan(Math.exp(g)) - (0.5 * Math::PI)) 
          [lon, lat]
        end
      end

      def px(ll, zoom)
        if zoom.is_a?(Float)
          size = @size * (2.0**zoom)
          d = size / 2.0
          bc = (size / 360.0)
          cc = (size / (2.0 * Math::PI))
          ac = size
          f = [0.9999, [Math.sin(D2R * ll[1]), -0.9999].max].min
          x = d + ll[0] * bc
          y = d + 0.5 * Math.log((1+f) / (1-f)) * -cc
          (x > ac) && (x = ac);
          (y > ac) && (y = ac);
          return [x, y];
        else
          d = self.zc[zoom]
          f = [0.9999, [Math.sin(D2R * ll[1]), -0.9999].max].min
          x = (d + ll[0] * self.Bc[zoom]).round
          y = (d + 0.5 * Math.log((1+f)/(1-f)) * (-self.Cc[zoom])).round
          (x > self.Ac[zoom]) && (x = self.Ac[zoom]);
          (y > self.Ac[zoom]) && (y = self.Ac[zoom]);
          return [x, y];
        end
      end

      def convert(bbox, to)
        if to == '900913'
          forward(bbox.slice(0,2)).concat(forward(bbox.slice(2, 4)))
        else
          inverse(bbox.slice(0,2)).concat(inverse(bbox.slice(2, 4)))
        end
      end

      def forward(ll)
        xy = [
          A * ll[0] * D2R, 
          A * Math.log(Math.tan((Math::PI * 0.25) + (0.5 * ll[1] * D2R)))
        ]
        (xy[0] > MAXEXTENT) && (xy[0] = MAXEXTENT);
        (xy[0] < -MAXEXTENT) && (xy[0] = -MAXEXTENT);
        (xy[1] > MAXEXTENT) && (xy[1] = MAXEXTENT);
        (xy[1] < -MAXEXTENT) && (xy[1] = -MAXEXTENT);
        xy
      end

      def inverse(xy)
        [
          (xy[0] * R2D / A), 
          ((Math::PI * 0.5) - 2.0 * Math.atan(Math.exp(-xy[1] / A))) * R2D
        ]
      end

  end

end