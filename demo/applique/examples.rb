require 'ae'
require 'ostruct'

When /Given a template/ do |text|
  @template = text.strip
end

When /given a local binding/ do |code|
  @code = code
end

When /The result will be/ do |text|
  b = binding
  Kernel.eval(@code, b)
  result = RagTag.compile(@template, b).to_xhtml
  # IMPORTANT! We remove the new lines only b/c JRuby inserts extras.
  #            Don't know why, but there you are.
  text   = text.strip.delete("\n")
  result = result.strip.delete("\n")
  text.assert == result
end

