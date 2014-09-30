# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Brcobranca::Boleto::Sicredi do
  before(:each) do
    @valid_attributes = {
      especie_documento: 'A',
      moeda: '9',
      data_documento: Date.parse('2012-01-18'),
      dias_vencimento: 1,
      aceite: 'S',
      quantidade: 1,
      valor: 0.0,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '4042',
      conta_corrente: '61900',
      convenio: 12_387_989,
      numero_documento: '00168',
      posto: '18',
      byte_idt: '2'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('748')
    expect(boleto_novo.especie_documento).to eql('A')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.dias_vencimento).to eql(1)
    expect(boleto_novo.data_vencimento).to eql(Date.today + 1)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.carteira).to eql('03')

  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('748')
    expect(boleto_novo.especie_documento).to eql('A')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_documento).to eql(Date.parse('2012-01-18'))
    expect(boleto_novo.dias_vencimento).to eql(1)
    expect(boleto_novo.data_vencimento).to eql(Date.parse('2012-01-18') + 1)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('61900')
    expect(boleto_novo.agencia).to eql('4042')
    expect(boleto_novo.convenio).to eql(12_387_989)
    expect(boleto_novo.numero_documento).to eql('00168')
    expect(boleto_novo.carteira).to eql('03')
  end

  it 'Montar código de barras para carteira número 03' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:data_documento] = Date.parse('2012-01-19')
    @valid_attributes[:numero_documento] = '13871'
    @valid_attributes[:conta_corrente] = '12345'
    @valid_attributes[:agencia] = '1234'
    @valid_attributes[:carteira] = '03'
    @valid_attributes[:posto] = '18'
    @valid_attributes[:aceite] = 'N'
    @valid_attributes[:byte_idt] = '2'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('74893.11220 13871.512342 18123.451009 1 52220000295295')
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('3112213871512341812345100')
    # boleto_novo.codigo_barras.should eql("23791377000000135004042030077770016800619000")
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eql(4)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    boleto_novo.byte_idt = '2'
    boleto_novo.agencia = '1234'
    boleto_novo.posto = '18'
    boleto_novo.conta_corrente = '12345'
    boleto_novo.numero_documento = '13871'
    boleto_novo.carteira = '03'
    expect(boleto_novo.nosso_numero_boleto).to eql('12/213871-5')
    expect(boleto_novo.nosso_numero_dv).to eql(5)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    boleto_novo.agencia = '1234'
    boleto_novo.posto = '18'
    boleto_novo.conta_corrente = '12345'
    expect(boleto_novo.agencia_conta_boleto).to eql('1234.18.12345')
  end

  it 'Busca logotipo do banco' do
    boleto_novo = described_class.new
    expect(File.exist?(boleto_novo.logotipo)).to be_truthy
    expect(File.stat(boleto_novo.logotipo).zero?).to be_falsey
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
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
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse('2009-04-30')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '86452'
    @valid_attributes[:conta_corrente] = '03005'
    @valid_attributes[:agencia] = '1172'
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
