require 'nokogiri'
require 'ragtag/core_ext/opvars'

# = RAGTAG - A Tag Attribute Language for Ruby
#
# RubyTals is a Ruby variation on Zope Page Templates and it's TAL specification.
# It differs from TAL in that it is specifically geared for use by Ruby.
#
# == Usage
#
#   s = %q{
#     <html>
#     <body>
#       <h1 r:content="x">[X]</h1>
#       <div r:each="animal" r:do="a">
#         <b r:content="a">[ANIMAL]</b>
#       </div>
#       <div r:if="animal.size > 1">
#         There are <b r:content="animal.size">[ANIMAL SIZE]</b> animals.
#       </div>
#     </body>
#     </html>
#   }
#
#   x = 'Our Little Zoo'
#   animal = ['Zebra', 'Monkey', 'Tiger' ]
#
#   puts Ragtag.compile(s, binding)
#
# == Note
#
# Presently RagTag clauses can run arbitraty Ruby code. Although
# upping the safety level before executing a compiled template
# should be sufficiently protective in most cases, perhaps it would
# be better to limit valid expressions to single object references,
# ie. 'this.that', and then use a substitution of '.' for '/'.
# Not only would this be highly protective, it would also be more
# compatible with the original TAL spec; albeit this isn't exacty
# how TALs interprets the '/' divider.
#
# On the other hand perhaps it is too much restraint. For instance
# it would require the if-clause in the above exmaple to be
# something like:
#
#       <div r:if="animal/plenty">
#
# and have a definition in the evaluating code:
#
#   def animal.plenty
#     size > 1
#   end
#
# It's a classic Saftey vs. Usability trade-off. Something to
# consider for the future.

class RagTag

  #
  attr :xml

  #
  attr :scope

  #
  def self.compile(xml, scope=nil)
    new(xml).compile(scope)
  end

  #def self.execute( script, data )
  #  vars.each_pair { |k,v|
  #  }
  #  eval script
  #end

  #
  def initialize(xml)
    case xml
    when String
      @xml = Nokogiri::XML(xml)
    else
      @xml = xml
    end
  end

  #
  def compile(scope=nil)
    scope = scope || $TOPLEVEL_BINDING
    parse(@xml.root, scope)
    xml
  end

  #def parse_all(node)
  #  while node
  #    parse(node)
  #    node = node.next
  #  end
  #end

  #$rtals_each_stack = []

  #
  def parse(node, scope)
    case node
    when Nokogiri::XML::Text
      # nothing
    when Nokogiri::XML::NodeSet
      parse_nodeset(node, scope)
    when Nokogiri::XML::Element
      if value = node['define']
        eval(value, scope)
      end

      if node['if']
        parse_if(node, scope)
      #elsif node['condition']
      #  parse_condition(node, scope)
      end

      if node['content']
        parse_content(node, scope)
      elsif node['replace']
        parse_replace(node, scope)
      end

      if node['attr'] || node['attributes']
        parse_attributes(node, scope)
      end

      if node['each']
        parse_each(node, scope)
        return
      elsif node['repeat']
        parse_repeat(node, scope)
        return
      end

      node.children.each do |child|
        parse(child, scope)
      end

      if node['omit'] && node['omit'] != 'false'
        parse_omit(node, scope)
      end
    else
      raise node.inspect
    end
    return node
  end

  #
  def parse_nodeset(nodeset, scope)
    nodeset.each do |node|
      parse(node, scope)
    end
    nodeset
  end

  #
  def parse_content(node, scope)
    value = node['content']
    node.content = eval(value, scope)
    node.remove_attribute('content')
  end

  #
  def parse_replace(node, scope)
    value = node['replace']
    node.before(eval(value, scope).to_s)
    node.unlink
  end

  #
  def parse_attributes(node, scope)
    if attrs = node['attr']
      assoc = attrs.split(',').map{ |e| e.strip.split(':') }
      assoc.each do |(k,v)|
        node[k] = eval(v, scope).to_s
      end
      node.remove_attribute('attr')
    end
    if attrs = node['attributes']
      assoc = attrs.split(',').map{ |e| e.strip.split(':') }
      assoc.each do |(k,v)|
        node[k] = eval(v, scope).to_s
      end
      node.remove_attribute('attributes')
    end
    node
  end

  #
  def parse_if(node, scope)
    value = node['if']
    if eval(value, scope)
      node.remove_attribute('if')
      parse(node.children, scope)
    else
      node.unlink
    end
    node
  end

  ## Like #parse_if but does not keep the conditional node.
  #def parse_condition(node, scope)
  #  value = node['condition']
  #  if eval(value, scope)
  #    parse(node.children, scope).each do |x|
  #      x.unlink
  #      node.add_previous_sibling(x) 
  #    end
  #    node.unlink
  #  else
  #    node.unlink
  #  end
  #end

  #
  def parse_each(node, scope)
    value = node['each']
    args  = node['do'] || 'x'
    copy  = node.dup
    node.children.remove
    bindings = eval("#{value}.map{ |#{args}| binding }", scope)
    bindings.each do |each_scope|
      sect = parse(copy.dup.children, each_scope)
      sect.each do |x|
        node << x
      end
    end
    node.remove_attribute('each')
    node.remove_attribute('do')
    value
  end

  #
  def parse_repeat(node, scope)
    value = node['repeat']
    args  = node['do'] || 'x'
    copy  = node.dup
    copy.remove_attribute('repeat')
    copy.remove_attribute('do')
    bindings = eval("#{value}.map{ |#{args}| binding }", scope)
    bindings.each do |each_scope|
      sect = parse(copy.dup, each_scope)
      node.add_previous_sibling(sect)
      # parse_omit(sect, scope) if sect['omit'] && sect['omit'] != 'false'
    end
    node.unlink
    value
  end

  #
  def parse_omit(node, scope)
    #parse(node.children, scope).each do |x|
    node.children.each do |x|
      x.unlink
      node.add_previous_sibling(x) 
    end
    node.unlink
  end

end

