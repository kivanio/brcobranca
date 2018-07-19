# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Bradesco do
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
      nosso_numero: '777700168'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('237')
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
    expect(boleto_novo.carteira).to eql('06')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.banco).to eql('237')
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
    expect(boleto_novo.conta_corrente).to eql('0061900')
    expect(boleto_novo.agencia).to eql('4042')
    expect(boleto_novo.convenio).to be(12_387_989)
    expect(boleto_novo.nosso_numero).to eql('00777700168')
    expect(boleto_novo.carteira).to eql('06')
  end

  it 'Montar código de barras para carteira número 06' do
    valid_attributes[:valor] = 2952.95
    valid_attributes[:data_documento] = Date.parse('2009-04-30')
    valid_attributes[:data_vencimento] = Date.parse('2009-04-30')
    valid_attributes[:nosso_numero] = '75896452'
    valid_attributes[:conta_corrente] = '0403005'
    valid_attributes[:agencia] = '1172'
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1172060007589645204030050')
    expect(boleto_novo.codigo_barras).to eql('23795422300002952951172060007589645204030050')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('23791.17209 60007.589645 52040.300502 5 42230000295295')
  end

  it 'Montar código de barras para carteira número 03' do
    valid_attributes[:valor] = 135.00
    valid_attributes[:data_vencimento] = Date.parse('2008-02-02')
    valid_attributes[:data_documento] = Date.parse('2008-02-01')
    valid_attributes[:nosso_numero] = '777700168'
    valid_attributes[:conta_corrente] = '61900'
    valid_attributes[:agencia] = '4042'
    valid_attributes[:carteira] = '03'
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('4042030077770016800619000')
    expect(boleto_novo.codigo_barras).to eql('23791377000000135004042030077770016800619000')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('23794.04201 30077.770011 68006.190000 1 37700000013500')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(5)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(valid_attributes)

    boleto_novo.nosso_numero = '00000000525'
    boleto_novo.carteira = '06'
    expect(boleto_novo.nosso_numero_boleto).to eql('06/00000000525-P')
    expect(boleto_novo.nosso_numero_dv).to eql('P')

    boleto_novo.nosso_numero = '00000000001'
    boleto_novo.carteira = '09'
    expect(boleto_novo.nosso_numero_boleto).to eql('09/00000000001-1')
    expect(boleto_novo.nosso_numero_dv).to be(1)

    boleto_novo.nosso_numero = '00000000002'
    boleto_novo.carteira = '19'
    expect(boleto_novo.nosso_numero_boleto).to eql('19/00000000002-8')
    expect(boleto_novo.nosso_numero_dv).to be(8)

    boleto_novo.nosso_numero = 6
    boleto_novo.carteira = '19'
    expect(boleto_novo.nosso_numero_boleto).to eql('19/00000000006-0')
    expect(boleto_novo.nosso_numero_dv).to be(0)

    boleto_novo.nosso_numero = '00000000001'
    boleto_novo.carteira = '19'
    expect(boleto_novo.nosso_numero_boleto).to eql('19/00000000001-P')
    expect(boleto_novo.nosso_numero_dv).to eql('P')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('4042-8 / 0061900-0')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('0719-6 / 0061900-0')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    expect(boleto_novo.agencia_conta_boleto).to eql('0548-7 / 0001448-6')
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

  describe '#agencia_dv' do
    it { expect(described_class.new(agencia: '0255').agencia_dv).to eq(0) }
    it { expect(described_class.new(agencia: '0943').agencia_dv).to eq(1) }
    it { expect(described_class.new(agencia: '1467').agencia_dv).to eq(2) }
    it { expect(described_class.new(agencia: '0794').agencia_dv).to eq(3) }
    it { expect(described_class.new(agencia: '0155').agencia_dv).to eq(4) }
    it { expect(described_class.new(agencia: '0650').agencia_dv).to eq(5) }
    it { expect(described_class.new(agencia: '0199').agencia_dv).to eq(6) }
    it { expect(described_class.new(agencia: '1425').agencia_dv).to eq(7) }
    it { expect(described_class.new(agencia: '2839').agencia_dv).to eq(8) }
    it { expect(described_class.new(agencia: '2332').agencia_dv).to eq(9) }
    it { expect(described_class.new(agencia: '0121').agencia_dv).to eq('P') }
  end

  describe '#conta_corrente_dv' do
    it { expect(described_class.new(conta_corrente: '0325620').conta_corrente_dv).to eq(0) }
    it { expect(described_class.new(conta_corrente: '0284025').conta_corrente_dv).to eq(1) }
    it { expect(described_class.new(conta_corrente: '0238069').conta_corrente_dv).to eq(2) }
    it { expect(described_class.new(conta_corrente: '0135323').conta_corrente_dv).to eq(3) }
    it { expect(described_class.new(conta_corrente: '0010667').conta_corrente_dv).to eq(4) }
    it { expect(described_class.new(conta_corrente: '0420571').conta_corrente_dv).to eq(5) }
    it { expect(described_class.new(conta_corrente: '0510701').conta_corrente_dv).to eq(6) }
    it { expect(described_class.new(conta_corrente: '0420536').conta_corrente_dv).to eq(7) }
    it { expect(described_class.new(conta_corrente: '0012500').conta_corrente_dv).to eq(8) }
    it { expect(described_class.new(conta_corrente: '0010673').conta_corrente_dv).to eq(9) }
    it { expect(described_class.new(conta_corrente: '0019669').conta_corrente_dv).to eq('P') }
    it { expect(described_class.new(conta_corrente: '0301357').conta_corrente_dv).to eq('P') }
  end
end
