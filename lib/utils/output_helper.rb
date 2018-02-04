require 'yaml'

module OutputHelper
  def yp(obj, color=nil) # yaml print : yp
    p(obj.to_yaml, color ? color.to_sym : color) unless ENV['silent']
  end
end