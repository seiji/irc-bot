#!/usr/bin/env rake
# Add files as lib/tasks/*.rake
require 'bundler'
Bundler.require(:default)
$:.unshift 'lib'

Dir.glob('lib/tasks/**/*.rake').each { |r| load r }
