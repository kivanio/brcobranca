# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Boleto::BancoNordeste do #:nodoc:[all]
  before do
    @valid_attributes = {
      valor: 25.0,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '0016',
      conta_corrente: '0001193',
      convenio: '0001193',
      numero_documento: '0000053'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('004')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.carteira).to eql('21')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('004')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(25.0)
    expect(boleto_novo.valor_documento).to eql(25.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.agencia).to eql('0016')
    expect(boleto_novo.convenio).to eql('0001193')
    expect(boleto_novo.numero_documento).to eql('0000053')
    expect(boleto_novo.carteira).to eql('21')
  end

  it 'Gerar boleto' do
    @valid_attributes[:valor] = 1000.00
    @valid_attributes[:data_vencimento] = Date.parse('2009/10/21')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0016000119320000053121000')
    expect(boleto_novo.codigo_barras).to eql('00491439700001000000016000119320000053121000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00490.01605 00119.320000 00531.210003 1 43970000100000')

    @valid_attributes[:valor] = 54.00
    @valid_attributes[:numero_documento] = '0002720'
    @valid_attributes[:data_vencimento] = Date.parse('2012/09/08')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0016000119320002720021000')
    expect(boleto_novo.codigo_barras).to eql('00497545000000054000016000119320002720021000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00490.01605 00119.320000 27200.210006 7 54500000005400')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eql(3)
  end

  it 'Montar nosso_numero_dv' do
    @valid_attributes[:numero_documento] = '0000010'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(8)

    @valid_attributes[:numero_documento] = '0020572'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(9)

    @valid_attributes[:numero_documento] = '1961005'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(0)

    @valid_attributes[:numero_documento] = '0000053'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(1)

  end

  it 'Montar nosso_numero_boleto' do
    @valid_attributes[:numero_documento] = '0000010'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('0000010-8   21')

    @valid_attributes[:numero_documento] = '0020572'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('0020572-9   21')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  describe 'Formato do boleto' do
    it_behaves_like 'formatos_validos'
  end
end
