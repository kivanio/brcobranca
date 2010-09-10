# -*- encoding: utf-8 -*-
lib = File.expand_path(File.dirname(__FILE__) + '/../lib')
$:.unshift(lib) unless $:.include?('lib') || $:.include?(lib)
require 'brcobranca'
require 'spec'
require 'tempfile'