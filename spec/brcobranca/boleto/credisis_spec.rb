# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Credisis do #:nodoc:[all]
  before do
    @valid_attributes = {
      valor: 0.0,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '0001',
      conta_corrente: '0000002',
      convenio: 100000,
      nosso_numero: '000095'
    }
  end

  it 'Não permitir gerar boleto com atributos inválidos' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
  end

  it 'Tamanho do número da agência deve ser de 4 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(agencia: "0001")
    expect(boleto_novo.agencia).to eq('0001')

    boleto_novo = described_class.new @valid_attributes.merge(agencia: "00001")
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número de convênio deve ser de 7 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(convenio: '12345678')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho da carteira deve ser de 2 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(carteira: '145')
    expect(boleto_novo).not_to be_valid
  end

  it 'Tamanho do número documento deve ser de 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1234567')
    expect(boleto_novo).not_to be_valid
  end

  it 'documento_cedente nao pode estar em branco' do
    boleto_novo = described_class.new @valid_attributes.merge(documento_cedente: nil)
    expect(boleto_novo).not_to be_valid
  end

  it 'documento_cedente deve ter somente numeros' do
    boleto_novo = described_class.new @valid_attributes.merge(documento_cedente: '123.456.789-12')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do documento deve ser preenchido com zeros à esquerda quando menor que 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1')
    expect(boleto_novo.nosso_numero).to eq('000001')
    expect(boleto_novo).to be_valid
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('097')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.carteira).to eql('18')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('097')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('0000002')
    expect(boleto_novo.agencia).to eql('0001')
    expect(boleto_novo.convenio).to eql('100000')
    expect(boleto_novo.nosso_numero).to eql('000095')
    expect(boleto_novo.carteira).to eql('18')
  end

  it 'Montar código de barras' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000009750001100000000095')
    expect(boleto_novo.codigo_barras).to eql('09791376900000135000000009750001100000000095')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('09790.00007 09750.001100 00000.000950 1 37690000013500')
    expect(boleto_novo.conta_corrente_dv).to eql(7)

    @valid_attributes[:convenio] = "6641"
    segundo_boleto = described_class.new(@valid_attributes)

    expect(segundo_boleto.codigo_barras_segunda_parte).to eql('0000009750001006641000095')
    expect(segundo_boleto.codigo_barras).to eql('09797376900000135000000009750001006641000095')
    expect(segundo_boleto.codigo_barras.linha_digitavel).to eql('09790.00007 09750.001001 66410.000955 7 37690000013500')
  end

  it 'Calcular agencia_dv' do
    boleto_novo = described_class.new(@valid_attributes)
    boleto_novo.agencia = '4042'
    expect(boleto_novo.agencia_dv).to eql(8)
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_dv).to eql(6)
    boleto_novo.agencia = 4042
    expect(boleto_novo.agencia_dv).to eql(8)
    boleto_novo.agencia = 719
    expect(boleto_novo.agencia_dv).to eql(6)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(@valid_attributes)
    boleto_novo.nosso_numero = '95'
    expect(boleto_novo.nosso_numero_boleto).to eql('09750001100000000095')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('0001-9 / 0000002-7')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('0719-6 / 0000002-7')
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
