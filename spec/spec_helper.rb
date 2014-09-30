# -*- encoding: utf-8 -*-
require 'coveralls'
Coveralls.wear!

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'pry'
require 'tempfile'
require 'brcobranca'
require 'rghost'

RGhost::Config.config_platform
