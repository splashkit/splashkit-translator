#!/usr/bin/env ruby
require 'nokogiri'

#
# Check if headerdoc is installed
#
def headerdoc_installed?
  system %(which headerdoc2html > /dev/null)
end

#
# Monkey patches to Array
#
class Array
  alias _to_h to_h
  #
  # Returns nil if the array is empty
  #
  def to_h
    empty? ? nil : _to_h
  end
end

#
# Monkey patches to String
#
class String
  #
  # Squashes the string down to its most relevant type, trimming where possible
  #
  def squash
    s = strip
    s.to_i || s.to_f || s.to_b || (s.empty? ? nil : s)
  end

  #
  # Converts to a boolean type if applicable, or nil
  #
  def to_b
    return true if self =~ /^(true|t|yes|y|1)$/i
    return false if empty? || self =~ /^(false|f|no|n|0)$/i
    nil
  end

  #
  # Monkey patch to_f to return nil if self doesn't represent a float
  #
  def to_f
    Float(self)
  rescue ArgumentError
    nil
  end

  #
  # Monkey patch to_i to return nil if self doesn't represent an integer
  #
  def to_i
    Integer(self)
  rescue ArgumentError
    nil
  end
end

module Nokogiri
  #
  # Monkey patches to Nokogiri::XML
  #
  module XML
    #
    # Text representations should always be squashed
    #
    class Text
      alias _text text
      def text
        _text.squash
      end
    end
    #
    # Empty NodeSets should return nil
    #
    class NodeSet
      alias _text text
      def text
        empty? ? nil : _text.squash
      end
    end
  end
end

#
# Parses the docblock at the start of a .h file
#
def parse_header(xml)
  {
    name:  xml.xpath('//header/name').text,
    brief:        xml.xpath('//header/abstract').text,
    description:  xml.xpath('//header/desc').text
  }
end

#
# Parses a single `@attribute` in a docblock
#
def parse_attributes(xml)
  [xml.xpath('name').text.to_sym, xml.xpath('value').text]
end

#
# Parses a single `@param` in a docblock
#
def parse_parameters(xml, hdoc_parsed_params)
  name = xml.xpath('name').text
  # Need to find the matching type, this comes from
  # the hdoc_parsed_params elements
  type = hdoc_parsed_params[name]
  raise "Mismatched headerdoc @param '#{name}'. Check it exists in the signature: #{fn.xpath('declaration').text}" if type.nil?
  [
    name.to_sym,
    {
      type:        type,
      description: xml.xpath('desc').text
    }
  ]
end

#
# Parses the docblock of a function
#
def parse_function(xml)
  # Values from the <parsedparamater> elements
  hdoc_pp = xml.xpath('.//parsedparameter').map do |p|
    [p.xpath('name').text, p.xpath('type').text]
  end.to_h
  {
    name:        xml.xpath('name').text,
    description: xml.xpath('desc').text,
    brief:       xml.xpath('abstract').text,
    return_type: xml.xpath('returntype').text,
    returns:     xml.xpath('result').text,
    parameters:  xml.xpath('.//parameter').map { |p| parse_parameters(p, hdoc_pp) },
    attributes:  xml.xpath('.//attribute').map { |a| parse_attributes(a) }
  }
end

#
# Parses the XML into a hash
#
def parse(xml)
  # TODO: Finish this off for types etc...
  parsed = parse_header(xml)
  parsed[:functions] = xml.xpath('//header/functions/function').map { |fn| parse_function(fn) }
  parsed[:typedefs]  = nil
  parsed
end

#
# Runs headerdoc for the provided src directory
#
def xmlify(src)
  hcfg_file = File.expand_path File.dirname __FILE__ + '/res/headerdoc.config'
  parsed = Dir[src + '/*.h'].map do |hfile|
    puts "XMLifying #{hfile}..."
    cmd = %(headerdoc2html -XPOLltjbq -c #{hcfg_file} #{hfile})
    proc = IO.popen cmd
    out = proc.readlines
    hfile_xml = out.empty? ? nil : out.join
    raise "headerdoc2html failed. Command was #{cmd}." unless $?.exitstatus.zero?
    [File.basename(hfile), parse(Nokogiri.XML(hfile_xml))]
  end
  parsed.to_h
end

sk_src = ARGF.argv.first
raise 'Please provide the /path/to/splashkit/coresdk/src/coresdk' unless sk_src
raise 'headerdoc2html is not installed!' unless headerdoc_installed?

parsed = xmlify(sk_src)
parsed.each do |hfile_name, hfile|
  puts "==== #{hfile_name} ===="
  puts "~ #{hfile[:brief]} ~\n\n#{hfile[:description]}\n\n"
  puts 'Functions:'
  hfile[:functions].each_with_index do |fn, index|
    puts "#{index+1}.\tName:\t#{fn[:name]}"
    puts "\tBrief:\t#{fn[:brief]}"
    puts "\tDesc:\n\t\t#{fn[:description].gsub("\n", "\n\t\t")}"
    puts "\tParameters:\t#{fn[:parameters].empty? ? 'None' : ''}"
    fn[:parameters].each do |k, v|
      puts "\t\t* #{k}: #{v[:type]}"
      puts "\t\t\t#{v[:description].gsub("\n", "\n\t\t\t")}"
    end
    puts "\tReturns:\t#{fn[:return_type]}"
    puts "\t        \t#{fn[:returns]}" unless fn[:return_type] == 'void'
    puts "\tAttributes:"
    fn[:attributes].each do |k, v|
      puts "\t\t* #{k}: #{v}"
    end
    puts "---"
  end
  #puts 'Types:', hfile.typedefs
end
