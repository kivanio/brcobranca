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
      agencia_dv: '8',
      conta_corrente: '61900',
      conta_corrente_dv: '7',
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
    expect(boleto_novo.quantidade).to eq(1)
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
    expect(boleto_novo.quantidade).to eq(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('00061900')
    expect(boleto_novo.conta_corrente_dv).to eql('7')
    expect(boleto_novo.agencia).to eql('4042')
    expect(boleto_novo.agencia_dv).to eql('8')
    expect(boleto_novo.convenio).to eq(12_387_989)
    expect(boleto_novo.nosso_numero).to eql('77700168')
  end

  it 'Montar código de barras' do
    valid_attributes[:valor] = 180.84
    valid_attributes[:data_documento] = Date.parse('2025-02-23')
    valid_attributes[:data_vencimento] = Date.parse('2025-02-23')
    valid_attributes[:nosso_numero] = '26173001'
    valid_attributes[:conta_corrente] = '00027824'
    valid_attributes[:conta_corrente_dv] = '7'
    valid_attributes[:agencia] = '0040'
    valid_attributes[:agencia_dv] = '0'
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('7004000002782472617300112')
    expect(boleto_novo.codigo_barras).to eql('42296100100000180847004000002782472617300112')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('42297.00408 00002.782472 26173.001129 6 10010000018084')
    
    valid_attributes[:valor] = 5543.05
    valid_attributes[:data_documento] = Date.parse('2016-03-30')
    valid_attributes[:data_vencimento] = Date.parse('2016-03-30')
    valid_attributes[:nosso_numero] = '50153004'
    valid_attributes[:conta_corrente] = '00627672'
    valid_attributes[:conta_corrente_dv] = '9'
    valid_attributes[:agencia] = '1150'
    valid_attributes[:agencia_dv] = '0'
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('7115000062767295015300452')
    expect(boleto_novo.codigo_barras).to eql('42291674900005543057115000062767295015300452')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('42297.11504 00062.767298 50153.004523 1 67490000554305')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eq(9)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(valid_attributes)

    boleto_novo.nosso_numero = '94550200'
    expect(boleto_novo.nosso_numero_boleto).to eql('94550200-1')
    expect(boleto_novo.nosso_numero_dv).to eq(1)

    boleto_novo.nosso_numero = '93199999'
    expect(boleto_novo.nosso_numero_boleto).to eql('93199999-5')
    expect(boleto_novo.nosso_numero_dv).to eq(5)

    boleto_novo.nosso_numero = '26173001'
    expect(boleto_novo.nosso_numero_boleto).to eql('26173001-1')
    expect(boleto_novo.nosso_numero_dv).to eq(1)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('40428 / 000619007')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('07198 / 000619007')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    expect(boleto_novo.agencia_conta_boleto).to eql('05488 / 000014487')
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
      expect(File.delete(tmp_file.path)).to eq(1)
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
      expect(File.delete(tmp_file.path)).to eq(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end
end
