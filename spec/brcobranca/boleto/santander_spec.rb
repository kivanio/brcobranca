# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Santander do
  before do
    @valid_attributes = {
      valor: 25.0,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '0059',
      convenio: 1_899_775,
      numero_documento: '90000267',
      conta_corrente: '013000123'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('033')
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
    expect(boleto_novo.carteira).to eql('102')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('033')
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
    expect(boleto_novo.agencia).to eql('0059')
    expect(boleto_novo.convenio).to eql('1899775')
    expect(boleto_novo.numero_documento).to eql('000090000267')
    expect(boleto_novo.carteira).to eql('102')
  end

  it 'Gerar boleto' do
    @valid_attributes[:data_vencimento] = Date.parse('2011/10/09')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('9189977500009000026700102')
    expect(boleto_novo.codigo_barras).to eql('03398511500000025009189977500009000026700102')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('03399.18997 77500.009004 00267.001022 8 51150000002500')

    @valid_attributes[:valor] = 54.00
    @valid_attributes[:numero_documento] = '90002720'
    @valid_attributes[:data_vencimento] = Date.parse('2012/09/08')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('9189977500009000272070102')
    expect(boleto_novo.codigo_barras).to eql('03399545000000054009189977500009000272070102')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('03399.18997 77500.009004 02720.701024 9 54500000005400')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eql(3)
  end

  it 'Montar nosso_numero_dv' do
    @valid_attributes[:numero_documento] = '566612457800'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(2)

    @valid_attributes[:numero_documento] = '90002720'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(7)

    @valid_attributes[:numero_documento] = '1961005'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(0)
  end

  it 'Montar nosso_numero_boleto' do
    @valid_attributes[:numero_documento] = '566612457800'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('566612457800-2')

    @valid_attributes[:numero_documento] = '90002720'
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('000090002720-7')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = described_class.new(@valid_attributes)

    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.send("to_#{format}".to_sym)
      tmp_file = Tempfile.new('foobar.' << format)
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end

  it 'Gerar boleto nos formatos válidos' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = described_class.new(@valid_attributes)

    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.to(format)
      tmp_file = Tempfile.new('foobar.' << format)
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end
end
