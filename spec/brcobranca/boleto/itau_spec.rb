# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Itau do
  before do
    @valid_attributes = {
      valor: 0.0,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '0810',
      conta_corrente: '53678',
      convenio: 12_387,
      nosso_numero: '12345678'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('341')
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
    expect(boleto_novo.carteira).to eql('175')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('341')
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
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('53678')
    expect(boleto_novo.agencia).to eql('0810')
    expect(boleto_novo.convenio).to eql('12387')
    expect(boleto_novo.nosso_numero).to eql('12345678')
    expect(boleto_novo.carteira).to eql('175')
  end

  it '#usa_seu_numero?' do
    @valid_attributes[:carteira] = 198
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.usa_seu_numero?).to be_truthy

    @valid_attributes[:carteira] = 109
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.usa_seu_numero?).to be_falsey
  end

  it 'Gerar boleto' do
    @valid_attributes[:data_vencimento] = Date.parse('2009/08/14')
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1751234567840810536789000')
    expect(boleto_novo.codigo_barras).to eql('34191432900000000001751234567840810536789000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('34191.75124 34567.840813 05367.890000 1 43290000000000')

    @valid_attributes[:valor] = 135.00
    @valid_attributes[:nosso_numero] = '258281'
    @valid_attributes[:data_vencimento] = Date.parse('2008/02/02')
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1750025828170810536789000')
    expect(boleto_novo.codigo_barras).to eql('34191377000000135001750025828170810536789000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('34191.75009 25828.170818 05367.890000 1 37700000013500')

    @valid_attributes[:nosso_numero] = '258281'
    @valid_attributes[:data_vencimento] = Date.parse('2004/09/05')
    @valid_attributes[:carteira] = 168
    @valid_attributes[:valor] = 135.00
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1680025828120810536789000')
    expect(boleto_novo.codigo_barras).to eql('34194252500000135001680025828120810536789000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('34191.68004 25828.120813 05367.890000 4 25250000013500')

    @valid_attributes[:nosso_numero] = '258281'
    @valid_attributes[:data_vencimento] = Date.parse('2004/09/05')
    @valid_attributes[:carteira] = 196
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:convenio] = '12345'
    @valid_attributes[:seu_numero] = '1234567'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1960025828112345671234550')
    expect(boleto_novo.codigo_barras).to eql('34191252500000135001960025828112345671234550')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('34191.96005 25828.112349 56712.345505 1 25250000013500')

    @valid_attributes[:nosso_numero] = '258281'
    @valid_attributes[:data_vencimento] = Date.parse('2004/09/05')
    @valid_attributes[:carteira] = 196
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:convenio] = '12345'
    @valid_attributes[:seu_numero] = '123456'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1960025828101234561234550')
    expect(boleto_novo.codigo_barras).to eql('34192252500000135001960025828101234561234550')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('34191.96005 25828.101235 45612.345509 2 25250000013500')

    @valid_attributes[:nosso_numero] = '258281'
    @valid_attributes[:data_vencimento] = Date.parse('2004/09/05')
    @valid_attributes[:carteira] = 196
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:convenio] = '1234'
    @valid_attributes[:seu_numero] = '123456'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.send(:codigo_barras_primeira_parte)).to eql('341925250000013500')
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1960025828101234560123440')
    expect(boleto_novo.codigo_barras).to eql('34192252500000135001960025828101234560123440')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('34191.96005 25828.101235 45601.234409 2 25250000013500')

    @valid_attributes[:nosso_numero] = '00010152'
    @valid_attributes[:data_vencimento] = Date.parse('2029/05/20')
    @valid_attributes[:carteira] = 109
    @valid_attributes[:valor] = 6757.87
    @valid_attributes[:seu_numero] = '00010152'
    @valid_attributes[:agencia] = '1248'
    @valid_attributes[:conta_corrente] = '02124'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.send(:codigo_barras_primeira_parte)).to eql('341925480000675787')
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1090001015271248021246000')
    expect(boleto_novo.codigo_barras).to eql('34194254800006757871090001015271248021246000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('34191.09008 01015.271248 80212.460002 4 25480000675787')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(5)
  end

  it 'Montar agencia_conta_corrente_dv' do
    @valid_attributes[:conta_corrente] = '15255'
    @valid_attributes[:agencia] = '0607'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_corrente_dv).to be(0)
    expect(boleto_novo.agencia_conta_boleto).to eql('0607 / 15255-0')

    @valid_attributes[:conta_corrente] = '85547'
    @valid_attributes[:agencia] = '1547'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_corrente_dv).to be(6)
    expect(boleto_novo.agencia_conta_boleto).to eql('1547 / 85547-6')

    @valid_attributes[:conta_corrente] = '10207'
    @valid_attributes[:agencia] = '1547'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_corrente_dv).to be(7)

    @valid_attributes[:conta_corrente] = '53678'
    @valid_attributes[:agencia] = '0811'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_corrente_dv).to be(8)
    expect(boleto_novo.agencia_conta_boleto).to eql('0811 / 53678-8')
  end

  it 'Montar nosso_numero_boleto' do
    @valid_attributes[:conta_corrente] = '15255'
    @valid_attributes[:agencia] = '0607'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_boleto).to eql('175/12345678-4')

    @valid_attributes[:conta_corrente] = '15255'
    @valid_attributes[:agencia] = '0607'
    @valid_attributes[:carteira] = '143'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_boleto).to eql('143/12345678-2')
  end

  it 'Montar nosso_numero_dv' do
    @valid_attributes[:nosso_numero] = '00015448'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_dv).to be(6)

    @valid_attributes[:nosso_numero] = '15448'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_dv).to be(6)

    @valid_attributes[:nosso_numero] = '12345678'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_dv).to be(4)

    @valid_attributes[:nosso_numero] = '34230'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_dv).to be(5)

    @valid_attributes[:nosso_numero] = '258281'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_dv).to be(7)
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
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
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
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
