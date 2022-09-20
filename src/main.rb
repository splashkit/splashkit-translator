#!/usr/bin/env ruby
require          'optparse'
require          'fileutils'
require          'json'
require          'colorize'
require_relative 'parser'
require_relative 'config'
require_relative 'translators/clib'
require_relative 'translators/pascal'
require_relative 'translators/python'
require_relative 'translators/csharp'
require_relative 'translators/cpp'
require_relative 'translators/dart'
# require_relative 'translators/rust'
require_relative 'translators/docs'

# Access to config vars
include Config

#
# Global run options
#
class RunOpts
  @tanslators = []
  @src = nil
  @out = nil
  @validate_only = false
  @write_to_cache = nil
  @read_from_cache = nil
  @verbose = false
  @logging = false
  @no_color = false
  class << self
    attr_accessor *(%i(
      translators
      src
      out
      validate_only
      write_to_cache
      read_from_cache
      verbose
      logging
      no_color
    ))
  end
end

#
# Parse options provided
#
def parse_options
  opt_parser = OptionParser.new do |opts|
    # Translators we can use
    avaliable_translators = Translators.all
    # Setup
    help =
      "Usage: translate --input /path/to/splashkit[/#{SK_SRC_CORESDK}/file.h]"\
      '                [--generate GENERATOR[,GENERATOR ... ]"'\
      '                [--output /path/to/write/output/to]"'\
      '                [--validate]'
    opts.banner = help
    opts.separator ''
    opts.separator 'Required:'
    # Source file
    help = 'Source header file or SplashKit CoreSDK directory'
    opts.on('-i', '--input SOURCE', help) do |input|
      RunOpts.src = File.expand_path input
    end
    # Generate using translator
    help = 'Comma separated list of translators to run on the file(s).'
    opts.on('-g', '--generate TRANSLATOR[,TRANSLATOR ... ]', help) do |translators|
      parsed_translators = translators.split(',')
      RunOpts.translators = parsed_translators.map do |translator|
        translator_class = avaliable_translators[translator.upcase.to_sym]
        if translator_class.nil?
          raise OptionParser::InvalidOption,
                "#{translator} - Unknown translator #{translator}"
        end
        translator_class
      end
    end
    # Output file(s)
    help = 'Directory to write output to (defaults to /path/to/splashkit/out/translated)'
    opts.on('-o', '--output OUTPUT', help) do |out|
      RunOpts.out = File.expand_path out
    end
    # Validate only (don't generate)
    help = 'Validate HeaderDoc only to parse without translating'
    opts.on('-v', '--validate', help) do
      RunOpts.validate_only = true
    end
    # Read parsed contents from cache
    help = 'Read parsed contents from a cache file'
    opts.on('-r', '--readcache FILE', help) do |file|
      RunOpts.read_from_cache = File.expand_path file
    end
    # Parse and cache parsed contents to file
    help = 'Write parsed contents to a cache file'
    opts.on('-w', '--writecache FILE', help) do |file|
      RunOpts.write_to_cache =
        if file.nil? && !RunOpts.read_from_cache.nil?
          RunOpts.read_from_cache
        else
          File.expand_path file
        end
    end
    opts.separator ''
    # Show warnings at the end of parsing
    help = 'Log HeaderDoc warnings after parsing'
    opts.on('-b', '--verbose', help) do
      RunOpts.verbose = true
    end
    help = 'Output log messages'
    opts.on('-l', '--logging', help) do
      RunOpts.logging = true
    end
    help = 'Format messages without colors'
    opts.on('', '--no-color', help) do
      RunOpts.no_color = true
    end
    opts.separator ''
    opts.separator 'Translators:'
    avaliable_translators.keys.each do |translator|
      opts.separator "* #{translator}".indent
    end
  end
  # Parse options block
  opt_parser.parse!
  mandatory = RunOpts.read_from_cache ? [] : [:src]
  # Add translators to mandatory if not validating
  mandatory << :translators unless RunOpts.validate_only
  missing = mandatory.select do |param|
    RunOpts.instance_variable_get("@#{param}").nil?
  end
  # Check if read cache files exist
  if RunOpts.read_from_cache
    unless File.exist?(RunOpts.read_from_cache)
      puts "No such cache file #{RunOpts.read_from_cache} -- ignoring..." if RunOpts.logging
    end
  end
  unless missing.empty?
    raise OptionParser::MissingArgument,
          "Missing #{missing.map(&:to_s).join(', ')} arguments"
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  exit 1
end

#
# Parses at the src provided
#
def run_parse_on_src(src)
  parser = Parser.new(src, RunOpts.logging)
  parsed = parser.parse
  if RunOpts.verbose
    parser.warnings.each do |msg|
      print RunOpts.no_color ? '' : '[WARN] '.yellow
      puts msg
    end
  end
  unless parser.errors.empty?
    parser.errors.each do |msg|
      print RunOpts.no_color ? 'ERROR: ' : '[ERR] '.red
      puts msg
    end
    puts 'Errors detected during parsing. Exiting.'
    exit 1
  end
  parsed
end

