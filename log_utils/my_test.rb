require 'test/unit'
require_relative 'cosmetics'

class Try
  def initialize &blk
    @hello = 1
    blk.call
    put
  end

  def put
    p "@hello #{@hello}"
    p "@world #{@world}"
  end
end


class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @loc = Try.new { @hello = 5; @world = 2 }
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail
    fail('Not implemented')
  end
  def put
    p "@hello #{@hello}"
    p "@world #{@world}"
  end
  def test_true_blk_test
    p @loc
    put
  end
end

require 'erb'
yml_str = '
<% 10.times { |n| %>
user_<%= n %>:
    username: <%= "user#{n}" %>
    email: <%= "user#{n}@example.com" %>
<% } %>'

aa = YAML.load ERB.new(yml_str).result
p aa
p yml_str