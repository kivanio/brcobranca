# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Boleto::Real do
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
    boleto_novo = Brcobranca::Boleto::Real.new
    boleto_novo.banco.should eql('356')
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
    boleto_novo.carteira.should eql('57')

  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = Brcobranca::Boleto::Real.new(@valid_attributes)
    boleto_novo.banco.should eql('356')
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
    boleto_novo.numero_documento.should eql('0000777700168')
    boleto_novo.carteira.should eql('57')
  end

  it 'Gerar boleto para carteira registrada' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '7701684'
    @valid_attributes[:carteira] = '56'
    boleto_novo = Brcobranca::Boleto::Real.new(@valid_attributes)

    boleto_novo.agencia_conta_corrente_nosso_numero_dv.should eql(8)
    boleto_novo.codigo_barras_segunda_parte.should eql('0000004042006190087701684')
    boleto_novo.codigo_barras.should eql('35691376900000135000000004042006190087701684')
    boleto_novo.codigo_barras.linha_digitavel.should eql('35690.00007 04042.006199 00877.016840 1 37690000013500')
  end

  it 'Gerar boleto pra carteiras sem registro' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:dias_vencimento] = 1
    @valid_attributes[:numero_documento] = '777700168'
    @valid_attributes[:carteira] = '57'
    boleto_novo = Brcobranca::Boleto::Real.new(@valid_attributes)

    boleto_novo.agencia_conta_corrente_nosso_numero_dv.should eql(3)
    boleto_novo.codigo_barras_segunda_parte.should eql('4042006190030000777700168')
    boleto_novo.codigo_barras.should eql('35692377000000135004042006190030000777700168')
    boleto_novo.codigo_barras.linha_digitavel.should eql('35694.04209 06190.030004 07777.001681 2 37700000013500')

    @valid_attributes[:valor] = 934.23
    @valid_attributes[:data_documento] = Date.parse('2004-09-03')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '00005020'
    @valid_attributes[:carteira] = '57'
    @valid_attributes[:conta_corrente] = '0016324'
    @valid_attributes[:agencia] = '1018'
    boleto_novo = Brcobranca::Boleto::Real.new(@valid_attributes)

    boleto_novo.agencia_conta_corrente_nosso_numero_dv.should eql(9)
    boleto_novo.codigo_barras_segunda_parte.should eql('1018001632490000000005020')
    boleto_novo.codigo_barras.should eql('35697252300000934231018001632490000000005020')
    boleto_novo.codigo_barras.linha_digitavel.should eql('35691.01805 01632.490007 00000.050203 7 25230000093423')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = Brcobranca::Boleto::Real.new(:numero_documento => '18030299444444444401')
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(3)
  end

  it 'Busca logotipo do banco' do
    boleto_novo = Brcobranca::Boleto::Real.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '7701684'
    @valid_attributes[:carteira] = '56'
    boleto_novo = Brcobranca::Boleto::Real.new(@valid_attributes)

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
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse('2008-02-01')
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = '7701684'
    @valid_attributes[:carteira] = '56'
    boleto_novo = Brcobranca::Boleto::Real.new(@valid_attributes)

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
