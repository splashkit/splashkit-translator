#
# Parses HeaderDoc into Ruby
#
module Parser
  require 'nokogiri'

  # Monkey patch Nokogiri to squash data down
  require_relative '../lib/core_ext/nokogiri/xml.rb'

  module_function

  #
  # Checks if HeaderDoc is installed
  #
  def headerdoc_installed?
    system %(which headerdoc2html > /dev/null)
  end

  #
  # Parses HeaderDoc for the provided src directory into a hash
  #
  # @param src [String] the source directory where the SplashKit codebase is
  # @return [Hash] a hash with a representation of every header
  #
  def parse(src)
    hcfg_file = File.expand_path File.dirname __FILE__ + '/res/headerdoc.config'
    # If only parsing one file then don't amend /*.h
    src += '/*.h' unless src.end_with? '.h'
    parsed = Dir[src].map do |hfile|
      puts "Parsing #{hfile}..."
      cmd = %(headerdoc2html -XPOLltjbq -c #{hcfg_file} #{hfile})
      proc = IO.popen cmd
      out = proc.readlines
      hfile_xml = out.empty? ? nil : out.join
      unless $?.exitstatus.zero?
        raise ParserError,
              "headerdoc2html failed. Command was #{cmd}."
      end
      [File.basename(hfile), parse_xml(Nokogiri.XML(hfile_xml))]
    end
    parsed.to_h
  end

  private; module_function

  #
  # Class for raising parsing errors
  #
  class ParserError < StandardError; end

  #
  # Parses the docblock at the start of a .h file
  #
  def parse_header(xml)
    {
      name:         xml.xpath('//header/name').text,
      brief:        xml.xpath('//header/abstract').text,
      description:  xml.xpath('//header/desc').text
    }
  end

  #
  # Parses a single `@attribute` in a docblock
  #
  def parse_attribute(xml)
    [xml.xpath('name').text.to_sym, xml.xpath('value').text]
  end

  #
  # Parses all attributes in a docblock
  #
  def parse_attributes(xml)
    attrs = xml.xpath('.//attribute').map { |a| parse_attribute(a) }.to_h
    # Method, self, unique, destructor, constructor, getter, setter
    # must have a class attribute also
    enforce_class_keys = [
      :method,
      :self,
      :unique,
      :destructor,
      :constructor,
      :getter,
      :setter
    ]
    enforced_class_keys_found = attrs.keys & enforce_class_keys
    has_enforced_class_keys = !enforced_class_keys_found.empty?
    if has_enforced_class_keys && attrs[:class].nil?
      raise ParserError,
            "Attribute(s) `#{enforced_class_keys_found.map(&:to_s)
            .join('\', `')}' found, but `class' attribute is missing?"
    end
    # Can't have destructor & constructor
    if attrs[:destructor] && attrs[:constructor]
      raise ParserError,
            'Attributes `destructor` and `constructor` conflict.'
    end
    # Can't have (destructor | constructor) & (setter | getter)
    destructor_constructor_keys_found = attrs.keys & [:constructor, :destructor]
    getter_setter_keys_found = attrs.keys & [:getter, :setter]
    if !destructor_constructor_keys_found.empty? &&
       !getter_setter_keys_found.empty?
      raise ParserError,
            "Attribute(s) `#{destructor_constructor_keys_found.map(&:to_s)
            .join('\', `')}' violate `#{getter_setter_keys_found.map(&:to_s)
            .join('\', `')}'. Choose one or the other."
    end
    # Can't have (destructor | constructor) & method
    if !destructor_constructor_keys_found.empty? && !attrs[:method].nil?
      raise ParserError,
            "Attribute(s) `#{destructor_constructor_keys_found.map(&:to_s)
            .join('\', `')}' violate `method`. Choose one or the other."
    end
    # Can't have (setter | getter) & method
    if !getter_setter_keys_found.empty? && attrs[:method]
      raise ParserError,
            "Attribute(s) `#{getter_setter_keys_found.map(&:to_s)
            .join('\', `')}' violate `method`. Choose one or the other."
    end
    # If unique then method must be set
    if attrs[:unique] && attrs[:method].nil?
      raise ParserError,
            "Attribute `unique` is only valid if `method` attribute is also set"
    end
    attrs
  end

  #
  # Parses a single `@param` in a docblock
  #
  def parse_parameter(xml, hdoc_parsed_params)
    name = xml.xpath('name').text
    # Need to find the matching type, this comes from
    # the hdoc_parsed_params elements
    type = hdoc_parsed_params[name]
    if type.nil?
      raise ParserError,
            "Mismatched headerdoc @param '#{name}'. Check it exists
            in the signature."
    end
    [
      name.to_sym,
      {
        type:        type,
        description: xml.xpath('desc').text
      }
    ]
  end

  #
  # Parses all parameters in a docblock
  #
  def parse_parameters(xml, hdoc_parsed_params)
    xml.xpath('.//parameter').map do |p|
      parse_parameter(p, hdoc_parsed_params)
    end.to_h
  end

  #
  # Parses the docblock of a function
  #
  def parse_function(xml)
    signature = xml.xpath('declaration').text.split(/\n/).map(&:strip).join()
    # Values from the <parsedparamater> elements
    hdoc_pp = xml.xpath('.//parsedparameter').map do |p|
      [p.xpath('name').text, p.xpath('type').text]
    end.to_h
    {
      signature:   signature,
      name:        xml.xpath('name').text,
      description: xml.xpath('desc').text,
      brief:       xml.xpath('abstract').text,
      return_type: xml.xpath('returntype').text,
      returns:     xml.xpath('result').text,
      parameters:  parse_parameters(xml, hdoc_pp),
      attributes:  parse_attributes(xml)
    }
  rescue ParserError => e
    raise ParserError, "HeaderDoc parser error on `#{signature}`: #{e.message}"
  end

  #
  # Parses all functions in the xml provided
  #
  def parse_functions(xml)
    xml.xpath('//header/functions/function').map { |fn| parse_function(fn) }
  end

  #
  # Parses the XML into a hash representing the object model of every header
  # file
  #
  def parse_xml(xml)
    # TODO: Finish this off for types etc...
    parsed = parse_header(xml)
    parsed[:functions] = parse_functions(xml)
    parsed[:typedefs]  = nil
    parsed
  end
end
