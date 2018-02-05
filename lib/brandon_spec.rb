require 'rspec'
require 'find'
require_relative 'brandon'

describe Brandon, :unit do
  let(:curr_dir) {File.dirname(__FILE__)}
  let(:root_dir) {"."}


  context Brandon::Reader do
    def build_subject file_path
      Brandon::Reader.new file_path
    end

    it "should fail gracefully for invalid files (nil and bad_path)" do
      invalid_file = 'non_existant_file.yml' # invalid path
      # expect(Brandon::Reader.new invalid_file).to raise_error(Brandon::FileNotFoundError)
      expect {Brandon::Reader.new nil}.to raise_error(TypeError)
      expect {Brandon::Reader.new invalid_file}.to raise_exception(Brandon::FileNotFoundError)
    end

    it "should read simple yml into hash" do
      blank_file = 'C:\Users\kyu-homebase\repos\gems\brandon\lib\simple_test.yml' # absolute path
      bran_reader = build_subject(blank_file)
      res = {"one" => {"two" => [:one, "two", "three", 4, "five", {"Object" => ["more", "stuff"]}], "three" => nil, "four" => "kod"}, "Two" => nil}
      expect(bran_reader.hsh).to eq(res)
    end

    it "should read blank yml into an empty hash" do
      blank_file = '.\blank_test.yml' # relative path
      bran_reader = build_subject(blank_file)
      res = {}
      expect(bran_reader.hsh).to eq(res)
    end
  end

  context Brandon::Parser do

    def build_subject tree, dir = root_dir
      Brandon::Parser.new dir, tree
    end

    def build_res ary, dir = root_dir
      ary.map {|loc| "#{dir}#{loc}"}
    end

    describe "should take the yml and store the dirs and files correctly for" do
      let(:tree_hash) {{main1: {sub1: nil, sub2: "sub2file1.txt", sub3: {sub4: "  ", sub5: '', :sub6 => :kod, :sub7 => 2342}}, main2: ""}}
      let(:blank_hash) {{}}
      let(:file_hash) {{main1: [nil, "", "  ", "str name.file", 1234, :symbol, Object, Hash.new, Array.new]}}
      let(:file_edgecase_hash) {{main2: {sub1: [:sub2 => [[:one, 'two'], 3], :sub3 => 2342]}}}

      # subject {Brandon.new root_dir, tree_hash}

      it "returns blank paths for blank tree hash" do
        bran = build_subject(blank_hash)
        expect(bran.paths).to eq([])
      end

      it "any type of file from ary" do
        tree = file_hash
        bran = build_subject(tree)
        # res = build_res %w[]
        res = build_res ["./main1/", "./main1/str name.file", "./main1/1234", "./main1/symbol", "./main1/Object"], ""

        expect(bran.paths).to eq(res)
      end

      it "even malformed edge cases" do
        tree = file_edgecase_hash
        bran = build_subject(tree)
        res = build_res ["./main2/", "./main2/sub1/", "./main2/sub1/sub2/", "./main2/sub1/sub2/one", "./main2/sub1/sub2/two", "./main2/sub1/sub2/3", "./main2/sub1/sub3/", "./main2/sub1/sub3/2342"], ""

        expect(bran.paths).to eq(res)
      end
    end
  end

  context Brandon::Builder do

    def build_subject paths_ary
      Brandon::Builder.new paths_ary
    end

    def build_res ary, dir
      ary.map {|loc| "#{dir}#{loc}"}
    end

    it "errors for blank input paths" do
      expect {build_subject nil}.to raise_error(Brandon::NoPathsWarning)
      expect {build_subject []}.to raise_error(Brandon::NoPathsWarning)
    end

    it "creates files and folders" do
      Dir.mktmpdir do |dir|
        paths_ary = ["/main2/", "/main2/sub1/", "/main2/sub1/sub2/", "/main2/sub1/sub2/one", "/main2/sub1/sub2/two", "/main2/sub1/sub2/3", "/main2/sub1/sub3/", "/main2/sub1/sub3/2342"]
        # paths_ary = ["/main2/", "/main2/sub1/", "/main2/sub1/sub2/", "/main2/sub1/sub2/one", "/main2/sub1/sub2/2342"]
        # paths_ary = ["/main2/", "/main2/sub1.txt", "/main2/sub3/"]

        paths_ary = build_res paths_ary, dir
        sub = build_subject(paths_ary)
        sub.build

        walk = Find.find("#{dir}/").map {|path| File.file?(path) ? path : "#{path}/"}
        walk.shift # remove the top level dir path from the ary

        expect(walk).to match_array(paths_ary)
      end
    end
  end

  context "Static methods" do

    it "init in curr dir with a template yml" do
      # bran = Brandon.build
      # expect(bran.root_dir).to eq(".")
    end

    it "foundation" do
      Dir.mktmpdir do |dir|
        # curr_file = FileUtils.touch "#{dir}/sample.txt"
        Brandon.foundation dir
        walk = Find.find("#{dir}/").map {|path| File.file?(path) ? path : "#{path}/"}
        exp = walk.pop
        res = [dir, '/sample_template', '.yml'].join
        expect(exp).to eq(res)
      end
    end

    it "file_parse" do
      Dir.mktmpdir do |dir|
        curr_file = "#{dir}/sample.txt"
        exp = Brandon.file_parse curr_file
        res = [dir, 'sample', '.txt']
        expect(exp).to eq(res)
      end
    end

    it "reads the dir path into dir.yml" do
      Dir.mktmpdir do |dir|
        # setup dir tree
        Brandon.foundation dir
        Brandon.build "#{dir}/sample_template.yml"
        FileUtils.rm "#{dir}/sample_template.yml"

        #
        Brandon.read "#{dir}/sample_template"
      end
    end
  end
end

describe Brandon, :integration do
  def build_res ary, dir
    ary.map {|loc| "#{dir}#{loc}"}
  end

  context "ultimately" do
    it "should take the tree yml and create the directory structure" do
      Dir.mktmpdir do |dir|
        # dir = "."
        Brandon.foundation dir
        Brandon.build "#{dir}/sample_template.yml"

        walk = Find.find("#{dir}/").map {|path| File.file?(path) ? path : "#{path}/"}
        walk.shift # remove the top level dir path from the ary
        # puts walk
        paths_ary = %W[
sample_template/
sample_template/Two/
sample_template/one/
sample_template/one/four/
sample_template/one/four/kod.rb
sample_template/one/three/
sample_template/one/two/
sample_template/one/two/4
sample_template/one/two/Object/
sample_template/one/two/Object/more
sample_template/one/two/Object/stuff
sample_template/one/two/five.js
sample_template/one/two/one
sample_template/one/two/three.txt
sample_template/one/two/two
sample_template.yml
        ]
        paths_ary = build_res paths_ary, "#{dir}/"

        expect(walk).to match_array(paths_ary)
      end
    end
  end

end