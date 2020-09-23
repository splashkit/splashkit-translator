require_relative 'logger'

#
# Parses HeaderDoc into Ruby
#
class Parser
  # Monkey patch Nokogiri to squash data down
  require 'nokogiri'
  require_relative '../lib/core_ext/nokogiri/xml'

  # Improved IO
  require 'open3'

  # Logging support
  include Logger

  # Case conversion helpers
  require_relative '../lib/core_ext/string'

  #
  # Which `@attribute`s are currently allowed
  #
  ALLOWED_ATTRIBUTES = %i(
    group
    note
    class
    static
    method
    constructor
    destructor
    self
    suffix
    getter
    setter
    no_destructor
  ).freeze

  #
  # Checks if HeaderDoc is installed
  #
  def headerdoc_installed?
    system %(which headerdoc2html > /dev/null)
  end

  #
  # Initialiser with src
  #
  def initialize(src, logging)
    @src = src
    @logging = logging
  end

  #
  # Parses HeaderDoc for the provided src directory into a hash
  #
  def parse
    unless headerdoc_installed?
      raise Parser::Error, 'headerdoc2html is not installed!'
    end
    hcfg_file = File.expand_path('../../res/headerdoc.config', __FILE__)

    parsed = @src.map do |hfile|
      puts "Parsing #{hfile}..." if @logging
      cmd = %(headerdoc2html -XPOLltjbq -c #{hcfg_file} #{hfile})
      _, stdout, stderr, wait_thr = Open3.popen3 cmd
      out = stdout.readlines
      errs = stderr.readlines.join.gsub(/-{3,}(?:.|\n)+?-(?=\n)\n/, '').split("\n")
      errs.each do |e|
        # Fix headerdoc warning of unknown fields
        e = e.gsub(/:Unknown field type/, ': warning: Unknown field type')
        unless e =~ /(Warning: UID.*)|(No default encoding.*)|(specifying an appropriate value.*)/
          warn e.to_s
        end
      end
      exit_status = wait_thr.value.exitstatus
      hfile_xml = out.empty? ? nil : out.join
      unless exit_status.zero?
        raise Parser::Error,
              "headerdoc2html failed. Command was #{cmd}."
      end
      xml = Nokogiri.XML(hfile_xml)
      hfparsed = HeaderFileParser.new(hfile, xml).parse
      hfname = hfparsed[:name]
      hfparsed.delete(:name)
      [hfname, hfparsed]
    end

    if parsed.empty?
      raise Parser::Error,
            "Nothing parsed! Check that `#{@src.join('`, `')}` is the correct "\
            'SplashKit directory and that coresdk/src/coresdk contains the '\
            'correct C++ source. Check that HeaderDoc comments exist '\
            '(refer to README).'
    end
    parsed.to_h
  end
end

#
# Class for raising parsing errors
#
class Parser::Error < StandardError
  attr_accessor :signature

  def initialize(message, signature = nil)
    @message = message =~ /(?:\?|\.)$/ ? message : message << '.'
    return super(message) unless signature
    @signature = signature
  end

  def to_s
    if @signature
      "Parser violation for `#{@signature}`: #{@message}"
    else
      @message
    end
  end
end

#
# Class for raising parsing rule errors
#
class Parser::RuleViolationError < Parser::Error
  def initialize(message, rule_no)
    super message << "\n\tSee "\
          "https://github.com/splashkit/splashkit-translator\#rule-#{rule_no} "\
          'for more information.'
  end
end

#
# Class to parse a single header file
#
class Parser::HeaderFileParser
  attr_reader :name

  # Logging support
  include Logger

  #
  # Initialises a header parser with required data
  #
  def initialize(file, input_xml)
    @path =
      if file.include? SK_SRC_CORESDK
        file[file.index(SK_SRC_CORESDK)..-1] # remove user-part of src path
      else
        file
      end
    @filename = File.basename(file)
    @header_attrs = {}
    @input_xml = input_xml
    @unique_names = { unique_global: [], unique_method: [] }
  end

  #
  # Parses the header file
  #
  def parse
    # Start directly from 'header' node
    result = parse_xml(@input_xml.xpath('header'))
  end

  private

  #
  # A function which will default to the ppl provided if they are missing
  # within the hash provided using the parse_func provided. It will also
  # add missing data it finds using the parse_func.
  #
  def ppl_default_to(xml, hash, ppl, parse_func = :parse_parameter_info)
    ppl.each do |p_name, p_type|
      args = [xml || Nokogiri::XML(''), p_name, p_type]
      ppl_data = parse_func ? send(parse_func, *args) : {}
      p_name = p_name.to_sym
      hash[p_name] ||= {}
      # Merge in data that does not exist in hash
      ppl_data.each do |ppl_key, ppl_value|
        old_value = hash[p_name][ppl_key]
        # PPL parsed has an array bigger? Trust that (e.g., array_dimension_sizes)
        array_mismatch = (old_value.is_a?(Array) && ppl_value.is_a?(Array) &&
                          old_value.length < ppl_value.length)
        # PPL parsed is true when original data is false? Trust that
        truth_mismatch = (old_value === false && ppl_value === true)
        # PPL parsed has found a key which did not exist previously
        nil_mismatch = old_value == nil
        # Update to PPL value if mismatch
        hash[p_name][ppl_key] = ppl_value if array_mismatch || truth_mismatch || nil_mismatch
      end
    end
    hash
  end

  #
  # Parses HeaderDoc's parsedparameterlist (ppl) element
  #
  def parse_ppl(xml)
    xml.xpath('parsedparameterlist/parsedparameter').map.with_index do |p, idx|
      [p.xpath('name').text.to_sym, { type: p.xpath('type').text, index: idx }]
    end.to_h
  end

  #
  # Parses the parameter declaration
  #
  def parse_parameter_declaration(xml)
    # Extract declaration details from the xml
    decl = xml.xpath('declaration')
    decl_types = decl.xpath('declaration_type')
    # Get the type of the function
    fn_type = decl_types[0].children.to_s
    # types of the parameters...
    param_types = decl_types[1..-1].map(&:text)
    # names of the parameters
    param_names = decl.xpath('declaration_param').map { |n| n.text.to_sym }
    # names of type parameters
    template_types = decl.xpath('declaration_template').map(&:text)
    # i tracks the template_types... first may be the return type
    i = fn_type == 'vector' ? 1 : 0
    param_map = Hash[*param_names.zip(param_types).map do |n, t|
      result = { n => { base_type: t } }
      if t == 'vector'
        result[n][:type_parameter] = template_types[i]
        i += 1
      end
      result
    end.collect(&:to_a).flatten]

    unless i == template_types.count
      raise Parser::Error,
            "Unknown template type... mapped #{i + 1} or #{param_types.count + 1} templates!"
    end

    # Insert in index and type
    ppl = parse_ppl(xml)
    ppl.each do |key, data|
      param_map[key][:index] = data[:index]
      param_map[key][:type] = data[:type]
    end

    param_map
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
    @header_attrs = parse_attributes(xml)
    group = @header_attrs[:group]
    name = xml.xpath('name').text
    name = name[0..name.index('.h') - 1] if name.end_with?('.h') # Trim .h
    if group.nil?
      raise Parser::Error, "Group attribute is missing for header `#{name}.h`"
    end
    {
      name:         name,
      group:        group,
      brief:        xml.xpath('abstract').text,
      description:  xml.xpath('desc').text,
      parsed_at:    Time.now.to_i,
      path:         @path
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
    attrs = xml.xpath('attributes/attribute')
               .map { |a| parse_attribute(a) }
               .reject { |k, _| k == :Author }
               .to_h
               .merge @header_attrs
    # Check for unknown keys
    unknown_attributes = attrs.keys - Parser::ALLOWED_ATTRIBUTES
    unless unknown_attributes.empty?
      raise Parser::Error, 'Unknown attribute keys are present: '\
                           "`#{unknown_attributes.join('`, `')}`"
    end

    # `self` must be supplied to class, methods, getter, setters and destructors
    instance_needs_self_attr = attrs.keys & [:method, :destructor, :getter, :setter]
    if attrs[:class] && !instance_needs_self_attr.empty? && attrs[:self].nil?

      if ppl.length > 0
        attrs[:self] = ppl.keys.first.to_s
      else
        raise Parser::RuleViolationError.new(
              'Instance feature must have a self attribute', 14)
      end
    end

    # Method, self, destructor, constructor must have a class attribute also
    enforce_class_keys = [
      :self,
      :destructor,
      :constructor
    ]
    enforced_class_keys_found = attrs.keys & enforce_class_keys
    has_enforced_class_keys = !enforced_class_keys_found.empty?
    if has_enforced_class_keys && attrs[:class].nil?
      raise Parser::RuleViolationError.new(
            "Attribute(s) `#{enforced_class_keys_found.map(&:to_s)
            .join('\', `')}' found, but `class' attribute is missing?", 1)
    end
    # `method`, `getter` or `setter` must have `class` or `static`
    method_getter_static_keys_found = attrs.keys & [:method, :getter, :setter]
    class_static_keys_found = attrs.keys & [:class, :static]
    if !method_getter_static_keys_found.empty? &&
       class_static_keys_found.empty?
      raise Parser::RuleViolationError.new(
            'Attributes `getter` and `setter` must also specify either ' \
            '`class` or `static` attributes (or both).', 2)
    end
    # Can't have `destructor` & `constructor`
    if attrs[:destructor] && attrs[:constructor]
      raise Parser::RuleViolationError.new(
            'Attributes `destructor` and `constructor` conflict.', 3)
    end
    # Can't have (`destructor` | `constructor`) & (`setter` | `getter`) if
    # not marked with `static`
    marked_with_static = !attrs[:static].nil?
    destructor_constructor_keys_found = attrs.keys & [:constructor, :destructor]
    getter_setter_keys_found = attrs.keys & [:getter, :setter]
    if !destructor_constructor_keys_found.empty? &&
       !getter_setter_keys_found.empty? &&
       !marked_with_static
      raise Parser::RuleViolationError.new(
            "Attribute(s) `#{destructor_constructor_keys_found.map(&:to_s)
            .join('\', `')}' violate `#{getter_setter_keys_found.map(&:to_s)
            .join('\', `')}'. Choose one or the other.", 4)
    end
    # Can't have (`destructor` | `constructor`) & `method` if no `static`
    if !attrs[:constructor].nil? &&
       !attrs[:method].nil? &&
       !marked_with_static
      raise Parser::RuleViolationError.new(
            "Attribute(s) `constructor' violate `method`. Choose one or the other " \
            'or mark with `static` to indicate that this is a static ' \
            'method.', 5)
    end
    # Can't have (`setter` | `getter`) & `method` if no `static`
    if !getter_setter_keys_found.empty? &&
       attrs[:method] &&
       !marked_with_static
      raise Parser::RuleViolationError.new(
            "Attribute(s) `#{getter_setter_keys_found.map(&:to_s)
            .join('\', `')}' violate `method`. Choose one or the other " \
            'or mark with `static` to indicate that this is a static ' \
            'method.', 6)
    end
    # Ensure `self` matches a parameter
    self_value = attrs[:self]
    if self_value && ppl && ppl[self_value.to_sym].nil?
      raise Parser::RuleViolationError.new(
            'Attribute `self` must be set to the name of a parameter.', 7)
    end
    # Ensure the parameter set by `self` attribute has the same type indicated
    # by the `class`
    if self_value && ppl
      class_type = attrs[:class]
      self_type  = ppl[self_value.to_sym][:type]
      unless class_type == self_type || "const #{class_type} &amp;" == self_type
        raise Parser::RuleViolationError.new(
              'Attribute `self` must list a parameter whose type matches ' \
              "the `class` value (`class` is `#{class_type}` but `self` " \
              "is set to parameter (`#{self_value}`) with type " \
              "`#{self_type}`).", 8)
      end
    end
    # `getter` must be non-void
    ret_type = parse_function_return_type(xml)
    is_void = ret_type && ret_type[:type] == 'void' && !ret_type[:is_pointer]
    if attrs[:getter] && is_void
      raise Parser::RuleViolationError.new(
            'Function marked with `getter` must return something (i.e., '\
            'it should not return `void`).', 9)
    end
    # `class` rules applicable to `getter`s and `setter`s
    if attrs[:class]
      # Getters must have 1 parameter which is self
      if attrs[:getters] && ppl && ppl.length != 1 && attrs[:self]
        raise Parser::RuleViolationError.new(
              'A `getter` specified with `class` must have exactly one '\
              'parameter that is the parameter specified by the '\
              'attribute `self`.', 10)
      end
      # Setters must have 2 parameters
      if attrs[:setters] && ppl && ppl.length != 2 && attrs[:self] == ppl.keys.first
        raise Parser::RuleViolationError.new(
              'A `setter` specified with `class` must have exactly two '\
              'parameters of which the first parameter is the parameter '\
              'specified by the attribute `self`.', 11)
      end
    end
    # `static` rules applicable to `getter`s and `setter`s
    if attrs[:static]
      # Getters must have 0 parameters
      if attrs[:getters] && ppl && ppl.empty?
        raise Parser::RuleViolationError.new(
              'A `getter` specified with `static` must have no parameters',
              12)
      end
      # Setters must have 2 parameters
      if attrs[:setters] && ppl && ppl.length != 2
        raise Parser::RuleViolationError.new(
              'A `setter` specified with `static` must have one parameter', 13)
      end
    end
    attrs
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
      raise Parser::Error,
            'Only 1 and 2 dimensional arrays are supported at this time ' \
            "(got a #{dims.length}D array for `#{search_for_name}')."
    end
    dims
  end

  #
  # Returns parameter type information based on the type and desc given
  #
  def parse_parameter_info(xml, param_name, ppl_type_data)
    regex = /(?:(const)\s+)?((?:unsigned\s)?\w+)\s*(?:(&amp;)|(\*)|(\[\d+\])*)?/
    _, const, type, ref, ptr = *(ppl_type_data[:type].match regex)

    # Grab template <T> value for parameter
    is_vector = type == 'vector'
    array = parse_array_dimensions(xml, param_name)

    if is_vector && ppl_type_data[:type_parameter].nil?
      raise Parser::Error, "Vector with unknown type parameter! #{param_name}, #{type_details}"
    end

    {
      type: type,
      description: xml.xpath('desc').text,
      is_pointer: !ptr.nil?,
      is_const: !const.nil?,
      is_reference: !ref.nil?,
      is_array: !array.empty?,
      array_dimension_sizes: array,
      is_vector: is_vector,
      type_parameter: ppl_type_data[:type_parameter]
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
      raise Parser::Error,
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
    xml = xml.xpath('parameterlist/parameter')
    params = xml.map do |p|
      parse_parameter(p, ppl)
    end.to_h
    # At this point the params that can be parsed have been taken
    # from the xml... so pass in an empty xml for others.
    ppl_default_to(nil, params, ppl)
    # Check for parameters that have no assigned description
    params_with_no_desc = params.select { |_, p| p[:description].nil? }.keys
    if params_with_no_desc.count > 0
      raise Parser::Error, 'Missing parameters description for: '\
                           "`#{params_with_no_desc.join('`, `')}`"
    end
    # Sort parameters by PPL index (for type information)
    # That is, sorted by source code param index not documentation param index
    params = params.sort do |a, b|
      a_key = a[0]
      b_key = b[0]
      # Compare using the parsed PPL indicies
      ppl[a_key][:index] <=> ppl[b_key][:index]
    end.to_h
    params
  end

  #
  # Returns vector information if a vector is parsed
  #
  def parse_vector(xml, type)
    # Extract template <T> value for parameter
    is_vector = type == 'vector'
    if is_vector
      # Check if return type...
      type_parameter = xml.xpath('declaration/declaration_template').text
      if type_parameter.nil?
        # check if
        raise Parser::Error, 'Unable to detect vector type!'
      end
    end
    # Vector of vectors...
    if is_vector && type_parameter == 'vector'
      raise Parser::Error, 'Vectors of vectors not yet supported!'
    end
    [
      type_parameter,
      is_vector
    ]
  end

  #
  # Parses a function (pointer) return type
  #
  def parse_function_return_type(xml, raw_return_type = nil)
    returntype_xml = xml.xpath('returntype')
    # Return if no results
    return if returntype_xml.empty? && raw_return_type.nil?
    raw_return_type ||= returntype_xml.text
    ret_type_regex = /((?:unsigned\s)?\w+)\s*(?:(&)|(\*)?)/
    _, type, ref, ptr = *(raw_return_type.match ret_type_regex)
    is_pointer = !ptr.nil?
    is_reference = !ref.nil?
    # Extract <T> from generic returns
    type_parameter, is_vector = *parse_vector(xml, type)
    desc = xml.xpath('result').text
    is_proc = type == 'void' &&                 # returns void
              !(is_pointer || is_reference) &&  # not void* or void&
              (raw_return_type.nil? ||          # with no raw_return_type
               raw_return_type == 'void')       # or a void raw_return_type
    is_func = !is_proc
    # Check that procedures don't have return description
    if is_proc && !desc.nil?
      raise Parser::Error,
            'Pure procedures should not have an `@returns` labelled.'
    end
    # Check for empty return description
    if is_func && desc.nil?
      raise Parser::Error,
            'Non-void functions should have an `@returns` labelled.'
    end
    {
      type: type,
      description: desc,
      is_pointer: is_pointer,
      is_reference: is_reference,
      is_vector: is_vector,
      type_parameter: type_parameter,
    }
  end

  #
  # Parses a function's name for both a unique and standard name
  #
  def parse_function_names(xml, attributes)
    # Originally, headerdoc does overloaded names like name(int, const float).
    headerdoc_overload_tags = /const|\(|\,\s|\)|&|\*/
    fn_name = xml.xpath('name').text
    headerdoc_idx = fn_name.index(headerdoc_overload_tags)
    sanitized_name = headerdoc_idx ? fn_name[0..(headerdoc_idx - 1)] : fn_name
    suffix = "_#{attributes[:suffix]}" if attributes && attributes.include?(:suffix)
    # Make a method name if specified
    method_name = attributes[:method] if attributes
    class_name = attributes[:class] if method_name

    # Make a unique name using the suffix if specified
    unique_global_name = "#{sanitized_name}#{suffix}"
    unique_method_name = "#{class_name}.#{method_name}#{suffix}" unless method_name.nil?

    # Check if unique name is actually unique
    if @unique_names[:unique_global].include? unique_global_name
      raise Parser::RuleViolationError.new(
            'Generated unique name (function name + suffix) is not unique: ' \
            "`#{sanitized_name}` + `#{suffix}` = `#{unique_global_name}`", 14)
    else
      @unique_names[:unique_global] << unique_global_name
    end

    # Unique method name was made?
    unless unique_method_name.nil?
      # Check if unique method name is actually unique
      if @unique_names[:unique_method].include? unique_method_name
        raise Parser::RuleViolationError.new(
              'Generated unique method name (method + suffix) is not unique: ' \
              "`#{class_name}.#{method_name}` + `#{suffix}` = `#{unique_method_name}`", 15)
      # Else register the unique name
      else
        @unique_names[:unique_method] << unique_method_name
      end
    end
    {
      sanitized_name: sanitized_name,
      method_name: method_name,
      unique_global_name: unique_global_name,
      unique_method_name: unique_method_name
    }
  end

  #
  # Parses the docblock of a function
  #
  def parse_function(xml)
    signature = parse_signature(xml)
    ppl = parse_parameter_declaration(xml)
    attributes = parse_attributes(xml, ppl)
    parameters = parse_parameters(xml, ppl)
    fn_names = parse_function_names(xml, attributes)
    return_data = parse_function_return_type(xml)
    {
      signature:          signature,
      name:               fn_names[:sanitized_name],
      method_name:        fn_names[:method_name],
      unique_global_name: fn_names[:unique_global_name],
      unique_method_name: fn_names[:unique_method_name],
      suffix_name:        fn_names[:suffix],
      description:        xml.xpath('desc').text,
      brief:              xml.xpath('abstract').text,
      return:             return_data,
      parameters:         parameters,
      attributes:         attributes
    }
  rescue Parser::Error => e
    e.signature = signature
    error e
    {}
  end

  #
  # Parses all functions in the xml provided
  #
  def parse_functions(xml)
    xml.xpath('functions/function').map { |fn| parse_function(fn) }
  end

  #
  # Parses a function-pointer typedef
  #
  def parse_function_pointer_typedef(xml)
    ppl = parse_ppl(xml)
    return_type = xml.xpath('declaration/declaration_type[1]').text
    params = parse_parameters(xml, ppl)
    {
      return: parse_function_return_type(xml, return_type),
      parameters: params
    }
  end

  #
  # Checks if a typedef is a function pointer typedef (else it's 'simple')
  #
  def typedef_is_a_fn_ptr?(xml)
    xml.xpath('@type').text == 'funcPtr'
  end

  #
  # Parses a typedef signature for extended information that HeaderDoc does
  # not parse in
  #
  def parse_simple_typedef(signature)
    regex = /typedef\s+(\w+)?\s+(\w+)\s+(\*)?(\w+);$/
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
    is_fn_ptr = typedef_is_a_fn_ptr?(xml)
    signature = parse_signature(xml)
    attributes = parse_attributes(xml)
    merge_data = is_fn_ptr ? parse_function_pointer_typedef(xml) : parse_simple_typedef(xml)
    data = {
      signature:           signature,
      name:                xml.xpath('name').text,
      description:         xml.xpath('desc').text,
      brief:               xml.xpath('abstract').text,
      attributes:          attributes,
      is_function_pointer: is_fn_ptr
    }.merge merge_data
    if attributes && attributes[:class].nil? && data[:is_pointer]
      raise Parser::RuleViolationError.new(
            'Typealiases to pointers must have a class attribute set', 16)
    end
    data
  rescue Parser::Error => e
    e.signature = signature
    error e
  end

  #
  # Parses all typedefs in the xml provided
  #
  def parse_typedefs(xml)
    xml.xpath('typedefs/typedef').map { |td| parse_typedef(td) }
  end

  #
  # Parses all fields in a struct
  #
  def parse_fields(xml, ppl)
    fields = xml.xpath('fieldlist/field').map do |p|
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
  rescue Parser::Error => e
    e.signature = signature
    error e
  end

  #
  # Parses all structs in the xml provided
  #
  def parse_structs(xml)
    xml.xpath('structs_and_unions/struct').map { |s| parse_struct(s) }
  end

  #
  # Parses enum numbers on a constant
  #
  def parse_enum_constant_numbers(xml, constants)
    xpath_query = "declaration/*[name() = 'declaration_var' or " \
                  "              name() = 'declaration_number']"
    result = xml.xpath(xpath_query)
    result.each_with_index do |parsed, i|
      # Is this a declaration_var?
      if parsed.name == 'declaration_var'
        # Does it exist in the list of constants?
        constant_name = parsed.text.to_sym
        if constants[constant_name]
          # Is the next a declaration_number?
          next_el = result[i+1]
          next unless next_el
          if next_el.name == 'declaration_number'
            # This number matches the constant
            constants[constant_name][:number] = next_el.text.to_i
          end
        end
      end
    end
    constants
  end

  #
  # Parse a single enum constant data
  #
  def parse_enum_constant(xml)
    { description: xml.xpath('desc').text }
  end

  #
  # Parses enum constants
  #
  def parse_enum_constants(xml, ppl)
    constants = xml.xpath('constantlist/constant').map do |const|
      [const.xpath('name').text.to_sym, parse_enum_constant(const)]
    end.to_h
    # after parsing <constant>, must ensure they align with the ppl
    missing_constants = (ppl.keys - constants.keys)
    # ppl for enums have no types! Thus, just check against keys
    unless missing_constants.empty?
      raise Parser::Error,
            "Constant(s) not tagged in enum definition: `'#{
            missing_constants.join('`, `')}'`. Check it exists in the enum" \
            'definition.'
    end
    ppl_default_to(xml, constants, ppl, nil)
    parse_enum_constant_numbers(xml, constants)
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
      attributes:  parse_attributes(xml)
    }
  rescue Parser::Error => e
    e.signature = signature
    error e
  end

  #
  # Parses all enums in the xml provided
  #
  def parse_enums(xml)
    xml.xpath('enums/enum').map { |e| parse_enum(e) }
  end

  #
  # Parses a single define
  #
  def parse_define(xml)
    definition_xpath = 'declaration/declaration_preprocessor[position() > 2]'
    {
      name:        xml.xpath('name').text,
      description: xml.xpath('desc').text,
      brief:       xml.xpath('abstract').text,
      definition:  xml.xpath(definition_xpath).text
    }
  end

  #
  # Parses all hash defines in the xml provided
  #
  def parse_defines(xml)
    xml.xpath('defines/pdefine').map { |d| parse_define(d) }
  end

  #
  # Parses the XML into a hash representing the object model of every header
  # file
  #
  def parse_xml(xml)
    parsed               = parse_header(xml)
    parsed[:functions]   = parse_functions(xml)
    parsed[:typedefs]    = parse_typedefs(xml)
    parsed[:structs]     = parse_structs(xml)
    parsed[:enums]       = parse_enums(xml)
    parsed[:defines]     = parse_defines(xml)
    parsed
  end
end
