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
    hcfg_file = File.expand_path('../../res/headerdoc.config', __FILE__)
    # If only parsing one file then don't amend /*.h
    headers_src = "#{src}/coresdk/src/coresdk/*.h" unless src.end_with? '.h'
    parsed = Dir[headers_src || src].map do |hfile|
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
    if parsed.empty?
      raise ParserError, <<-EOS
Nothing parsed! Check that #{src} is the correct SplashKit directory and that
coresdk/src/coresdk contains the correct C++ source. Check that HeaderDoc
comments exist (refer to README).
EOS
    end
    parsed.to_h
  end

  private; module_function

  #
  # Class for raising parsing errors
  #
  class ParserError < StandardError
    def initialize(message, signature = nil)
      return super(message) unless signature
      @signature = signature
      super("HeaderDoc parser error on `#{signature}`: #{message}")
    end
  end

  #
  # A function which will default to the ppl provided if they are missing
  # within the params
  #
  def ppl_default_to(xml, params, ppl)
    ppl.each do |p_name, p_type|
      params[p_name] = (params[p_name] || {}).merge(
        parse_parameter_info(xml, p_name, p_type)
      )
    end
    params
  end

  #
  # Parses HeaderDoc's parsedparameterlist (ppl) element
  #
  def parse_ppl(xml)
    xml.xpath('./parsedparameterlist/parsedparameter').map do |p|
      [p.xpath('name').text.to_sym, p.xpath('type').text]
    end.to_h
  end

  #
  # Parses a signature from HeaderDoc's declaration element
  #
  def parse_signature(xml)
    xml.xpath('declaration').text.split(/\n/).map(&:strip).join()
  end

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
  def parse_attributes(xml, ppl = nil)
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
    # Can't have `destructor` & `constructor`
    if attrs[:destructor] && attrs[:constructor]
      raise ParserError,
            'Attributes `destructor` and `constructor` conflict.'
    end
    # Can't have (`destructor` | `constructor`) & (`setter` | `getter`)
    destructor_constructor_keys_found = attrs.keys & [:constructor, :destructor]
    getter_setter_keys_found = attrs.keys & [:getter, :setter]
    if !destructor_constructor_keys_found.empty? &&
       !getter_setter_keys_found.empty?
      raise ParserError,
            "Attribute(s) `#{destructor_constructor_keys_found.map(&:to_s)
            .join('\', `')}' violate `#{getter_setter_keys_found.map(&:to_s)
            .join('\', `')}'. Choose one or the other."
    end
    # Can't have (`destructor` | `constructor`) & method
    if !destructor_constructor_keys_found.empty? && !attrs[:method].nil?
      raise ParserError,
            "Attribute(s) `#{destructor_constructor_keys_found.map(&:to_s)
            .join('\', `')}' violate `method`. Choose one or the other."
    end
    # Can't have (`setter` | `getter`) & method
    if !getter_setter_keys_found.empty? && attrs[:method]
      raise ParserError,
            "Attribute(s) `#{getter_setter_keys_found.map(&:to_s)
            .join('\', `')}' violate `method`. Choose one or the other."
    end
    # Ensure `self` matches a parameter
    self_value = attrs[:self]
    if self_value && ppl && ppl[self_value.to_sym].nil?
      raise ParserError,
            'Attribute `self` must be set to the name of a parameter.'
    end
    # Ensure the parameter set by `self` attribute has the same type indicated
    # by the `class`
    if self_value && ppl
      class_type = attrs[:class]
      self_type  = ppl[self_value.to_sym]
      unless class_type == self_type
        raise ParserError,
              'Attribute `self` must list a parameter whose type matches ' \
              'the `class` value (`class` is `#{class_type}` but `self` ' \
              "is set to parameter (`#{self_value}`) with type `#{self_type}`)"
      end
    end
  end

  #
  # Parses array sizes from a given xml using its `<declaration>` and the
  # given type name desired. If no array sizes are found, nil is returned.
  # Otherwise each dimension and its size is given in order as an array.
  # E.g., float three_by_two_matrix[3][2] => [3,3]
  #
  def parse_array_dimensions(xml, search_for_name)
    xpath_query = 'declaration/*[preceding-sibling::declaration_type[' \
                  "text() = '#{search_for_name}']]"
    dims = xml.xpath(xpath_query).map(&:text).take_while(&:int?).map(&:to_i)
    if dims.length > 2
      raise ParserError,
            'Only 1 and 2 dimensional arrays are supported at this time ' \
            "(got a #{dims.length}D array for `#{search_for_name}')."
    end
    dims
  end

  #
  # Returns parameter type information based on the type and desc given
  #
  def parse_parameter_info(xml, param_name, ppl_type_data)
    regex = /(?:(const)\s+)?([^\s]+)\s*(?:(&amp;)|(\*)|(\[\d+\])*)?/
    _, const, type, ref, ptr = *(ppl_type_data.match regex)
    array = parse_array_dimensions(xml, param_name)
    {
      type: type,
      description: xml.xpath('desc').text,
      is_pointer: !ptr.nil?,
      is_const: !const.nil?,
      is_reference: !ref.nil?,
      is_array: !array.empty?,
      array_dimension_sizes: array
    }
  end

  #
  # Parses a single `@param` in a docblock
  #
  def parse_parameter(xml, ppl)
    name = xml.xpath('name').text
    # Need to find the matching type, this comes from
    # the parsed parameter list elements
    type = ppl[name.to_sym]
    if type.nil?
      raise ParserError,
            "Mismatched headerdoc @param '#{name}'. Check it exists in the " \
            'signature.'
    end
    [
      name.to_sym,
      parse_parameter_info(xml, name, type)
    ]
  end

  #
  # Parses all parameters in a docblock
  #
  def parse_parameters(xml, ppl)
    params = xml.xpath('.//parameter').map do |p|
      parse_parameter(p, ppl)
    end.to_h
    ppl_default_to(xml, params, ppl)
  end

  #
  # Parses the docblock of a function
  #
  def parse_function(xml)
    signature = parse_signature(xml)
    # Values from the <parsedparameter> elements
    ppl = parse_ppl(xml)
    # Originally, headerdoc does overloaded names like name(int, float).
    headerdoc_overload_tags = /const|\(|\,\s|\)|&|\*/
    # We will make our unique name: name__int__float or use the attribute
    # specified!
    fn_name = xml.xpath('name').text
    attributes = parse_attributes(xml, ppl)
    parameters = parse_parameters(xml, ppl)
    # Choose the unique name from the attributes specified, or make your
    # own using double underscore (i.e., headerdoc makes unique names for
    # us but we want to make them double underscore separated)
    unique_name =
      if attributes and attributes[:unique]
        attributes[:unique]
      elsif !(fn_name =~ headerdoc_overload_tags).nil?
        puts "No unique name for `#{fn_name}'! Creating default unique name."
        name = fn_name.split(headerdoc_overload_tags).first
        unless parameters.empty?
          types_part = parameters.values.pluck(:type).join('__')
          name << "__#{types_part}"
        end
        name
      else
        fn_name
      end
    # Original function name without the headerdoc overloaded name (if
    # applicable)
    fn_name = fn_name.split('(').first
    {
      signature:   signature,
      name:        fn_name,
      unique_name: unique_name,
      description: xml.xpath('desc').text,
      brief:       xml.xpath('abstract').text,
      return_type: xml.xpath('returntype').text,
      returns:     xml.xpath('result').text,
      parameters:  parameters,
      attributes:  attributes
    }
  rescue ParserError => e
    raise ParserError.new e.message, signature
  end

  #
  # Parses all functions in the xml provided
  #
  def parse_functions(xml)
    xml.xpath('//header/functions/function').map { |fn| parse_function(fn) }
  end

  #
  # Parses a typedef signature for extended information that HeaderDoc does
  # not parse in
  #
  def parse_typedef_signature(signature)
    regex = /typedef\s+([a-z]+)?\s+([a-z\_]+)\s+(\*)?([a-z\_]+);$/
    _,
    aliased_type,
    aliased_identifier,
    is_pointer,
    new_identifier = *(regex.match signature)
    {
      aliased_type: aliased_type,
      aliased_identifier: aliased_identifier,
      is_pointer: !is_pointer.nil?,
      new_identifier: new_identifier
    }
  end

  #
  # Parses a single typedef
  #
  def parse_typedef(xml)
    signature = parse_signature(xml)
    alias_info = parse_typedef_signature(signature)
    attributes = parse_attributes(xml)
    if attributes && attributes[:class].nil? && alias_info[:is_pointer]
      raise ParserError,
            "Typealiases to pointers must have a class attribute set"
    end
    {
      signature:   signature,
      alias_info:  alias_info,
      name:        xml.xpath('name').text,
      description: xml.xpath('desc').text,
      brief:       xml.xpath('abstract').text,
      attributes:  attributes
    }
  rescue ParserError => e
    raise ParserError.new e.message, signature
  end

  #
  # Parses all typedefs in the xml provided
  #
  def parse_typedefs(xml)
    xml.xpath('//header/typedefs/typedef').map { |td| parse_typedef(td) }
  end

  #
  # Parses all fields (marked with `@param`) in a struct
  #
  def parse_fields(xml, ppl)
    fields = xml.xpath('.//field').map do |p|
      # fields are marked with `@param`, so we just use parse_parameter
      parse_parameter(p, ppl)
    end.to_h
    ppl_default_to(xml, fields, ppl)
  end

  #
  # Parses a single struct
  #
  def parse_struct(xml)
    signature = parse_signature(xml)
    ppl = parse_ppl(xml)
    {
      signature:   signature,
      name:        xml.xpath('name').text,
      description: xml.xpath('desc').text,
      brief:       xml.xpath('abstract').text,
      fields:      parse_fields(xml, ppl),
      attributes:  parse_attributes(xml)
    }
  rescue ParserError => e
    raise ParserError.new e.message, signature
  end

  #
  # Parses all structs in the xml provided
  #
  def parse_structs(xml)
    xml.xpath('//header/structs_and_unions/struct').map { |s| parse_struct(s) }
  end

  #
  # Parses enum constants
  #
  def parse_enum_constants(xml, ppl)
    constants = xml.xpath('.//constant').map do |const|
      [const.xpath('name').text.to_sym, const.xpath('desc').text]
    end.to_h
    # after parsing <constant>, must ensure they align with the ppl
    constants.keys.each do | const |
      # ppl for enums have no types! Thus, just check against keys
      unless ppl.keys.include? const
        raise ParserError,
              "Mismatched headerdoc @constant '#{const}'. Check it exists " \
              'in the enum definition.'
      end
    end
    constants
  end

  #
  # Parses a single enum
  #
  def parse_enum(xml)
    signature = parse_signature(xml)
    ppl = parse_ppl(xml)
    {
      signature:   signature,
      name:        xml.xpath('name').text,
      description: xml.xpath('desc').text,
      brief:       xml.xpath('abstract').text,
      constants:   parse_enum_constants(xml, ppl),
      attributes:  parse_attributes(xml),
    }
  rescue ParserError => e
    raise ParserError.new e.message, signature
  end

  #
  # Parses all enums in the xml provided
  #
  def parse_enums(xml)
    xml.xpath('//header/enums/enum').map { |e| parse_enum(e) }
  end

  #
  # Parses the XML into a hash representing the object model of every header
  # file
  #
  def parse_xml(xml)
    parsed = parse_header(xml)
    parsed[:functions] = parse_functions(xml)
    parsed[:typedefs]  = parse_typedefs(xml)
    parsed[:structs]   = parse_structs(xml)
    parsed[:enums]     = parse_enums(xml)
    parsed
  end
end
