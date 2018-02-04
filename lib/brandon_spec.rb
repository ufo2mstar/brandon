require 'rspec'
require_relative 'brandon'

describe Brandon do

  context "tree build" do
    describe "tree builder" do
      let(:tree_hash) {{main1: {sub1: nil, sub2: "sub2file1.txt", sub3: {sub4: ""}}, main2: ""}}
      let(:root_dir) {File.dirname(__FILE__)}
      # let(:root_dir) {""}
      subject {Brandon.new root_dir, tree_hash}

      it "should take the yml and store the dirs and files correctly" do
        bran = build_at()
        res = %w[/main1/ /main1/sub1/ /main1/sub2/ /main1/sub2/sub2file1.txt /main1/sub3/ /main1/sub3/sub4/ /main2/].map {|loc| "#{root_dir}#{loc}"}
        expect(subject.paths).to eq(res)
      end

      it "should default location to current dir" do

      end

    end
  end

  context "ultimately" do
    it "should take the tree yml and create the directory structure" do

    end
  end

end