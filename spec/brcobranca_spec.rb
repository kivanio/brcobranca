# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Brcobranca" do
  it "Validar opções padrão" do
    expect(Brcobranca.configuration.gerador).to eql(:rghost)
    expect(Brcobranca.configuration.formato).to eql(:pdf)
  end

  it "Mudar configurações" do
    Brcobranca.setup do |config|
      config.gerador = :prawn
      config.formato = :gif
    end
    expect(Brcobranca.configuration.gerador).to eql(:prawn)
    expect(Brcobranca.configuration.formato).to eql(:gif)
  end
end