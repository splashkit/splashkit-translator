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

# Access to config vars
include Config

# Required to run
options = {
  translators: [],
  src: nil,
  out: nil,
  validate_only: false,
  write_to_cache: nil,
  read_from_cache: nil,
  verbose: nil
}

#=== Options parse block ===
opt_parser = OptionParser.new do |opts|
  # Translators we can use
  avaliable_translators =
    Translators.constants
               .select { |c| Class === Translators.const_get(c) }
               .select { |c| c != :AbstractTranslator }
               .map { |t| [t.upcase, Translators.const_get(t)] }
               .to_h
  # Setup
  help = <<-EOS
Usage: translate --input /path/to/splashkit[/#{SK_SRC_CORESDK}/file.h]
                [--generate GENERATOR[,GENERATOR ... ]
                [--output /path/to/write/output/to]
                [--validate]
EOS
  opts.banner = help
  opts.separator ''
  opts.separator 'Required:'
  # Source file
  help = <<-EOS
Source header file or SplashKit CoreSDK directory
EOS
  opts.on('-i', '--input SOURCE', help) do |input|
    options[:src] = File.expand_path input
    options[:out] = "#{input}/#{SK_TRANSLATED_OUTPUT}"
  end
  # Generate using translator
  help = <<-EOS
Comma separated list of translators to run on the file(s).
EOS
  opts.on('-g', '--generate TRANSLATOR[,TRANSLATOR ... ]', help) do |translators|
    parsed_translators = translators.split(',')
    options[:translators] = parsed_translators.map do |translator|
      translator_class = avaliable_translators[translator.upcase.to_sym]
      if translator_class.nil?
        raise OptionParser::InvalidOption, "#{translator} - Unknown translator #{translator}"
      end
      translator_class
    end
  end
  # Output file(s)
  help = <<-EOS
Directory to write output to (defaults to /path/to/splashkit/out/translated)
EOS
  opts.on('-o', '--output OUTPUT', help) do |out|
    options[:out] = File.expand_path out
  end
  # Validate only (don't generate)
  help = <<-EOS
Validate HeaderDoc only to parse without translating
EOS
  opts.on('-v', '--validate', help) do
    options[:validate_only] = true
  end
  # Parse and cache parsed contents to file
  help = <<-EOS
Write parsed contents to a cache file
EOS
  opts.on('-w', '--writecache FILE', help) do |file|
    options[:write_to_cache] = File.expand_path file
  end
  # Read parsed contents from cache
  help = <<-EOS
Read parsed contents from a cache file
EOS
  opts.on('-r', '--readcache FILE', help) do |file|
    options[:read_from_cache] = File.expand_path file
  end
  opts.separator ''
  # Show warnings at the end of parsing
  help = <<-EOS
Log HeaderDoc warnings after parsing
EOS
  opts.on('-b', '--verbose', help) do |level|
    options[:verbose] = true
  end
  opts.separator ''
  opts.separator 'Translators:'
  avaliable_translators.keys.each { |translator| opts.separator "    * #{translator}" }
end
# Parse block
begin
  opt_parser.parse!
  mandatory = options[:read_from_cache] ? [] : [:src]
  # Add translators to mandatory if not validating
  mandatory << :translators unless options[:validate_only]
  missing = mandatory.select { |param| options[param].nil? }
  # Check if read cache files exist
  if options[:read_from_cache]
    unless File.exist?(options[:read_from_cache])
      raise OptionParser::InvalidOption,
            "No such cache file #{options[:read_from_cache]}"
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

#=== Try parse ===
begin
  # Read cache contents if exists
  parsed =
    if options[:read_from_cache]
      JSON.parse(File.read(options[:read_from_cache]), symbolize_names: true)
    else
      parser = Parser.new options[:src]
      parsed = parser.parse
      if options[:verbose]
        parser.warnings.each do |msg|
          print '[WARN]'.yellow
          puts " #{msg}"
        end
      end
      unless parser.errors.empty?
        parser.errors.each do |msg|
          print '[ERR]'.red
          puts " #{msg}"
        end
        puts 'Errors detected during parsing. Exiting.'
        exit 1
      end
      parsed
    end
  if options[:write_to_cache]
    out = options[:write_to_cache]
    data = parsed.merge(__cache_src: options[:src])
    FileUtils.mkdir_p File.dirname out
    File.write out, JSON.pretty_generate(data)
  elsif options[:read_from_cache]
    options[:src] = parsed.delete(:__cache_src)
    raise '__cache_src missing from cache. Aborting.' if options[:src].nil?
  end
rescue Parser::Error
  puts $!.to_s
  exit 1
end

#=== Translate or validate ===
if options[:validate_only]
  puts 'SplashKit API documentation valid!'
else
  options[:translators].each do |translator_class|
    translator = translator_class.new(parsed, options[:src])
    out = translator.execute
    next unless options[:out]
    out.each do |filename, contents|
      output = "#{options[:out]}/#{translator.name}/#{filename}"
      FileUtils.mkdir_p File.dirname output
      puts "Writing output to #{output}..."
      File.write output, contents
    end
    puts 'Output written!'
    puts translator.post_execute
  end
end
