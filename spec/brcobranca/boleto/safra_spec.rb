# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Safra do
  let(:valid_attributes) do
    {
      valor: 0.0,
      local_pagamento: 'Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '4042',
      conta_corrente: '61900',
      convenio: 12_387_989,
      nosso_numero: '77700168'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('422')
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
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.banco).to eql('422')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('000061900')
    expect(boleto_novo.agencia).to eql('04042')
    expect(boleto_novo.convenio).to be(12_387_989)
    expect(boleto_novo.nosso_numero).to eql('77700168')
  end

  it 'Montar código de barras' do
    valid_attributes[:valor] = 180.84
    valid_attributes[:data_documento] = Date.parse('2025-02-23')
    valid_attributes[:data_vencimento] = Date.parse('2025-02-23')
    valid_attributes[:nosso_numero] = '26173001'
    valid_attributes[:conta_corrente] = '000278247'
    valid_attributes[:agencia] = '00400'
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('7004000002782472617300112')
    expect(boleto_novo.codigo_barras).to eql('42296100100000180847004000002782472617300112')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('42297.00408 00002.782472 26173.001129 6 10010000018084')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(5)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(valid_attributes)

    boleto_novo.nosso_numero = '94550200'
    expect(boleto_novo.nosso_numero_boleto).to eql('94550200-1')
    expect(boleto_novo.nosso_numero_dv).to be(1)

    boleto_novo.nosso_numero = '93199999'
    expect(boleto_novo.nosso_numero_boleto).to eql('93199999-5')
    expect(boleto_novo.nosso_numero_dv).to be(5)

    boleto_novo.nosso_numero = '26173001'
    expect(boleto_novo.nosso_numero_boleto).to eql('26173001-1')
    expect(boleto_novo.nosso_numero_dv).to be(1)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('04042 / 000061900')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('00719 / 000061900')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    expect(boleto_novo.agencia_conta_boleto).to eql('00548 / 000001448')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    valid_attributes[:valor] = 2952.95
    valid_attributes[:data_documento] = Date.parse('2009-04-30')
    valid_attributes[:data_vencimento] = Date.parse('2009-04-30')
    valid_attributes[:nosso_numero] = '75896452'
    valid_attributes[:conta_corrente] = '0403005'
    valid_attributes[:agencia] = '1172'
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
    valid_attributes[:valor] = 2952.95
    valid_attributes[:data_documento] = Date.parse('2009-04-30')
    valid_attributes[:data_vencimento] = Date.parse('2009-04-30')
    valid_attributes[:nosso_numero] = '75896452'
    valid_attributes[:conta_corrente] = '0403005'
    valid_attributes[:agencia] = '1172'
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