#
# Pre-parse setup (e.g., cache handling)
#
def run_parser
  # If only parsing one file then don't amend /*.h
  src =
    if RunOpts.src.end_with? '.h'
      [RunOpts.src]
    else
      Dir["#{RunOpts.src}/#{SK_SRC_CORESDK}/*.h"]
    end if RunOpts.src
  # Read cache contents if exists
  parsed =
    if RunOpts.read_from_cache && File.exist?(RunOpts.read_from_cache)
      parsed_from_cache =
        JSON.parse(File.read(RunOpts.read_from_cache), symbolize_names: true)
      # Source also provided?
      if src
        last_modified_hash = src.map do |path|
          [path[path.index(SK_SRC_CORESDK)..-1], File.mtime(path).to_i]
        end.to_h
        cache_data = parsed_from_cache.values
        # Re-parse those files which have been modified after the
        # last parsed_time
        to_parse =
          if RunOpts.src.end_with? '.h'
            path = RunOpts.src.split('/').last
            from_cache = cache_data.select { |p| p[:path].end_with? path }.first
            updated_since = last_modified_hash[from_cache[:path]] > from_cache[:parsed_at]
            updated_since ? [RunOpts.src] : []
          else
            cache_data.select { |p| last_modified_hash[p[:path]] > p[:parsed_at] }
                      .map { |p| "#{RunOpts.src}/#{p[:path]}" }
          end
        unless to_parse.empty?
          merge_data = run_parse_on_src(to_parse)
                        .map { |k,v| [k.to_sym, v] } # symbolize keys
                        .to_h
          parsed_from_cache.merge! merge_data
        end
        # Delete all those in parsed_from_cache that no longer exist in src
        no_longer_exists =
          cache_data.map { |p| p[:path] } -
          src.map { |s| s[s.index(SK_SRC_CORESDK)..-1] }
        parsed_from_cache.reject! do |k, p|
          no_longer_exists.include? p[:path]
        end
      end
      parsed_from_cache
    else
      run_parse_on_src(src)
    end
  # Write to cache file
  if RunOpts.write_to_cache
    out = RunOpts.write_to_cache
    data = parsed.clone
    FileUtils.mkdir_p File.dirname out
    File.write out, JSON.pretty_generate(data)
  end
  parsed
rescue Parser::Error
  puts $!.to_s
  exit 1
end

#
# Run the translator, or validate only if option set
#
def run_translate(parsed)
  if RunOpts.validate_only
    puts 'SplashKit API documentation valid!'
  else
    RunOpts.translators.each do |translator_class|
      translator = translator_class.new(parsed, RunOpts.logging)
      out = translator.execute
      next unless RunOpts.out
      out.each do |filename, contents|
        output = "#{RunOpts.out}/#{translator.name}/#{filename}"
        FileUtils.mkdir_p File.dirname output
        puts "Writing output to #{output}..." if RunOpts.logging
        File.write output, contents
      end
      puts 'Output written!'
      puts translator.post_execute
    end
  end
end

def empty_class_data(name)
  {
    name: name,
    is_alias: false,
    methods: [],
    properties: {},
    constructors: [],
    destructor: nil,
    is_struct: false
  }
end

def extract_classes_from_types(typedefs, structs)
  result = typedefs.select { |td| ! td[:is_function_pointer] }.map { |td|
    data = empty_class_data(td[:name])
    data[:is_alias] = true
    data[:alias_of] = td
    data[:no_destructor] = true if td[:attributes][:no_destructor]
    [
      td[:name], data
    ]
  }

  result = result + structs.map { |struct|
    struct[:properties] = {}
    struct[:constructors] = []
    struct[:methods] = []
    struct[:is_alias] = false
    struct[:is_struct] = true
    [
      struct[:name], struct
    ]
  }

  result.to_h
end

def allocate_methods(classes, functions)
  functions.select{ |fn|
    fn[:attributes] && fn[:attributes][:method] }.each do |fn|
    in_class = fn[:attributes][:class] || fn[:attributes][:static]
    in_class = in_class.downcase

    the_class = classes[in_class]
    if the_class.nil?
      classes[in_class] = empty_class_data(in_class)
      the_class = classes[in_class]
    end
    the_class[:methods] << fn
  end

  functions.select{ |fn| fn[:attributes] && (fn[:attributes][:getter] || fn[:attributes][:setter]) }.each do |fn|
    in_class = fn[:attributes][:class] || fn[:attributes][:static]
    in_class = in_class.downcase
    property_name = fn[:attributes][:getter] || fn[:attributes][:setter]
    property_name = property_name.downcase
    kind = fn[:attributes][:getter] ? :getter : :setter

    the_class = classes[in_class]
    if the_class.nil?
      classes[in_class] = empty_class_data(in_class)
      the_class = classes[in_class]
    end
    the_property = the_class[:properties][property_name]
    if the_property.nil?
      the_property = { getter: nil, setter: nil }
      the_class[:properties][property_name] = the_property
    end
    the_property[kind] = fn
  end

  functions.select{ |fn| fn[:attributes] && fn[:attributes][:constructor] }.each do |fn|
    in_class = fn[:attributes][:class]

    the_class = classes[in_class]
    if the_class.nil?
      classes[in_class] = empty_class_data(in_class)
      the_class = classes[in_class]
    end

    the_class[:constructors] << fn
  end

  functions.select{ |fn| fn[:attributes] && fn[:attributes][:destructor] }.each do |fn|
    in_class = fn[:attributes][:class]

    the_class = classes[in_class]
    if the_class.nil?
      classes[in_class] = empty_class_data(in_class)
      the_class = classes[in_class]
    end

    raise "Duplicate destructor for #{the_class[:name]}" unless the_class[:destructor].nil?
    the_class[:destructor] = fn
  end
end

#
# Post process is passed the hash containing the parsed data from parse_xml
# This is then processed to identify
#
def identify_classes(parsed)
  result = {}
  puts "Identifying classes" if RunOpts.logging
  parsed.each do |k, v|
    result = result.merge extract_classes_from_types(v[:typedefs], v[:structs])
  end

  puts "Allocating members" if RunOpts.logging
  parsed.each do |k, v|
    allocate_methods(result, v[:functions])
  end

  {
    data: parsed,
    classes: result
  }
end

# Main
parse_options
run_translate identify_classes run_parser
