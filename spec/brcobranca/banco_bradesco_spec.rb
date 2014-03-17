# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Boleto::Bradesco do
  before(:each) do
    @valid_attributes = {
        :especie_documento => 'DM',
        :moeda => '9',
        :data_documento => Date.today,
        :dias_vencimento => 1,
        :aceite => 'S',
        :quantidade => 1,
        :valor => 0.0,
        :local_pagamento => 'QUALQUER BANCO ATÉ O VENCIMENTO',
        :beneficiario => 'Kivanio Barbosa',
        :documento_beneficiario => '12345678912',
        :pagador => 'Claudio Pozzebom',
        :pagador_documento => '12345678900',
        :agencia => '4042',
        :conta_corrente => '61900',
        :convenio => 12387989,
        :numero_documento => '777700168'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = Brcobranca::Boleto::Bradesco.new
    boleto_novo.banco.should eql('237')
    boleto_novo.especie_documento.should eql('DM')
    boleto_novo.especie.should eql('R$')
    boleto_novo.moeda.should eql('9')
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql('N')
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    boleto_novo.carteira.should eql('06')

  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)
    boleto_novo.banco.should eql('237')
    boleto_novo.especie_documento.should eql('DM')
    boleto_novo.especie.should eql('R$')
    boleto_novo.moeda.should eql('9')
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql('S')
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    boleto_novo.beneficiario.should eql('Kivanio Barbosa')
    boleto_novo.documento_beneficiario.should eql('12345678912')
    boleto_novo.pagador.should eql('Claudio Pozzebom')
    boleto_novo.pagador_documento.should eql('12345678900')
    boleto_novo.conta_corrente.should eql('0061900')
    boleto_novo.agencia.should eql('4042')
    boleto_novo.convenio.should eql(12387989)
    boleto_novo.numero_documento.should eql('00777700168')
    boleto_novo.carteira.should eql('06')
  end

  it 'Montar código de barras para carteira número 06' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse('2009-04-30')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '75896452'
    @valid_attributes[:conta_corrente] = '0403005'
    @valid_attributes[:agencia] = '1172'
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('1172060007589645204030050')
    boleto_novo.codigo_barras.should eql('23795422300002952951172060007589645204030050')
    boleto_novo.codigo_barras.linha_digitavel.should eql('23791.17209 60007.589645 52040.300502 5 42230000295295')
  end

  it 'Montar código de barras para carteira número 03' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:dias_vencimento] = 1
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:numero_documento] = '777700168'
    @valid_attributes[:conta_corrente] = '61900'
    @valid_attributes[:agencia] = '4042'
    @valid_attributes[:carteira] = '03'
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('4042030077770016800619000')
    boleto_novo.codigo_barras.should eql('23791377000000135004042030077770016800619000')
    boleto_novo.codigo_barras.linha_digitavel.should eql('23794.04201 30077.770011 68006.190000 1 37700000013500')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = Brcobranca::Boleto::Bradesco.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(3)
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    boleto_novo.numero_documento = '4042'
    boleto_novo.carteira = '06'
    boleto_novo.nosso_numero_boleto.should eql('06/00000004042-8')
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = '61900'
    boleto_novo.carteira = '05'
    boleto_novo.nosso_numero_boleto.should eql('05/00000061900-0')
    boleto_novo.nosso_numero_dv.should eql(0)
    boleto_novo.numero_documento = '0719'
    boleto_novo.carteira = '07'
    boleto_novo.nosso_numero_boleto.should eql('07/00000000719-6')
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.numero_documento = 4042
    boleto_novo.carteira = '06'
    boleto_novo.nosso_numero_boleto.should eql('06/00000004042-8')
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = 61900
    boleto_novo.carteira = '05'
    boleto_novo.nosso_numero_boleto.should eql('05/00000061900-0')
    boleto_novo.nosso_numero_dv.should eql(0)
    boleto_novo.numero_documento = 719
    boleto_novo.carteira = '07'
    boleto_novo.nosso_numero_boleto.should eql('07/00000000719-6')
    boleto_novo.nosso_numero_dv.should eql(6)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    boleto_novo.agencia_conta_boleto.should eql('4042-8 / 0061900-0')
    boleto_novo.agencia = '0719'
    boleto_novo.agencia_conta_boleto.should eql('0719-6 / 0061900-0')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    boleto_novo.agencia_conta_boleto.should eql('0548-7 / 0001448-6')
  end

  it 'Busca logotipo do banco' do
    boleto_novo = Brcobranca::Boleto::Bradesco.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse('2009-04-30')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '75896452'
    @valid_attributes[:conta_corrente] = '0403005'
    @valid_attributes[:agencia] = '1172'
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    %w| pdf jpg tif png ps |.each do |format|
      file_body=boleto_novo.send("to_#{format}".to_sym)
      tmp_file=Tempfile.new('foobar.' << format)
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      File.stat(tmp_file.path).zero?.should be_false
      File.delete(tmp_file.path).should eql(1)
      File.exist?(tmp_file.path).should be_false
    end
  end

  it 'Gerar boleto nos formatos válidos' do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse('2009-04-30')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '75896452'
    @valid_attributes[:conta_corrente] = '0403005'
    @valid_attributes[:agencia] = '1172'
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    %w| pdf jpg tif png ps |.each do |format|
      file_body=boleto_novo.to(format)
      tmp_file=Tempfile.new('foobar.' << format)
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      File.stat(tmp_file.path).zero?.should be_false
      File.delete(tmp_file.path).should eql(1)
      File.exist?(tmp_file.path).should be_false
    end
  end

end
