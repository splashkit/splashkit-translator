#!/usr/bin/env ruby
require          'optparse'
require          'fileutils'
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
  validate_only: false
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
    options[:src] = input
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
    options[:out] = out
  end
  # Validate only (don't generate)
  help = <<-EOS
Validate HeaderDoc only to parse without translating
EOS
  opts.on('-v', '--validate', help) do
    options[:validate_only] = true
  end
  opts.separator ''
  opts.separator 'Translators:'
  avaliable_translators.keys.each { |translator| opts.separator "    * #{translator}" }
end
# Parse block
begin
  opt_parser.parse!
  mandatory = [:src]
  # Add translators to mandatory if not validating
  mandatory << :translators unless options[:validate_only]
  missing = mandatory.select { |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument, 'Missing #{missing.map(&:to_s)} arguments'
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  exit 1
end

#=== Try parse ===
begin
  parsed = Parser.parse(options[:src])
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
