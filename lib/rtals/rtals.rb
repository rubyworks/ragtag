require 'nokogiri'
require 'facets/binding/opvars'

# = Tag Attribute Language for Ruby
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
#   puts RubyTals.compile(s, binding)
#
# == Note
#
# WARNING! This library is only minimally functional at this point.
# If you would like to use it please consider improving upon it!
#
# Presently rTAL clauses can run arbitraty Ruby code. Although
# upping the safety level before executing a compiled template
# should be sufficiently protective in most cases, perhaps it would
# be better to limit valid expressions to single object references,
# ie. 'this.that', and then use a substitution of '.' for '/'.
# Not only would this be highly protective, it would also be more
# compatible with the original TAL spec; albiet this isn't exacty
# how TALs interprets the '/' divider.
#
# On the other hand perhaps it is too much restraint. For instance
# it would require the if-clause in the above exmaple to be
# something like:
#
#       <div r:if="animal/plenty">
#
# and have a definition in the evaluateing code:
#
#   def animal.plenty
#     size > 1
#   end
#
# It's a classic Saftey vs. Usability trade-off. Something to
# consider for the future.

class RubyTals

  attr :xml

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
    @scope = scope || Object.new
    parse(@xml.root)
    xml
  end

  #def parse_all(node)
  #  while node
  #    parse(node)
  #    node = node.next
  #  end
  #end

  $rtals_each_stack = []

  #
  def parse(node)
    case node
    when Nokogiri::XML::Text
      # nothing
    when Nokogiri::XML::NodeSet
      parse_nodeset(node)
    when Nokogiri::XML::Element
      if value = node['content']
        node.content = eval(value, @scope)
      end

      if value = node['if']
        if eval(value, @scope)
          parse(node.children).each do |x|
            x.unlink
            node.parent.add_child(x)
          end
        end
        node.unlink
      end

      if value = node['each']
        copy = node.dup
        args = node['do'].split(',')
        eval(value, @scope).each do |*a|
          $rtals_each_stack << a
          eval("#{args} = *$rtals_each_stack.last", @scope)
          $rtals_each_stack.pop
          sect = parse(copy.dup.children)
          sect.each do |x|
            node.parent.add_child(x)
          end
        end
        node.unlink
        value
      end

      node.children.each do |child|
        parse(child)
      end
    else
      p node
      raise
    end
    return node
  end

  #
  def parse_nodeset(nodeset)
    nodeset.each do |node|
      parse(node)
    end
    nodeset
  end

end


if $0 == __FILE__

  xml = %q{
    <html>
    <body>
      <test>This is a test.</test>
      <h1 rtal:content="x">[X]</h1>
      <div rtal:each="animal" rtal:do="a">
        <b rtal:content="a">[ANIMAL]</b>
      </div>
      <div rtal:if="animal.size >= 1">
        <b rtal:content="animal.size">[ANIMAL SIZE]</b>
      </div>
    </body>
    </html>
  }

  x = '10'  # problem with numbers
  a = "Apple"
  animal = ['Zebra', 'Monkey', 'Tiger' ]

  rxml = RubyTals.compile(xml, binding)

  puts
  puts rxml
  puts

end

