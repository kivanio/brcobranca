# -*- encoding: utf-8 -*-
#

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
      digito_conta_corrente: '2',
      nosso_numero: '0000053'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('004')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.carteira).to eql('21')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('004')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(25.0)
    expect(boleto_novo.valor_documento).to eq(25.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.agencia).to eql('0016')
    expect(boleto_novo.nosso_numero).to eql('0000053')
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
    @valid_attributes[:nosso_numero] = '0002720'
    @valid_attributes[:data_vencimento] = Date.parse('2012/09/08')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0016000119320002720021000')
    expect(boleto_novo.codigo_barras).to eql('00497545000000054000016000119320002720021000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00490.01605 00119.320000 27200.210006 7 54500000005400')

    @valid_attributes[:agencia] = '0259'
    @valid_attributes[:conta_corrente] = '0008549'
    @valid_attributes[:digito_conta_corrente] = '3'
    @valid_attributes[:valor] = 1.01
    @valid_attributes[:nosso_numero] = '0000001'
    @valid_attributes[:data_vencimento] = Date.parse('2017/01/17')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0259000854930000001921000')
    expect(boleto_novo.codigo_barras).to eql('00492704200000001010259000854930000001921000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00490.25901 00854.930005 00019.210004 2 70420000000101')

    @valid_attributes[:agencia] = '0275'
    @valid_attributes[:conta_corrente] = '0000253'
    @valid_attributes[:digito_conta_corrente] = '5'
    @valid_attributes[:valor] = 2807.75
    @valid_attributes[:nosso_numero] = '0000005'
    @valid_attributes[:data_vencimento] = Date.parse('2016/07/28')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0275000025350000005121000')
    expect(boleto_novo.codigo_barras).to eql('00491686900002807750275000025350000005121000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00490.27501 00025.350000 00051.210003 1 68690000280775')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(6)
  end

  it 'Montar nosso_numero_dv' do
    @valid_attributes[:nosso_numero] = '9061138'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to be(1)

    @valid_attributes[:nosso_numero] = '0000010'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to be(8)

    @valid_attributes[:nosso_numero] = '0020572'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to be(9)

    @valid_attributes[:nosso_numero] = '1961005'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to be(0)

    @valid_attributes[:nosso_numero] = '0000053'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to be(1)
  end

  it 'Montar nosso_numero_boleto' do
    @valid_attributes[:nosso_numero] = '0000010'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('0000010-8')

    @valid_attributes[:nosso_numero] = '0020572'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('0020572-9')

    @valid_attributes[:nosso_numero] = '1297105'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('1297105-7')

    @valid_attributes[:nosso_numero] = '0000005'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('0000005-1')

    @valid_attributes[:nosso_numero] = '0020572'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('0020572-9')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.agencia_conta_boleto).to eql('0016/0001193-2')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  describe 'Formato do boleto' do
    it_behaves_like 'formatos_validos'
  end
end
