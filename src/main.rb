#!/usr/bin/env ruby
require          'require_all'
require_relative 'parser'
require_relative 'generators/sklibc'
require_relative 'generators/yaml'

sk_src = ARGF.argv.first
raise 'Please provide the /path/to/splashkit/coresdk/src/coresdk' unless sk_src
raise 'headerdoc2html is not installed!' unless Parser.headerdoc_installed?

parsed = Parser.parse(sk_src)
result = Generators::YAML.new(parsed).execute
puts result
