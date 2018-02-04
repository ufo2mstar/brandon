require 'rspec'
require_relative 'brandon'

describe Brandon do
  let(:curr_dir) {File.dirname(__FILE__)}
  let(:root_dir) {"."}


  context Brandon::Reader do

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

  end

  context "Static methods" do

    it "init in curr dir with a template yml" do
      # bran = Brandon.build
      # expect(bran.root_dir).to eq(".")
    end

    it "foundation" do

    end

    it "file_parse" do
      curr_file = __FILE__
      exp = Brandon.file_parse curr_file
      res = ["C:/Users/kyu-homebase/repos/gems/brandon/lib", "brandon_spec", ".rb"]
      expect(exp).to eq(res)
    end

  end

  context "ultimately" do
    it "should take the tree yml and create the directory structure" do

    end
  end

end