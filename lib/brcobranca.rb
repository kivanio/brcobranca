require 'rghost'
require 'rghost_barcode'

$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

%w(core_ext currency config).each {|req| require File.dirname(__FILE__) +File::SEPARATOR+"brcobranca"+File::SEPARATOR+"#{req}"}

%w(base bancobrasil itau).each {|req| require File.dirname(__FILE__) + File::SEPARATOR + "brcobranca"+File::SEPARATOR+"boleto"+File::SEPARATOR+"#{req}"}

%w(retorno_cbr643).each {|req| require File.dirname(__FILE__) + File::SEPARATOR + "brcobranca"+File::SEPARATOR+"retorno"+File::SEPARATOR+"#{req}"}

module Brcobranca
  VERSION = '2.0.4'
end