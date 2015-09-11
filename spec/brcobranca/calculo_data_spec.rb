# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::CalculoData do
  it 'Calcula o fator de vencimento' do
    expect((Date.parse '2008-02-01').fator_vencimento).to eq('3769')
    expect((Date.parse '2008-02-02').fator_vencimento).to eq('3770')
    expect((Date.parse '2008-02-06').fator_vencimento).to eq('3774')
  end

  it 'Formata a data no padrão visual brasileiro' do
    expect((Date.parse '2008-02-01').to_s_br).to eq('01/02/2008')
    expect((Date.parse '2008-02-02').to_s_br).to eq('02/02/2008')
    expect((Date.parse '2008-02-06').to_s_br).to eq('06/02/2008')
  end

  it 'Calcula data juliana' do
    expect((Date.parse '2009-02-11').to_juliano).to eql('0429')
    expect((Date.parse '2008-02-11').to_juliano).to eql('0428')
    expect((Date.parse '2009-04-08').to_juliano).to eql('0989')
    # Ano 2008 eh bisexto
    expect((Date.parse '2008-04-08').to_juliano).to eql('0998')
  end
end