#!/usr/bin/env ruby
require          'optparse'
require          'fileutils'
require_relative 'parser'
require_relative 'generators/sklibc'

# Required to run
options = {
  generators: [],
  src: nil,
  out: nil,
  validate_only: false
}

# Options parse block
opt_parser = OptionParser.new do |opts|
  # Generators we can use
  avaliable_gens =
    Generators.constants
              .select { |c| Class === Generators.const_get(c) }
              .select { |c| c != :AbstractGenerator }
              .map { |g| [g.upcase, Generators.const_get(g)] }
              .to_h
  # Setup
  help = <<-EOS
Usage: parse.rb --from /path/to/splashkit/coresdk/src/coresdk[/file.h]
                --to GENERATOR[,GENERATOR ... ]
                [--out /path/to/write/output/to]
EOS
  opts.banner = help
  opts.separator ''
  opts.separator 'Required:'
  # Source file
  help = <<-EOS
Source header file or SplashKit CoreSDK directory
EOS
  opts.on('-i', '--input SOURCE', help) do |file|
    options[:src] = file
  end
  # To [using generator]
  help = <<-EOS
Comma separated list of generators to run on the file(s).
EOS
  opts.on('-g', '--generate GENERATOR[,GENERATOR ... ]', help) do |gens|
    parsed_gens = gens.split(',')
    options[:generators] = parsed_gens.map do |gen|
      gen_class = avaliable_gens[gen.upcase.to_sym]
      if gen_class.nil?
        raise OptionParser::InvalidOption, "#{gen} - Unknown generator #{gen}"
      end
      gen_class
    end
  end
  # Output file(s)
  help = <<-EOS
Directory to write output to
EOS
  opts.on('-o', '--out OUTPUT', help) do |out|
    options[:out] = out
  end
  # Validate only (don't generate)
  help = <<-EOS
Validate HeaderDoc only to parse without translating
EOS
  opts.on('-v', '--validate', help) do |validated|
    options[:validate_only] = true
  end
  opts.separator ''
  opts.separator 'Generators:'
  avaliable_gens.keys.each { |gen| opts.separator "    * #{gen}"}
end
# Parse block
begin
  opt_parser.parse!
  mandatory = [:src]
  # Add generators to mandatory if not validating
  mandatory << :generators unless options[:validate_only]
  missing = mandatory.select{ |param| options[param].nil? }
  raise OptionParser::MissingArgument.new "Arguments missing" unless missing.empty?
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts opt_parser
  exit 1
end
# Run block
begin
  raise 'headerdoc2html is not installed!' unless Parser.headerdoc_installed?
  parsed = Parser.parse(options[:src])
  options[:generators].each do |generator_class|
    out = generator_class.new(parsed, options[:src]).execute
    if options[:validate_only]
      puts 'Parser succeeded with no errors 🎉'
    elsif options[:out]
      out.each do |filename, contents|
        output = options[:out] + '/' + filename
        FileUtils.mkdir_p File.dirname output
        puts "Writing output to #{output}..."
        File.write output, contents
      end
    end
  end
rescue Parser::ParserError
  puts $!.to_s
  exit 1
end
