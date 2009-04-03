$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

%w(core_ext currency config).each {|req| require File.join(File.dirname(__FILE__),"brcobranca",req) }

%w(base banco_brasil banco_itau).each {|req| require File.join(File.dirname(__FILE__),"brcobranca","boleto",req) }

%w(util rghost).each {|req| require File.join(File.dirname(__FILE__),"brcobranca","boleto","template",req) }

%w(retorno_cbr643).each {|req| require File.join(File.dirname(__FILE__),"brcobranca","retorno",req) }

case Brcobranca::Config::OPCOES[:gerador]
when 'rghost'

  module Brcobranca::Boleto
    Base.class_eval do
      include Brcobranca::Boleto::Template::Rghost
      include Brcobranca::Boleto::Template::Util
    end
  end

# when 'prawn'
#   # require 'prawn'
end

module Brcobranca
  VERSION = '3.0.0'
end