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
      convenio: '0000528',
      numero_documento: '000001'
    }
  end

  it 'Criar nova instância com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('070')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
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

  it 'Gerar o dígito verificador do convênio' do
    boleto_novo = described_class.new @valid_attributes
    expect(boleto_novo.convenio_dv).not_to be_nil
    expect(boleto_novo.convenio_dv).to eq('2')
  end

  it 'Gerar o código de barras' do
    @valid_attributes[:data_documento] = Date.parse('2015-04-30')
    @valid_attributes[:data_vencimento] = Date.parse('2015-04-30')

    boleto_novo = described_class.new @valid_attributes

    expect { boleto_novo.codigo_barras }.not_to raise_error
    expect(boleto_novo.codigo_barras_segunda_parte).not_to be_blank
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000820000528200000107013')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('07090.00087 20000.528206 00001.070135 9 64140000001000')
  end

  it 'Não permitir gerar boleto com atributos inválidos' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
  end

 it 'Tamanho do número de convênio deve ser de 7 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(convenio: '12345678')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do convênio deve ser preenchido com zeros à esquerda quando menor que 7 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(convenio: '12345')
    expect(boleto_novo.convenio).to eq('0012345')
    expect(boleto_novo).to be_valid
  end

  it 'Tamanho da carteira deve ser de 1 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(carteira: '145')
    expect(boleto_novo).not_to be_valid

    boleto_novo = described_class.new @valid_attributes.merge(carteira: '24')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número documento deve ser de 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(numero_documento: '1234567')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do documento deve ser preenchido com zeros à esquerda quando menor que 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(numero_documento: '1')
    expect(boleto_novo.numero_documento).to eq('000001')
    expect(boleto_novo).to be_valid
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new @valid_attributes
    expect(boleto_novo.nosso_numero_boleto).to eq('200000000001-0')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('082/0000528-2')

    boleto_novo.convenio = '123456'
    expect(boleto_novo.agencia_conta_boleto).to eql('082/0123456-0')

    boleto_novo.agencia = '030'
    boleto_novo.convenio = '654321'
    expect(boleto_novo.agencia_conta_boleto).to eql('030/0654321-9')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  describe 'Formato do boleto' do
    before do
      @valid_attributes[:numero_documento] = '000168'
    end

    it_behaves_like 'formatos_validos'
  end
end
