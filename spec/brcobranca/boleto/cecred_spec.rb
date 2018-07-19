# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Cecred do #:nodoc:[all]
  before do
    @valid_attributes = {
      valor: 0.0,
      local_pagamento: 'PAGÁVEL PREFERENCIALMENTE NAS COOPERATIVAS DO SISTEMA CECRED',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '0101',
      conta_corrente: '1111111',
      convenio: 000_000,
      nosso_numero: '000000001'
    }
  end

  it 'Não permitir gerar boleto com atributos inválidos' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
  end

  it 'Tamanho do número da agência deve ser de 4 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(agencia: '0101')
    expect(boleto_novo.agencia).to eq('0101')

    boleto_novo = described_class.new @valid_attributes.merge(agencia: '00001')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número de convênio deve ser de 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(convenio: '1234567')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho da carteira deve ser de 2 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(carteira: '01')
    expect(boleto_novo).to be_valid

    boleto_novo = described_class.new @valid_attributes.merge(carteira: '112')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número documento deve ser de 9 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '123456789')
    expect(boleto_novo).to be_valid

    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1234567890')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do documento deve ser preenchido com zeros à esquerda quando menor que 9 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1')
    expect(boleto_novo.nosso_numero).to eq('000000001')
    expect(boleto_novo).to be_valid
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('085')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('PAGÁVEL PREFERENCIALMENTE NAS COOPERATIVAS DO SISTEMA CECRED')
    expect(boleto_novo.carteira).to eql('01')
    expect(boleto_novo.codigo_servico).to be_falsey
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('085')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('PAGÁVEL PREFERENCIALMENTE NAS COOPERATIVAS DO SISTEMA CECRED')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('1111111')
    expect(boleto_novo.agencia).to eql('0101')
    expect(boleto_novo.convenio).to eql('000000')
    expect(boleto_novo.nosso_numero).to eql('000000001')
    expect(boleto_novo.carteira).to eql('01')
    expect(boleto_novo.codigo_servico).to be_falsey
  end

  it 'Montar código de barras' do
    @valid_attributes[:valor] = 1.00
    @valid_attributes[:data_documento] = Date.parse('2015-02-03')
    @valid_attributes[:data_vencimento] = Date.parse('2015-05-25')
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000001111111900000000101')
    expect(boleto_novo.codigo_barras).to eql('08593643900000001000000001111111900000000101')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('08590.00002 01111.111900 00000.001016 3 64390000000100')
    expect(boleto_novo.conta_corrente_dv).to eql(9)

    @valid_attributes[:convenio] = '234'
    @valid_attributes[:conta_corrente] = '356156'
    segundo_boleto = described_class.new(@valid_attributes)

    expect(segundo_boleto.codigo_barras_segunda_parte).to eql('0002340356156900000000101')
    expect(segundo_boleto.codigo_barras).to eql('08593643900000001000002340356156900000000101')
    expect(segundo_boleto.codigo_barras.linha_digitavel).to eql('08590.00234 40356.156907 00000.001016 3 64390000000100')
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(@valid_attributes)
    boleto_novo.conta_corrente = '0357157'
    boleto_novo.nosso_numero = '1'
    expect(boleto_novo.nosso_numero_boleto).to eql('03571572000000001')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('0101-5 / 1111111-9')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('0719-6 / 1111111-9')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    expect(boleto_novo.agencia_conta_boleto).to eql('0548-7 / 0001448-6')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  describe 'Formato do boleto' do
    it_behaves_like 'formatos_validos'
  end
end
