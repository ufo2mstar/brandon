require 'rspec'
require_relative 'brandon'

describe Brandon do

  context "pieces" do
    describe "tree builder" do
      let(:tree_hash) {{main1: {sub1: nil, sub2: "sub2file1.txt", sub3: {sub4: ""}}, main2: ""}}
      let(:root_dir) {File.dirname(__FILE__)}
      subject {Brandon.new root_dir, tree_hash}

      it "should take the yml and store the dirs correctly" do
        res = %w[/main1 /main1/sub1 /main1/sub2/sub2file1.txt /main1/sub3/sub4/ /main2].map{|loc|"#{root_dir}#{loc}"}
        expect(subject.queue).to eq(res)
      end
      it "should take the yml and store the files correctly" do

      end

    end
  end

  context "ultimately" do
    it "should take the tree yml and create the directory structure" do

    end
  end

end