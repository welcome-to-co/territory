require 'minitest/autorun'
require 'territory/sphericalmercator'


class SphericalMercatorTest < Minitest::Test

  MAX_EXTENT_MERC = [-20037508.342789244,-20037508.342789244,20037508.342789244,20037508.342789244];
  MAX_EXTENT_WGS84 = [-180,-85.0511287798066,180,85.0511287798066];

  describe 'SphericalMercator' do 

    before do 
      @sm = Territory::SphericalMercator.new
    end

    it 'should calculate ll with integer zoom' do 
      assert_equal @sm.ll([200, 200], 9), [-179.45068359375, 85.00351401304403]
    end

    it 'should calculate ll with float zoom' do 
      assert_equal @sm.ll([200, 200], 8.6574), [-179.3034449476476, 84.99067388699072]
    end

    it 'should calculate px with integer zoom' do 
      assert_equal @sm.px([-179, 85], 9), [364, 215]      
    end

    it 'should calculate px with float zoom' do 
      assert_equal @sm.px([-179, 85], 8.6574), [287.12734093961626, 169.30444219392666]
    end

    it 'should return tileranges for world extent' do 
      assert_equal @sm.xyz([-180,-85.05112877980659,180,85.0511287798066], 0, true), {minX:0,minY:0,maxX:0, maxY:0}
    end

    it 'should convert SW to proper tile ranges' do 
      assert_equal @sm.xyz([-180,-85.05112877980659,0,0], 1, true), {minX:0,minY:0,maxX:0, maxY:0}
    end

    it 'should handle negative xyz' do 
      assert_equal @sm.xyz([-112.5, 85.0511, -112.5, 85.0511], 0), {minX:0,minY:0,maxX:0, maxY:0}
    end 

    it 'should handle broken xyz' do 
      xyz = @sm.xyz([-0.087891, 40.95703, 0.087891, 41.044916], 3, true)
      assert xyz[:minX] <= xyz[:maxX]
      assert xyz[:minY] <= xyz[:maxY]
    end

    it 'should convert [0,0,0] to proper bbox' do 
      assert_equal @sm.bbox(0,0,0,true), [-180, -85.05112877980659, 180, 85.0511287798066]
    end

    it 'should convert [0,0,1] to proper bbox' do 
      assert_equal @sm.bbox(0,0,1,true), [-180,-85.05112877980659,0,0]      
    end

    it 'should convert WGS84 to 900913' do 
      assert_equal @sm.convert(MAX_EXTENT_WGS84, '900913'), MAX_EXTENT_MERC
    end

    it 'should convert 900913 to WGS84' do 
      assert_equal @sm.convert(MAX_EXTENT_MERC, 'WGS84'), MAX_EXTENT_WGS84
    end

  end



end
