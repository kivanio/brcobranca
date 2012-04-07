# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'tempfile'
require 'bundler/setup'
require 'brcobranca'
require 'rghost'

RGhost::Config::GS[:path] = '/usr/local/bin/gs'

RSpec.configure do |config|
	
end