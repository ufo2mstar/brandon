require_relative '../core/brandon'
require 'rspec/snapshot'

describe 'BrandonBuilder' do
  THIS_DIR = File.dirname(__FILE__)
  context 'init' do
    it 'should read root path by default' do
      root = File.join(THIS_DIR, 'data', 'DEMO_SCRIPT_TEMPLATE')
      bran = BrandonBuilder.new root
      res = bran.template_map

      expect(res).to match_snapshot 'demo_init-template_map'
    end

    it 'should read data non-derfault' do
      root = File.join(THIS_DIR, 'data', 'DEMO_SCRIPT_TEMPLATE')
      bran = BrandonBuilder.new root, 'brandon_maps.yml'
      res = bran.template_map

      expect(res).to match_snapshot 'demo_init-template_map'
    end
  end

  context 'walk' do
    it 'should read dir files' do
      root = File.join(THIS_DIR, 'data', 'DEMO_SCRIPT_TEMPLATE')
      bran = BrandonBuilder.new root

      base = File.basename(root)
      dir = File.dirname(root)
      res = bran.dir_map.map{|s| s.gsub(dir,'')}
      expect(res).to match_snapshot 'demo_walk'
    end
  end
end

