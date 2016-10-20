#!/usr/bin/env ruby
require          'optparse'
require          'fileutils'
require          'json'
require          'colorize'
require_relative 'parser'
require_relative 'config'
require_relative 'translators/clib'
require_relative 'translators/pascal'
require_relative 'translators/cpp'
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
    avaliable_translators =
      Translators.constants
                 .select { |c| Class === Translators.const_get(c) }
                 .select { |c| ![:AbstractTranslator, :ReusableCAdapter].include? c }
                 .map { |t| [t.upcase, Translators.const_get(t)] }
                 .to_h
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
      RunOpts.out = "#{input}/#{SK_TRANSLATED_OUTPUT}"
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
    # Parse and cache parsed contents to file
    help = 'Write parsed contents to a cache file'
    opts.on('-w', '--writecache FILE', help) do |file|
      RunOpts.write_to_cache = File.expand_path file
    end
    # Read parsed contents from cache
    help = 'Read parsed contents from a cache file'
    opts.on('-r', '--readcache FILE', help) do |file|
      RunOpts.read_from_cache = File.expand_path file
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
    if RunOpts.read_from_cache
      parsed_from_cache =
        JSON.parse(File.read(RunOpts.read_from_cache), symbolize_names: true)
      # Source also provided?
      if src
        last_modified_hash = src.map do |path|
          [path[path.index(SK_SRC_CORESDK)..-1], File.mtime(path).to_i]
        end.to_h
        cache_data = parsed_from_cache.reject { |k| k == SK_CACHE_SOURCE_KEY }
                                      .values
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
          parsed_from_cache.merge! run_parse_on_src(to_parse).map { |k,v| [k.to_sym, v] }.to_h
        end
        # Delete all those in parsed_from_cache that no longer exist in src
        no_longer_exists =
          cache_data.map { |p| p[:path] } -
          src.map { |s| s[s.index(SK_SRC_CORESDK)..-1] }
        parsed_from_cache.reject! do |k, p|
          no_longer_exists.include? p[:path] if k != SK_CACHE_SOURCE_KEY
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
    data[SK_CACHE_SOURCE_KEY] = RunOpts.src
    FileUtils.mkdir_p File.dirname out
    File.write out, JSON.pretty_generate(data)
  end
  # Read cache file means to delete the cache key
  if RunOpts.read_from_cache
    RunOpts.src = parsed.delete(SK_CACHE_SOURCE_KEY)
    if RunOpts.src.nil?
      raise "#{SK_CACHE_SOURCE_KEY} missing from cache. Aborting."
    end
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
      translator = translator_class.new(parsed, RunOpts.src, RunOpts.logging)
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

# Main
parse_options
run_translate run_parser
