# XMLTailor/Ruby - XML Document Transformer for Ruby
# An implementation of the XML Tag Attribute Insertion Language System (XMLTails)
# Copyright (c) 2002 Thomas Sawyer, Ruby License

# NEED TO CONSIDER THE SCOPE OF EVALS
# SHOULD THEIR EVALUTATION ONLY BE WITHIN THE CONTEXT OF THEIR TAG OR GLOBAL, AS THEY ARE NOW?


require 'tomslib/rerexml' 
require 'tomslib/filefetch'


class Tailor

  include TomsLib::FileFetch

  attr_reader :xml_document

  #
  def initialize(xml)
    xml_string = fetch_xml(xml)
    @xml_document = REXML::Document.new(xml_string)
    load_ruby
  end


  # Loads the ruby processing instruction.
  def load_ruby
    ruby_pi = @xml_document.find_all { |i| i.is_a? REXML::Instruction and i.target == 'xml:script' }
    ruby_pi.each do |pi|
      if pi.attributes['uri'] == 'ruby'
        load_eval(fetch_xml(pi.attributes['url']))
      end
    end
  end

  def load_eval(evaluate)
    eval(evaluate.untaint, TOPLEVEL_BINDING)
  end
  
  #
  def process

    # process imports
    process_import(@xml_document, TOPLEVEL_BINDING)

    # process each loops
    loops = REXML::XPath.match(@xml_document, '//*[@each]')
    loops.reverse!  # reverse loops to do inner nested loops first
    loops.each do |element|
      #
      new_element_string = ''
      element.write(new_element_string)
      #
      loop_each = element.attributes['each']
      if element.attributes.has_key?('do')
        loop_do = element.attributes['do']
      else
        loop_do = 'item'
      end
      # collect bindings
      indexer = "#{loop_do.split(',')[0]}_index"
      loop_eval = "i = -1 \n"
      loop_eval += "#{loop_each}.collect do |#{loop_do}| \n"
      loop_eval += "  #{indexer} = i += 1 \n"
      loop_eval += "  binding \n"
      loop_eval += "end \n"
      loop_bindings = eval(loop_eval.untaint, TOPLEVEL_BINDING)
      loop_bindings.each do |loop_binding|  # for each binding substitute items
        # make new element
        new_element_source = REXML::SourceFactory.create_from(new_element_string)
        new_element = REXML::Element.new(new_element_source)
        new_element.attributes.get_attribute('each').remove
        new_element.attributes.get_attribute('do').remove if element.attributes.has_key?('do')
        # process items
        process_eval(new_element.untaint, loop_binding)
        process_if(new_element, loop_binding)
        process_content(new_element, loop_binding)
        process_attributes_if(new_element, loop_binding)
        process_attributes(new_element, loop_binding)
        # insert the new element
        element.parent.insert_before(element, new_element)
      end
      element.remove
    end
    
    # those not contained in each loops
    process_eval(@xml_document, TOPLEVEL_BINDING)
    process_if(@xml_document, TOPLEVEL_BINDING)
    process_content(@xml_document, TOPLEVEL_BINDING)
    process_attributes_if(@xml_document, TOPLEVEL_BINDING)
    process_attributes(@xml_document, TOPLEVEL_BINDING)

  end


  # Process imports.
  def process_import(xml_context, eval_context)
    elements = REXML::XPath.match(xml_context, './/*[@import]')
    elements.each do |element|
      import = element.attributes['import'].strip
      xpath = element.attributes['xpath'].strip if element.attributes.has_key?('xpath')
      import_file, import_context = import.split('#')
      import_file.strip!
      import_context.strip! if import_context
      import_rxtal = Tailor.new(import_file)
      import_rxtal.process
      if import_context
        context_element = REXML::XPath.first(import_rxtal.xml_document, ".//*[@importable='#{import_context}']")
        if xpath
          import_nodes = REXML::XPath.match(context_element, xpath)
        else
          import_nodes = [context_element]
        end
      else
        if xpath
          import_nodes = REXML::XPath.match(import_rxtal.xml_document, xpath)
        else
          import_nodes = [import_rxtal.xml_document.root]
        end
      end
      import_nodes.each do |import_element|
        import_element.attributes.get_attribute('importable').remove if import_element.attributes.has_key?('importable')
        element.parent.insert_before(element, import_element)
      end
      element.remove
    end
  end


  # Process evaluations.
  def process_eval(xml_context, eval_context)
    elements = REXML::XPath.match(xml_context, './/*[@eval]')
    elements.each do |element|
      begin
        evaluate = element.attributes['eval'].strip
        eval(evaluate.untaint, eval_context)
        element.attributes.get_attribute('eval').remove
      rescue NameError
        next
      end
    end

  end
  

  # Process if conditions.
  def process_if(xml_context, eval_context)
    elements = REXML::XPath.match(xml_context, './/*[@if]')
    elements.each do |element|
      begin
        condition = element.attributes['if'].strip
        result = eval(condition.untaint, eval_context)
        if result
          element.attributes.get_attribute('if').remove
        else
          element.remove
        end
      rescue NameError
        next
      end
    end
  end
  
  
  # Process content substitutions.
  def process_content(xml_context, eval_context)
    elements = REXML::XPath.match(xml_context, './/*[@content]')
    elements.each do |element|
      begin
        content = element.attributes['content'].strip
        element.text = eval(content.untaint, eval_context).to_s
        element.attributes.get_attribute('content').remove
      rescue NameError
        next
      end
    end
  end


  # Process attributes if conditions.
  def process_attributes_if(xml_context, eval_context)
    elements = REXML::XPath.match(xml_context, './/*[@attributes_if]')
    elements.each do |element|
      begin
        assignments = element.attributes['attributes_if'].split('\\')
        assignments.each do |assignment|
          attribute_name, attribute_condition = assignment.split('=')
          attribute_name.strip!
          attribute_condition.strip!
          result = eval(attribute_condition.untaint, eval_context)
          if not result
            if element.attributes.has_key?(attribute_name)
              element.attributes.get_attribute(attribute_name).remove
            end
          end
        end
        element.attributes.get_attribute('attributes_if').remove
      rescue NameError
        next
      end
    end
  end


  # Process attributes substitutions.
  def process_attributes(xml_context, eval_context)
  
    elements = REXML::XPath.match(xml_context, './/*[@attributes]')
    elements.each do |element|
      begin
        assignments = element.attributes['attributes'].split('\\')
        assignments.each do |assignment|
          attribute_name, attribute_value = assignment.split('=')
          attribute_name.strip!
          attribute_value.strip!
          if element.attributes.has_key?(attribute_name)
            element.attributes[attribute_name] = eval(attribute_value.untaint, eval_context).to_s
          end
        end  
        element.attributes.get_attribute('attributes').remove
      rescue NameError
        next
      end
    end
  end

end
