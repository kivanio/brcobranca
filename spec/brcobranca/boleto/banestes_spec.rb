# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Banestes do #:nodoc:[all]
  let(:valid_attributes) do
    {
      data_vencimento: Date.parse('2015-06-26'),
      valor: 1278.90,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '274',
      conta_corrente: '1454204',
      digito_conta_corrente: '7',
      nosso_numero: '69240101'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new

    expect(boleto_novo.banco).to eql('021')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.carteira).to eql('11')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.banco).to eql('021')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.parse('2015-06-26'))
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(1278.9)
    expect(boleto_novo.valor_documento).to eq(1278.9)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('0001454204')
    expect(boleto_novo.digito_conta_corrente).to eql('7')
    expect(boleto_novo.agencia).to eql('0274')
    expect(boleto_novo.nosso_numero).to eql('69240101')
    expect(boleto_novo.nosso_numero_boleto).to eql('69240101-68')
    expect(boleto_novo.carteira).to eql('11')
    expect(boleto_novo.codigo_barras).to eql('02199647100001278906924010100014542047202193')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('02196.92407 10100.014546 20472.021938 9 64710000127890')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(6)
  end

  it 'Montar nosso_numero_boleto' do
    valid_attributes[:nosso_numero] = '00000040'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000040-06')

    valid_attributes[:nosso_numero] = '00000068'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000068-07')

    valid_attributes[:nosso_numero] = '00000006'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000006-04')

    valid_attributes[:nosso_numero] = '00000281'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000281-00')

    valid_attributes[:nosso_numero] = '00000023'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000023-05')

    valid_attributes[:nosso_numero] = '00000337'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000337-90')

    valid_attributes[:nosso_numero] = '96656701'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('96656701-37')

    valid_attributes[:nosso_numero] = '00000484'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000484-70')

    valid_attributes[:nosso_numero] = '514'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000514-20')

    valid_attributes[:nosso_numero] = '565'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000565-70')

    valid_attributes[:nosso_numero] = '573'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000573-80')

    valid_attributes[:nosso_numero] = '00000603'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00000603-30')
  end

  it 'Montar codio de barras' do
    valid_attributes[:nosso_numero] = '00000032'
    valid_attributes[:data_vencimento] = Date.parse('2016-12-26')
    valid_attributes[:valor] = 80.0
    valid_attributes[:agencia] = '274'
    valid_attributes[:conta_corrente] = '2720129'
    valid_attributes[:digito_conta_corrente] = '2'
    valid_attributes[:carteira] = '11'
    valid_attributes[:variacao] = '4'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('02191702000000080000000003200027201292402179')

    valid_attributes[:nosso_numero] = '00000033'
    valid_attributes[:data_vencimento] = Date.parse('2016-12-16')
    valid_attributes[:valor] = 99.99
    valid_attributes[:agencia] = '274'
    valid_attributes[:conta_corrente] = '2720129'
    valid_attributes[:digito_conta_corrente] = '2'
    valid_attributes[:carteira] = '11'
    valid_attributes[:variacao] = '4'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('02199701000000099990000003300027201292402165')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('274 / 14542047')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    valid_attributes[:valor] = 135.00
    valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    valid_attributes[:nosso_numero] = '240'

    boleto_novo = described_class.new(valid_attributes)

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
    valid_attributes[:valor] = 135.00
    valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    valid_attributes[:nosso_numero] = '240'

    boleto_novo = described_class.new(valid_attributes)

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
