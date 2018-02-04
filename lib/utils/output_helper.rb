# require 'yaml'
#
# module OutputHelper
#   def yp(obj, color=nil) # yaml print : yp
#     p(obj.to_yaml, color ? color.to_sym : color) unless ENV['silent']
#   end
# end
#
# require 'find'
#
# # Find.find("./"){ |path| puts path }
#
# dir = File.dirname __FILE__
# # Find.find("#{dir}/"){ |path| puts path }
#
# puts Find.find("#{dir}/").to_a