# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Boleto::BancoBrasil do #:nodoc:[all]
  before do
    @valid_attributes = {
      valor: 0.0,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '4042',
      conta_corrente: '61900',
      convenio: 12_387_989,
      numero_documento: '777700168'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('001')
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
    expect(boleto_novo.carteira).to eql('18')
    expect(boleto_novo.codigo_servico).to be_falsey
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('001')
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
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('00061900')
    expect(boleto_novo.agencia).to eql('4042')
    expect(boleto_novo.convenio).to eql(12_387_989)
    expect(boleto_novo.numero_documento).to eql('777700168')
    expect(boleto_novo.carteira).to eql('18')
    expect(boleto_novo.codigo_servico).to be_falsey
  end

  it 'Montar código de barras para convenio de 8 digitos e nosso número de 9' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000001238798977770016818')
    expect(boleto_novo.codigo_barras).to eql('00193376900000135000000001238798977770016818')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00190.00009 01238.798977 77700.168188 3 37690000013500')
    expect(boleto_novo.conta_corrente_dv).to eql(0)
    expect(boleto_novo.nosso_numero_dv).to eql(7)

    @valid_attributes[:data_vencimento] = Date.parse('2008-02-02')
    @valid_attributes[:numero_documento] = '7700168'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000001238798900770016818')
    expect(boleto_novo.codigo_barras).to eql('00193377000000135000000001238798900770016818')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00190.00009 01238.798902 07700.168185 3 37700000013500')
    expect(boleto_novo.conta_corrente_dv).to eql(0)
    expect(boleto_novo.nosso_numero_dv).to eql(7)
  end

  it 'Montar código de barras para convenio de 7 digitos e nosso numero de 10' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    @valid_attributes[:convenio] = 1_238_798
    @valid_attributes[:numero_documento] = '7777700168'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000001238798777770016818')
    expect(boleto_novo.codigo_barras).to eql('00193377100000135000000001238798777770016818')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00190.00009 01238.798779 77700.168188 3 37710000013500')
    expect(boleto_novo.conta_corrente_dv).to eql(0)

    @valid_attributes[:valor] = 723.56
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    @valid_attributes[:convenio] = 1_238_798
    @valid_attributes[:numero_documento] = '7777700168'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000001238798777770016818')
    expect(boleto_novo.codigo_barras).to eql('00195377100000723560000001238798777770016818')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00190.00009 01238.798779 77700.168188 5 37710000072356')
    expect(boleto_novo.conta_corrente_dv).to eql(0)

    @valid_attributes[:valor] = 723.56
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    @valid_attributes[:convenio] = 1_238_798
    @valid_attributes[:numero_documento] = '7777700168'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0000001238798777770016818')
    expect(boleto_novo.codigo_barras).to eql('00194376900000723560000001238798777770016818')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00190.00009 01238.798779 77700.168188 4 37690000072356')
    expect(boleto_novo.conta_corrente_dv).to eql(0)
  end

  it 'Montar código de barras para convenio de 6 digitos e nosso numero de 5' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    @valid_attributes[:convenio] = 123_879
    @valid_attributes[:numero_documento] = '1234'
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.conta_corrente_dv).to eql(0)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1238790123440420006190018')
    expect(boleto_novo.codigo_barras).to eql('00192376900000135001238790123440420006190018')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00191.23876 90123.440423 00061.900189 2 37690000013500')
  end

  it 'Montar código de barras para convenio de 6 digitos, nosso numero de 17 e carteira 16' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    @valid_attributes[:convenio] = 123_879
    @valid_attributes[:numero_documento] = '1234567899'
    @valid_attributes[:carteira] = '16'
    @valid_attributes[:codigo_servico] = true
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.conta_corrente_dv).to eql(0)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1238790000000123456789921')
    expect(boleto_novo.codigo_barras).to eql('00199376900000135001238790000000123456789921')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00191.23876 90000.000126 34567.899215 9 37690000013500')
  end

  it 'Montar código de barras para convenio de 6 digitos, nosso numero de 17 e carteira 18' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    @valid_attributes[:convenio] = 123_879
    @valid_attributes[:numero_documento] = '1234567899'
    @valid_attributes[:carteira] = '18'
    @valid_attributes[:codigo_servico] = true
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.conta_corrente_dv).to eql(0)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1238790000000123456789921')
    expect(boleto_novo.codigo_barras).to eql('00199376900000135001238790000000123456789921')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00191.23876 90000.000126 34567.899215 9 37690000013500')
  end

  it 'Não montar código de barras para convenio de 6 digitos, nosso numero de 17 e carteira 17' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    @valid_attributes[:convenio] = 123_879
    @valid_attributes[:numero_documento] = '1234567899'
    @valid_attributes[:carteira] = '17'
    @valid_attributes[:codigo_servico] = true
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.conta_corrente_dv).to eql(0)
    expect { boleto_novo.codigo_barras_segunda_parte }.to raise_error(RuntimeError)
    expect { boleto_novo.codigo_barras_segunda_parte }.to raise_error('Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é 17')
  end

  it 'Montar código de barras para convenio de 4 digitos e nosso numero de 7' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-01')
    @valid_attributes[:convenio] = 1238
    @valid_attributes[:numero_documento] = '123456'
    @valid_attributes[:codigo_servico] = true
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.conta_corrente_dv).to eql(0)
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1238012345640420006190018')
    expect(boleto_novo.codigo_barras).to eql('00191376900000135001238012345640420006190018')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('00191.23801 12345.640424 00061.900189 1 37690000013500')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::NaoImplementado)
    expect(boleto_novo.errors.count).to eql(2)
  end

  it 'Calcular agencia_dv' do
    boleto_novo = described_class.new(@valid_attributes)
    boleto_novo.agencia = '85068014982'
    expect(boleto_novo.agencia_dv).to eql(9)
    boleto_novo.agencia = '05009401448'
    expect(boleto_novo.agencia_dv).to eql(1)
    boleto_novo.agencia = '12387987777700168'
    expect(boleto_novo.agencia_dv).to eql(2)
    boleto_novo.agencia = '4042'
    expect(boleto_novo.agencia_dv).to eql(8)
    boleto_novo.agencia = '61900'
    expect(boleto_novo.agencia_dv).to eql(0)
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_dv).to eql(6)
    boleto_novo.agencia = 85_068_014_982
    expect(boleto_novo.agencia_dv).to eql(9)
    boleto_novo.agencia = 5_009_401_448
    expect(boleto_novo.agencia_dv).to eql(1)
    boleto_novo.agencia = 12_387_987_777_700_168
    expect(boleto_novo.agencia_dv).to eql(2)
    boleto_novo.agencia = 4042
    expect(boleto_novo.agencia_dv).to eql(8)
    boleto_novo.agencia = 61_900
    expect(boleto_novo.agencia_dv).to eql(0)
    boleto_novo.agencia = 719
    expect(boleto_novo.agencia_dv).to eql(6)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(@valid_attributes)
    boleto_novo.numero_documento = '4042'
    expect(boleto_novo.nosso_numero_boleto).to eql('12387989000004042')
    expect(boleto_novo.nosso_numero_dv).to eql(4)
    boleto_novo.numero_documento = '61900'
    expect(boleto_novo.nosso_numero_boleto).to eql('12387989000061900')
    expect(boleto_novo.nosso_numero_dv).to eql(7)
    boleto_novo.numero_documento = '0719'
    expect(boleto_novo.nosso_numero_boleto).to eql('12387989000000719')
    expect(boleto_novo.nosso_numero_dv).to eql(2)
    boleto_novo.numero_documento = 4042
    expect(boleto_novo.nosso_numero_boleto).to eql('12387989000004042')
    expect(boleto_novo.nosso_numero_dv).to eql(4)
    boleto_novo.numero_documento = 61_900
    expect(boleto_novo.nosso_numero_boleto).to eql('12387989000061900')
    expect(boleto_novo.nosso_numero_dv).to eql(7)
    boleto_novo.numero_documento = 719
    expect(boleto_novo.nosso_numero_boleto).to eql('12387989000000719')
    expect(boleto_novo.nosso_numero_dv).to eql(2)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('4042-8 / 00061900-0')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('0719-6 / 00061900-0')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    expect(boleto_novo.agencia_conta_boleto).to eql('0548-7 / 00001448-6')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    @valid_attributes[:convenio] = 1_238_798
    @valid_attributes[:numero_documento] = '7777700168'
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
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    @valid_attributes[:convenio] = 1_238_798
    @valid_attributes[:numero_documento] = '7777700168'
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
