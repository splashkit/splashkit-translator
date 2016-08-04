#!/usr/bin/env ruby
require_relative 'parser'

sk_src = ARGF.argv.first
raise 'Please provide the /path/to/splashkit/coresdk/src/coresdk' unless sk_src
raise 'headerdoc2html is not installed!' unless Parser.headerdoc_installed?

parsed = Parser.parse(sk_src)
puts parsed
parsed.each do |hfile_name, hfile|
  puts "==== #{hfile_name} ===="
  puts "~ #{hfile[:brief]} ~\n\n#{hfile[:description]}\n\n"
  puts 'Functions:'
  hfile[:functions].each_with_index do |fn, index|
    puts "#{index+1}.\tName:\t#{fn[:name]}"
    puts "\tBrief:\t#{fn[:brief]}"
    puts "\tDesc:\n\t\t#{fn[:description].gsub("\n", "\n\t\t")}"
    puts "\tParameters:\t#{fn[:parameters].nil? ? 'None' : ''}"
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
  puts 'Types:', hfile[:typedefs]
end
