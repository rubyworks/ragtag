# = rtals.rb
#
# == Copyright (c) 2006 Thomas Sawyer
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or redistribute this
#   software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#   FOR A PARTICULAR PURPOSE.
#
# == Author(s)
#
# * Thomas Sawyer

# Author::    Thomas Sawyer
# Copyright:: Copyright (c) 2006 Thomas Sawyer
# License::   Ruby License

require 'rexml/document'

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
#       <h1 rtal:content="x">[X]</h1>
#       <div rtal:each="animal" rtal:do="a">
#         <b rtal:content="a">[ANIMAL]</b>
#       </div>
#       <div rtal:if="animal.size > 1">
#         There are <b rtal:body="animal.size">[ANIMAL SIZE]</b> animals.
#       </div>
#     </body>
#     </html>
#   }
#
#   x = 'Our Little Zoo'
#   animal = ['Zebra', 'Monkey', 'Tiger' ]
#   out = ''
#
#   prg = RubyTals.compile( s )
#   puts eval(prg)
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
#       <div rtal:if="animal/plenty">
#
# and have a definition in the evaluateing code:
#
#   def animal.plenty
#     size > 1
#   end
#
# It's a classic Saftey vs. Usability trade-off. Something to
# consider for the future.

module RubyTals

  def self.compile( xmlstr )
    rxml = REXML::Document.new( xmlstr.strip )
    "out=''\n" + parse( rxml ) + "\nout"
  end

  def self.execute( script, data )
    vars.each_pair { |k,v|
    }
    eval script
  end

  def self.parse( xml )
    building = ''
    body = []

    xml.each do |elem|
      #p elem.class

      tag, mode = [], nil
      case elem
      when REXML::Element

        attributes, ruby_attributes = {}, {}
        elem.attributes.each { |k, v|
          if k =~ /^rtal:/i
            ruby_attributes[k.sub(/^rtal:/i,'')] = v
          else
            attributes[k] = v
          end
        }

        if ruby_attributes.empty?
          tag = add_tag( elem.name, parse( elem ), attributes )

        else
          if bd = ruby_attributes["content"]
            tag << "out << #{bd}.to_s"
          elsif bd = ruby_attributes["replace"]
            tag << "out << #{bd}.to_s"
            mode = :replace
          else
            tag << parse( elem )
          end

          if cond = ( ruby_attributes["if"] || ruby_attributes["condition"] )
            #mode = :replace
            tag = ([ "if #{cond}" ].concat( tag ) << "end")
          end

          if enum = ( ruby_attributes["each"] || ruby_attributes["repeat"] )
            loopf = "#{enum}.each do"
            if d = ruby_attributes["do"]
              loopf << " |#{d}|"
            end
            tag = ([ loopf ].concat( tag ) << "end")
          end

          unless mode == :replace  #unless attributes.empty? #
            tag = add_tag( elem.name, tag, attributes )
          end

        end

      else
        tag << "out << #{elem.to_s.inspect}"

      end

      body.concat tag
    end

    building << body.flatten.join("\n")
    return building
  end

  def self.add_tag( name, body, attributes={} )
    b = []
    if attributes.empty?
      b << "out << '<#{name}>'"
      b << body
      b << "out << '</#{name}>'"
    else
      s = ''
      s << "out << '<#{name} "
      s << attributes.collect { |k,v| %{#{k}="#{v}"} }.join(' ')
      s << ">'"
      b << s
      b << body
      b << "out << '</#{name}>'"
    end
    b
  end

  def self.loop_structure

  end

end




=begin

s = %q{
  <html>
  <body>
    <test>This is a test.</test>
    <h1 rtal:content="x">[X]</h1>
    <div rtal:each="animal" rtal:do="a">
      <b rtal:content="a">[ANIMAL]</b>
    </div>
    <div rtal:if="animal.size >= 1">
      <b rtal:body="animal.size">[ANIMAL SIZE]</b>
    </div>
  </body>
  </html>
}

x = '10'  # problem with numbers
animal = ['Zebra', 'Monkey', 'Tiger' ]
out = ''

prg = RubyTals.compile( s )
puts
puts prg
puts
puts eval(prg)

=end
