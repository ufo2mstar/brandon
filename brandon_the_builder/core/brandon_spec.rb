require_relative 'brandon'

describe 'Brandon' do
  THIS_DIR = File.dirname(__FILE__)
  context 'init' do
    it 'should start by reading data' do
      root = File.join(THIS_DIR, 'data', 'DEMO_SCRIPT_TEMPLATE')
      bran = BrandonBuilder.new root
      res = bran.create
      # expect(res).to match_array(exp)
    end
  end
end

