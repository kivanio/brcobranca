# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Citibank do #:nodoc:[all]
  before do
    @valid_attributes = {
      valor: 10.00,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '1825',
      conta_corrente: '0000528',
      convenio: '0123456789',
      nosso_numero: '00000000001',
      portfolio: '650'
    }
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('745')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(10.00)
    expect(boleto_novo.valor_documento).to eq(10.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('0000528')
    expect(boleto_novo.agencia).to eql('1825')
    expect(boleto_novo.convenio).to eql('0123456789')
    expect(boleto_novo.nosso_numero).to eql('00000000001')
    expect(boleto_novo.carteira).to eql('3')
  end

  it 'Gerar o código de barras' do
    boleto_novo = described_class.new @valid_attributes
    expect { boleto_novo.codigo_barras }.not_to raise_error
    expect(boleto_novo.codigo_barras_segunda_parte).not_to be_blank
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('3650123456789000000000019')
  end

  it 'Não permitir gerar boleto com atributos inválidos' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
  end

  it 'Tamanho do número de convênio deve ser de 10 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(convenio: '12345678901')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do convênio deve ser preenchido com zeros à esquerda quando menor que 6 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(convenio: '12345')
    expect(boleto_novo.convenio).to eq('0000012345')
    expect(boleto_novo).to be_valid
  end

  it 'Tamanho do portfolio deve ser de 3 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(portfolio: '1454')
    expect(boleto_novo).not_to be_valid
  end

  it 'Portfolio deve ser preenchido com zeros à esquerda quando menor que 3 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(portfolio: '1')
    expect(boleto_novo.portfolio).to eq('001')
    expect(boleto_novo).to be_valid
  end

  it 'Tamanho do número documento deve ser de 11 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1234567891234567')
    expect(boleto_novo).not_to be_valid
  end

  it 'Número do documento deve ser preenchido com zeros à esquerda quando menor que 1 dígitos' do
    boleto_novo = described_class.new @valid_attributes.merge(nosso_numero: '1')
    expect(boleto_novo.nosso_numero).to eq('00000000001')
    expect(boleto_novo).to be_valid
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new @valid_attributes
    expect(boleto_novo.nosso_numero_boleto).to eq('00000000001.9')

    boleto_novo.nosso_numero = '66660000003'
    expect(boleto_novo.nosso_numero_boleto).to eq('66660000003.7')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('1825 / 0123456789')

    boleto_novo.convenio = '123456'
    expect(boleto_novo.agencia_conta_boleto).to eql('1825 / 0000123456')

    boleto_novo.agencia = '2030'
    boleto_novo.convenio = '654321'
    expect(boleto_novo.agencia_conta_boleto).to eql('2030 / 0000654321')
  end

  it 'Montar código de barras' do
    @valid_attributes[:valor] = 9.99
    @valid_attributes[:data_documento] = Date.parse('2012-09-10')
    @valid_attributes[:data_vencimento] = Date.parse('2012-09-10')
    @valid_attributes[:agencia] = '0093'
    @valid_attributes[:conta_corrente] = '21057486'
    @valid_attributes[:convenio] = '0305080446'
    @valid_attributes[:nosso_numero] = '00000000002'
    @valid_attributes[:portfolio] = '621'

    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('3621305080446000000000027')
    expect(boleto_novo.codigo_barras).to eql('74595545200000009993621305080446000000000027')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74593.62138 05080.446007 00000.000273 5 54520000000999')

    @valid_attributes[:valor] = 2.0
    @valid_attributes[:data_documento] = Date.parse('2013-09-27')
    @valid_attributes[:data_vencimento] = Date.parse('2013-09-27')
    @valid_attributes[:agencia] = '0121'
    @valid_attributes[:conta_corrente] = '22202129'
    @valid_attributes[:convenio] = '0264424020'
    @valid_attributes[:nosso_numero] = '00000000159'
    @valid_attributes[:portfolio] = '611'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('3611264424020000000001597')
    expect(boleto_novo.codigo_barras).to eql('74591583400000002003611264424020000000001597')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74593.61122 64424.020002 00000.015974 1 58340000000200')

    @valid_attributes[:valor] = 774.30
    @valid_attributes[:data_documento] = Date.parse('2013-11-20')
    @valid_attributes[:data_vencimento] = Date.parse('2013-11-20')
    @valid_attributes[:agencia] = '0121'
    @valid_attributes[:conta_corrente] = '22202129'
    @valid_attributes[:convenio] = '0264424020'
    @valid_attributes[:nosso_numero] = '00000000200'
    @valid_attributes[:portfolio] = '611'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('3611264424020000000002003')
    expect(boleto_novo.codigo_barras).to eql('74597588800000774303611264424020000000002003')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74593.61122 64424.020002 00000.020032 7 58880000077430')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    @valid_attributes[:nosso_numero] = '00077700168'
    boleto_novo = described_class.new(@valid_attributes)
    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.send("to_#{format}".to_sym)
      tmp_file = Tempfile.new(['foobar.', format])
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end

  it 'Gerar boleto nos formatos válidos' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    @valid_attributes[:nosso_numero] = '00077700168'
    boleto_novo = described_class.new(@valid_attributes)
    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.to(format)
      tmp_file = Tempfile.new(['foobar.', format])
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end
end
