# -*- encoding: utf-8 -*-
#
require 'spec_helper'

RSpec.describe Brcobranca::Limpeza do
  it 'Formata Float em String' do
    expect(1234.03.limpa_valor_moeda).to eq('123403')
    expect(1234.3.limpa_valor_moeda).to eq('123430')
  end
end
