# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Boleto::Itau do
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
        :agencia => '0810',
        :conta_corrente => '53678',
        :convenio => 12387,
        :numero_documento => '12345678'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = Brcobranca::Boleto::Itau.new
    boleto_novo.banco.should eql('341')
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
    boleto_novo.carteira.should eql('175')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)
    boleto_novo.banco.should eql('341')
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
    boleto_novo.conta_corrente.should eql('53678')
    boleto_novo.agencia.should eql('0810')
    boleto_novo.convenio.should eql('12387')
    boleto_novo.numero_documento.should eql('12345678')
    boleto_novo.carteira.should eql('175')
  end

  it 'Gerar boleto' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('1751234567840810536789000')
    boleto_novo.codigo_barras.should eql('34191432900000000001751234567840810536789000')
    boleto_novo.codigo_barras.linha_digitavel.should eql('34191.75124 34567.840813 05367.890000 1 43290000000000')

    @valid_attributes[:valor] = 135.00
    @valid_attributes[:numero_documento] = '258281'
    @valid_attributes[:data_documento] = Date.parse('2008/02/01')
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('1750025828170810536789000')
    boleto_novo.codigo_barras.should eql('34191377000000135001750025828170810536789000')
    boleto_novo.codigo_barras.linha_digitavel.should eql('34191.75009 25828.170818 05367.890000 1 37700000013500')

    @valid_attributes[:numero_documento] = '258281'
    @valid_attributes[:data_documento] = Date.parse('2004/09/04')
    @valid_attributes[:carteira] = 168
    @valid_attributes[:valor] = 135.00
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('1680025828120810536789000')
    boleto_novo.codigo_barras.should eql('34194252500000135001680025828120810536789000')
    boleto_novo.codigo_barras.linha_digitavel.should eql('34191.68004 25828.120813 05367.890000 4 25250000013500')

    @valid_attributes[:numero_documento] = '258281'
    @valid_attributes[:data_documento] = Date.parse('2004/09/04')
    @valid_attributes[:carteira] = 196
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:convenio] = '12345'
    @valid_attributes[:seu_numero] = '1234567'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('1960025828112345671234550')
    boleto_novo.codigo_barras.should eql('34191252500000135001960025828112345671234550')
    boleto_novo.codigo_barras.linha_digitavel.should eql('34191.96005 25828.112349 56712.345505 1 25250000013500')

    @valid_attributes[:numero_documento] = '258281'
    @valid_attributes[:data_documento] = Date.parse('2004/09/04')
    @valid_attributes[:carteira] = 196
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:convenio] = '12345'
    @valid_attributes[:seu_numero] = '123456'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('1960025828101234561234550')
    boleto_novo.codigo_barras.should eql('34192252500000135001960025828101234561234550')
    boleto_novo.codigo_barras.linha_digitavel.should eql('34191.96005 25828.101235 45612.345509 2 25250000013500')

    @valid_attributes[:numero_documento] = '258281'
    @valid_attributes[:data_documento] = Date.parse('2004/09/04')
    @valid_attributes[:carteira] = 196
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:convenio] = '1234'
    @valid_attributes[:seu_numero] = '123456'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql('1960025828101234560123440')
    boleto_novo.codigo_barras.should eql('34192252500000135001960025828101234560123440')
    boleto_novo.codigo_barras.linha_digitavel.should eql('34191.96005 25828.101235 45601.234409 2 25250000013500')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = Brcobranca::Boleto::Itau.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(3)
  end

  it 'Montar agencia_conta_corrente_dv' do
    @valid_attributes[:conta_corrente] = '15255'
    @valid_attributes[:agencia] = '0607'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.agencia_conta_corrente_dv.should eql(0)
    boleto_novo.agencia_conta_boleto.should eql('0607 / 15255-0')

    @valid_attributes[:conta_corrente] = '85547'
    @valid_attributes[:agencia] = '1547'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.agencia_conta_corrente_dv.should eql(6)
    boleto_novo.agencia_conta_boleto.should eql('1547 / 85547-6')

    @valid_attributes[:conta_corrente] = '10207'
    @valid_attributes[:agencia] = '1547'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.agencia_conta_corrente_dv.should eql(7)

    @valid_attributes[:conta_corrente] = '53678'
    @valid_attributes[:agencia] = '0811'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.agencia_conta_corrente_dv.should eql(8)
    boleto_novo.agencia_conta_boleto.should eql('0811 / 53678-8')
  end

  it 'Montar nosso_numero_boleto' do
    @valid_attributes[:conta_corrente] = '15255'
    @valid_attributes[:agencia] = '0607'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.nosso_numero_boleto.should eql('175/12345678-4')

    @valid_attributes[:conta_corrente] = '15255'
    @valid_attributes[:agencia] = '0607'
    @valid_attributes[:carteira] = '143'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.nosso_numero_boleto.should eql('143/12345678-2')
  end

  it 'Montar nosso_numero_dv' do
    @valid_attributes[:numero_documento] = '00015448'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.nosso_numero_dv.should eql(6)

    @valid_attributes[:numero_documento] = '15448'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.nosso_numero_dv.should eql(6)

    @valid_attributes[:numero_documento] = '12345678'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.nosso_numero_dv.should eql(4)

    @valid_attributes[:numero_documento] = '34230'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.nosso_numero_dv.should eql(5)

    @valid_attributes[:numero_documento] = '258281'
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

    boleto_novo.nosso_numero_dv.should eql(7)
  end

  it 'Busca logotipo do banco' do
    boleto_novo = Brcobranca::Boleto::Itau.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

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
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = Brcobranca::Boleto::Itau.new(@valid_attributes)

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
