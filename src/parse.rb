#!/usr/bin/env ruby
require 'bundler/setup'
require 'doxyparser'

def parse(src)
  puts "Parsing #{src} for Doxygen..."
  dir = File.expand_path File.dirname __FILE__
  build_dir = dir + '/build'
  doxy_file = dir + '/res/Doxyfile'
  xml_dir = build_dir + '/xml'
  Doxyparser.gen_xml_docs(src, build_dir, doxy_file)
  # Map from original name to double-underscore name
  parsed = Dir[src + '/*.h'].map { |f| File.basename(f).gsub('_', '__') }.map do |hfile|
    hfile_parsed = Doxyparser.parse_file(hfile, xml_dir)
    [hfile, hfile_parsed]
  end
  parsed.to_h
end

sk_src = ARGF.argv.first
raise 'Please provide the /path/to/splashkit/coresdk/src/coresdk' unless sk_src

parsed = parse(sk_src)
parsed.each do |hfile_name, hfile|
  puts "==== #{hfile_name} ===="
  puts 'Functions:'
  hfile.functions.each_with_index do |fn, index|
    puts "#{index} Name:    #{fn.basename}"
  end
  puts 'Types:', hfile.typedefs
end
