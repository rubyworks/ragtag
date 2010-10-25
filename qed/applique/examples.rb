require 'ostruct'

When /Given a template/ do |text|
  @template = text
end

When /given a local binding/ do |code|
  @code = code
end

When /The result will be/ do |text|
  eval(@code, binding)
  result = RagTag.compile(@template, binding).to_xhtml
  text.strip.assert == result.strip
end

