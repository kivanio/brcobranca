# -*- encoding: utf-8 -*-
#
require 'spec_helper'

RSpec.describe Brcobranca::Formatacao do
  it 'Formata o CPF' do
    expect(98_789_298_790.to_br_cpf).to eql('987.892.987-90')
    expect('98789298790'.to_br_cpf).to eql('987.892.987-90')
    expect('987.892.987-90'.to_br_cpf).to eql('987.892.987-90')
  end

  it 'Formata o CEP' do
    expect(85_253_100.to_br_cep).to eql('85253-100')
    expect('85253100'.to_br_cep).to eql('85253-100')
    expect('85253-100'.to_br_cep).to eql('85253-100')
  end

  it 'Formata o CNPJ' do
    expect(88_394_510_000_103.to_br_cnpj).to eql('88.394.510/0001-03')
    expect('88394510000103'.to_br_cnpj).to eql('88.394.510/0001-03')
    expect('88.394.510/0001-03'.to_br_cnpj).to eql('88.394.510/0001-03')
  end

  it 'Formata números automáticamente de acordo com o número de caracteres' do
    expect(98_789_298_790.formata_documento).to eql('987.892.987-90')
    expect('98789298790'.formata_documento).to eql('987.892.987-90')
    expect('987.892.987-90'.formata_documento).to eql('987.892.987-90')
    expect(85_253_100.formata_documento).to eql('85253-100')
    expect('85253100'.formata_documento).to eql('85253-100')
    expect('85253-100'.formata_documento).to eql('85253-100')
    expect(88_394_510_000_103.formata_documento).to eql('88.394.510/0001-03')
    expect('88394510000103'.formata_documento).to eql('88.394.510/0001-03')
    expect('88.394.510/0001-03'.formata_documento).to eql('88.394.510/0001-03')
    expect('8839'.formata_documento).to eql('8839')
    expect('8839451000010388394510000103'.formata_documento).to eql('8839451000010388394510000103')
  end

  it 'Monta linha digitável' do
    expect('00192376900000135000000001238798777770016818'.linha_digitavel).to eql('00190.00009 01238.798779 77700.168188 2 37690000013500')
    expect('00192376900000135000000001238798777770016818'.linha_digitavel).to be_a_kind_of(String)
    expect { ''.linha_digitavel }.to raise_error(ArgumentError)
    expect { '00193373700'.linha_digitavel }.to raise_error(ArgumentError)
    expect { '0019337370000193373700'.linha_digitavel }.to raise_error(ArgumentError)
    expect { '00b193373700bb00193373700'.linha_digitavel }.to raise_error(ArgumentError)
  end
end
