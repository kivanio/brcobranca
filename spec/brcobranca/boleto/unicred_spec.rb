# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Unicred do
  before do
    @valid_attributes = {
      especie_documento: 'DM',
      data_processamento: Date.parse('2012-01-18'),
      valor: 0.0,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '4042',
      conta_corrente: '61900',
      conta_corrente_dv: '7',
      nosso_numero: '00168'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('136')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('N')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('PAGÁVEL PREFERENCIALMENTE NAS AGÊNCIAS DA UNICRED')
    expect(boleto_novo.carteira).to eql('21')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('136')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.parse('2012-01-18'))
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('N')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('PAGÁVEL PREFERENCIALMENTE NAS AGÊNCIAS DA UNICRED')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('000061900')
    expect(boleto_novo.agencia).to eql('4042')
    expect(boleto_novo.nosso_numero).to eql('0000000168')
    expect(boleto_novo.carteira).to eql('21')
  end

  it 'Montar código de barras para carteira número 21' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_vencimento] = Date.parse('2012-01-24')
    @valid_attributes[:data_documento] = Date.parse('2012-01-19')
    @valid_attributes[:nosso_numero] = '13871'
    @valid_attributes[:conta_corrente] = '12345'
    @valid_attributes[:agencia] = '1234'
    @valid_attributes[:carteira] = '21'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('13691.23409 00012.345708 00001.387117 1 52220000295295')
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1234000012345700000138711')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(5)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    boleto_novo.agencia = '1234'
    boleto_novo.conta_corrente = '12345'
    boleto_novo.nosso_numero = '13871'
    boleto_novo.carteira = '21'
    expect(boleto_novo.nosso_numero_boleto).to eql('0000013871-1')
    expect(boleto_novo.nosso_numero_dv).to be(1)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    boleto_novo.agencia = '1234'
    boleto_novo.conta_corrente = '12345'
    expect(boleto_novo.agencia_conta_boleto).to eql('1234 / 000012345-7')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    boleto_novo = described_class.new(@valid_attributes)

    %w[pdf jpg tif png].each do |format|
      file_body = boleto_novo.send("to_#{format}".to_sym)
      tmp_file = Tempfile.new(['foobar.', format])
      tmp_file.puts file_body
      tmp_file.close
      expect(File).to exist(tmp_file.path)
      expect(File.stat(tmp_file.path)).not_to be_zero
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File).not_to exist(tmp_file.path)
    end
  end

  it 'Gerar boleto nos formatos válidos' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse('2009-04-30')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    @valid_attributes[:nosso_numero] = '86452'
    @valid_attributes[:conta_corrente] = '03005'
    @valid_attributes[:agencia] = '1172'
    boleto_novo = described_class.new(@valid_attributes)

    %w[pdf jpg tif png].each do |format|
      file_body = boleto_novo.to(format)
      tmp_file = Tempfile.new(['foobar.', format])
      tmp_file.puts file_body
      tmp_file.close
      expect(File).to exist(tmp_file.path)
      expect(File.stat(tmp_file.path)).not_to be_zero
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File).not_to exist(tmp_file.path)
    end
  end

  describe 'Aplica senha no pdf do boleto' do
    it_behaves_like 'senha_pdf'
  end
end
