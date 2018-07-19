# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Boleto::BancoBrasilia do #:nodoc:[all]
  before do
    @valid_attributes = {
      valor: 10.00,
      cedente: 'PREFEITURA MUNICIPAL DE VILHENA',
      documento_cedente: '04092706000181',
      sacado: 'João Paulo Barbosa',
      sacado_documento: '77777777777',
      agencia: '082',
      conta_corrente: '0000528',
      nosso_numero: '000001'
    }
  end

  it 'Criar nova instância com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('070')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.codigo_servico).to be_falsey
    expect(boleto_novo.carteira).to eql('2')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new @valid_attributes
    @valid_attributes.keys.each do |key|
      expect(boleto_novo.send(key)).to eql(@valid_attributes[key])
    end
    expect(boleto_novo).to be_valid
  end

  it 'Gerar o código de barras' do
    @valid_attributes[:data_documento] = Date.parse('2015-04-30')
    @valid_attributes[:data_vencimento] = Date.parse('2015-04-30')

    boleto_novo = described_class.new @valid_attributes

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000820000528200000107013')
    expect(boleto_novo.codigo_barras).to eql('07099641400000010000000820000528200000107013')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('07090.00087 20000.528206 00001.070135 9 64140000001000')

    @valid_attributes[:data_documento] = Date.parse('2016-07-25')
    @valid_attributes[:data_vencimento] = Date.parse('2016-07-25')
    @valid_attributes[:valor] = 372.77
    @valid_attributes[:carteira] = 1
    @valid_attributes[:agencia] = 240
    @valid_attributes[:conta_corrente] = 44990
    @valid_attributes[:nosso_numero] = 1
    @valid_attributes[:nosso_numero_incremento] = 2

    boleto_novo = described_class.new @valid_attributes
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0022400044990100000107070')
    expect(boleto_novo.codigo_barras).to eql('07099686600000372770022400044990100000107070')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('07090.02240 00044.990109 00001.070705 9 68660000037277')
  end

  it 'Não permitir gerar boleto com atributos inválidos' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
  end

  it 'Tamanho do número da agência deve ser de 3 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(agencia: "80")
    expect(boleto_novo.agencia).to eq('080')

    boleto_novo = described_class.new @valid_attributes.merge(agencia: "0080")
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número de nosso_numero_incremento deve ser de 3 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero_incremento: '12345678')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número de conta corrente deve ser de 7 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(conta_corrente: '12345678')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do conta corrente deve ser preenchido com zeros à esquerda quando menor que 7 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(conta_corrente: '12345')
    expect(boleto_novo.conta_corrente).to eq('0012345')
    expect(boleto_novo).to be_valid
  end

  it 'Tamanho da carteira deve ser de 1 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(carteira: '145')
    expect(boleto_novo).not_to be_valid

    boleto_novo = described_class.new @valid_attributes.merge(carteira: '24')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número documento deve ser de 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1234567')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do documento deve ser preenchido com zeros à esquerda quando menor que 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1')
    expect(boleto_novo.nosso_numero).to eq('000001')
    expect(boleto_novo).to be_valid
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new @valid_attributes
    expect(boleto_novo.nosso_numero_boleto).to eq('200000107013')

    @valid_attributes[:carteira] = 1
    @valid_attributes[:agencia] = '058'
    @valid_attributes[:conta_corrente] = 6002006
    @valid_attributes[:nosso_numero] = 1
    boleto_novo = described_class.new @valid_attributes
    expect(boleto_novo.nosso_numero_boleto).to eq('100000107045')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('000 - 082 - 0000528')

    boleto_novo.conta_corrente = '123456'
    expect(boleto_novo.agencia_conta_boleto).to eql('000 - 082 - 0123456')

    boleto_novo.agencia = '030'
    boleto_novo.conta_corrente = '654321'
    expect(boleto_novo.agencia_conta_boleto).to eql('000 - 030 - 0654321')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  describe 'Formato do boleto' do
    before do
      @valid_attributes[:nosso_numero] = '000168'
    end

    it_behaves_like 'formatos_validos'
  end
end
