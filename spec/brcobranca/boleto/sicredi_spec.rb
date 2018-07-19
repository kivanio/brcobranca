# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Sicredi do
  let(:valid_attributes) do
    {
      data_processamento: Date.parse('2016-08-22'),
      data_vencimento: Date.parse('2016-08-22'),
      valor: 195.57,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '0710',
      conta_corrente: '61900',
      convenio: '129',
      nosso_numero: '8879',
      posto: '65',
      byte_idt: '2',
      carteira: '1'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('748')
    expect(boleto_novo.especie_documento).to eql('A')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.carteira).to eql('3')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.banco).to eql('748')
    expect(boleto_novo.especie_documento).to eql('A')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.parse('2016-08-22'))
    expect(boleto_novo.data_vencimento).to eql(Date.parse('2016-08-22'))
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(195.57)
    expect(boleto_novo.valor_documento).to eq(195.57)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('61900')
    expect(boleto_novo.agencia).to eql('0710')
    expect(boleto_novo.convenio).to eql('00129')
    expect(boleto_novo.nosso_numero).to eql('08879')
    expect(boleto_novo.carteira).to eql('1')
  end

  it 'Montar código de barras para carteira número 3' do
    valid_attributes[:carteira] = '3'
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74893.11626 08879.307109 65001.291056 1 68940000019557')
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('3116208879307106500129105')
  end

  context 'carteira número 1' do
    it 'case 1' do
      boleto_novo = described_class.new(valid_attributes)
      expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74891.11620 08879.307109 65001.291015 1 68940000019557')
      expect(boleto_novo.codigo_barras_segunda_parte).to eql('1116208879307106500129101')
    end
    it 'case 2' do
      valid_attributes[:valor] = 700.00
      valid_attributes[:data_vencimento] = Date.parse('2016-07-25')
      valid_attributes[:nosso_numero] = '08902'
      boleto_novo = described_class.new(valid_attributes)
      expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74891.11620 08902.107104 65001.291007 3 68660000070000')
      expect(boleto_novo.codigo_barras_segunda_parte).to eql('1116208902107106500129100')
    end
    it 'case 3' do
      valid_attributes[:valor] = 700.00
      valid_attributes[:data_vencimento] = Date.parse('2016-07-25')
      valid_attributes[:nosso_numero] = '8896'
      boleto_novo = described_class.new(valid_attributes)
      expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74891.11620 08896.307108 65001.291072 1 68660000070000')
      expect(boleto_novo.codigo_barras_segunda_parte).to eql('1116208896307106500129107')
    end
    it 'case 4' do
      valid_attributes[:valor] = 700.00
      valid_attributes[:data_vencimento] = Date.parse('2016-07-25')
      valid_attributes[:nosso_numero] = '8899'
      boleto_novo = described_class.new(valid_attributes)
      expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74891.11620 08899.807104 65001.291031 6 68660000070000')
      expect(boleto_novo.codigo_barras_segunda_parte).to eql('1116208899807106500129103')
    end
    it 'case 5' do
      valid_attributes[:valor] = 195.58
      valid_attributes[:data_vencimento] = Date.parse('2016-07-25')
      valid_attributes[:nosso_numero] = '8878'
      boleto_novo = described_class.new(valid_attributes)
      expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74891.11620 08878.507105 65001.291064 1 68660000019558')
      expect(boleto_novo.codigo_barras_segunda_parte).to eql('1116208878507106500129106')
    end
    it 'case 6' do
      valid_attributes[:valor] = 222.00
      valid_attributes[:data_vencimento] = Date.parse('2016-08-26')
      valid_attributes[:nosso_numero] = '9048'
      boleto_novo = described_class.new(valid_attributes)
      expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74891.11620 09048.807102 65001.291031 8 68980000022200')
      expect(boleto_novo.codigo_barras_segunda_parte).to eql('1116209048807106500129103')
    end
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(6)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to be(3)
    expect(boleto_novo.nosso_numero_boleto).to eql('16/208879-3')

    valid_attributes[:posto] = '02'
    valid_attributes[:byte_idt] = '2'
    valid_attributes[:nosso_numero] = '00003'
    valid_attributes[:agencia] = '0165'
    valid_attributes[:convenio] = '00623'
    valid_attributes[:data_vencimento] = Date.parse('2007-08-26')
    valid_attributes[:data_processamento] = Date.parse('2007-08-26')

    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to be(1)
    expect(boleto_novo.nosso_numero_boleto).to eql('07/200003-1')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.agencia_conta_boleto).to eql('0710.65.00129')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
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
    valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    valid_attributes[:nosso_numero] = '86452'
    valid_attributes[:conta_corrente] = '03005'
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
