# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Brcobranca" do
  it "Validar opções padrão" do
    Brcobranca.configuration.gerador.should eql(:rghost)
    Brcobranca.configuration.formato.should eql(:pdf)
  end

  it "Mudar configurações" do
    Brcobranca.setup do |config|
      config.gerador = :prawn
      config.formato = :gif
    end
    Brcobranca.configuration.gerador.should eql(:prawn)
    Brcobranca.configuration.formato.should eql(:gif)
  end
end