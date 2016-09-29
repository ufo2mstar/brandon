# offset = 2
#
# p a=Dir[File.dirname(__FILE__)+"/*"]
# a.each { |name|
#   dirname = name[/\\|\/(\w+)$/, 1]
#   no, classname = dirname.split "_" rescue next
#   newno = "%.2d" % (no.to_i + offset)
#   p newname = newno+"_"+classname
#   # File.rename "./#{dirname}", "./#{newname}"
# }


# class String
#   def titilecase
#     self.split(' ').map { |w| w.capitalize }.join(' ')
#   end
#
#   def camelcase
#     self.gsub('_', ' ').downcase.titilecase.gsub(' ', '')
#   end
#
#   def snakecase
#     self.gsub(' ', '_').downcase
#   end
#   alias_method :downsnakecase, :snakecase
#
#   def upsnakecase
#     self.gsub(' ', '_').upcase
#   end
# end
#
# def shift text
#   case text
#     when /^[\s]*[^a-z][\S]*([\s]+[^a-z][\S]*)*[\s]*$/
#       return text.gsub('_', ' ').downcase
#     when /^[^a-z ]+$/
#       return text.gsub('_', ' ').downcase.titilecase
#     # return text.gsub('_', ' ').downcase.titilecase.gsub(' ', '')
#     else
#       return text.gsub(' ', '_').upcase
#   end
# end
#
# text= "enna Kod sarav_hai"
# p shift text
# p shift shift text
# p shift shift shift text
#
#
# p text.titilecase
# p text.camelcase
# p text.snakecase
# p text.downsnakecase
# p text.upsnakecase