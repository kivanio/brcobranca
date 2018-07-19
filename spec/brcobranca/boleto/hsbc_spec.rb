# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Hsbc do
  before do
    @valid_attributes = {
      valor: 0.0,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '4042',
      conta_corrente: '61900',
      convenio: 12_387_989,
      nosso_numero: '777700168'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('399')
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
    expect(boleto_novo.carteira).to eql('CNR')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('399')
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
    expect(boleto_novo.conta_corrente).to eql('0061900')
    expect(boleto_novo.agencia).to eql('4042')
    expect(boleto_novo.convenio).to be(12_387_989)
    expect(boleto_novo.nosso_numero).to eql('0000777700168')
    expect(boleto_novo.carteira).to eql('CNR')
  end

  it 'Gerar boleto' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_vencimento] = Date.parse('2009-04-08')
    @valid_attributes[:nosso_numero] = '12345678'
    @valid_attributes[:conta_corrente] = '1122334'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1122334000001234567809892')
    expect(boleto_novo.codigo_barras).to eql('39998420100002952951122334000001234567809892')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('39991.12232 34000.001239 45678.098927 8 42010000295295')

    @valid_attributes[:valor] = 934.23
    @valid_attributes[:data_vencimento] = Date.parse('2004-09-03')
    @valid_attributes[:nosso_numero] = '07778899'
    @valid_attributes[:conta_corrente] = '0016324'
    @valid_attributes[:agencia] = '1234'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0016324000000777889924742')
    expect(boleto_novo.codigo_barras).to eql('39993252300000934230016324000000777889924742')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('39990.01633 24000.000778 78899.247429 3 25230000093423')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(5)
  end

  it 'Montar nosso_numero_boleto' do
    @valid_attributes[:data_vencimento] = Date.parse('2000-07-09')
    @valid_attributes[:nosso_numero] = '12345678'
    @valid_attributes[:conta_corrente] = '1122334'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_boleto).to eql('0000012345678942')

    @valid_attributes[:data_vencimento] = Date.parse('2000-07-04')
    @valid_attributes[:nosso_numero] = '39104766'
    @valid_attributes[:conta_corrente] = '351202'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_boleto).to eql('0000039104766340')

    @valid_attributes[:data_vencimento] = Date.parse('2009-04-03')
    @valid_attributes[:nosso_numero] = '39104766'
    @valid_attributes[:conta_corrente] = '351202'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.nosso_numero_boleto).to eql('0000039104766346')

    @valid_attributes[:data_vencimento] = nil
    @valid_attributes[:nosso_numero] = '39104766'
    @valid_attributes[:conta_corrente] = '351202'
    boleto_novo = described_class.new(@valid_attributes)

    expect { boleto_novo.nosso_numero_boleto }.to raise_error(Brcobranca::BoletoInvalido)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('0061900')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('0061900')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    expect(boleto_novo.agencia_conta_boleto).to eql('0001448')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_vencimento] = Date.parse('2009-04-08')
    @valid_attributes[:nosso_numero] = '12345678'
    @valid_attributes[:conta_corrente] = '1122334'
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
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_vencimento] = Date.parse('2009-04-08')
    @valid_attributes[:nosso_numero] = '12345678'
    @valid_attributes[:conta_corrente] = '1122334'
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
