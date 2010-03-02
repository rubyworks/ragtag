
require 'facets/more/tailor'

xt = Tailor.load('example.xtr')
xt.process
puts xt.xml_document

