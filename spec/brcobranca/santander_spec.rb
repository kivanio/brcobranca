# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Boleto::Santander do
  before(:each) do
    @valid_attributes = {
        :especie_documento => 'DS',
        :moeda => '9',
        :data_documento => Date.today,
        :dias_vencimento => 1,
        :aceite => 'N',
        :quantidade => 1,
        :valor => 25.0,
        :local_pagamento => 'QUALQUER BANCO ATÉ O VENCIMENTO',
        :beneficiario => 'Kivanio Barbosa',
        :documento_beneficiario => '12345678912',
        :pagador => 'Claudio Pozzebom',
        :pagador_documento => '12345678900',
        :agencia => '0059',
        :convenio => 1899775,
        :numero_documento => '90000267'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = Brcobranca::Boleto::Santander.new
    boleto_novo.banco.should eql('033')
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
    boleto_novo.carteira.should eql('102')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)
    boleto_novo.banco.should eql('033')
    boleto_novo.especie_documento.should eql('DS')
    boleto_novo.especie.should eql('R$')
    boleto_novo.moeda.should eql('9')
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql('N')
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(25.0)
    boleto_novo.valor_documento.should eql(25.0)
    boleto_novo.local_pagamento.should eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    boleto_novo.beneficiario.should eql('Kivanio Barbosa')
    boleto_novo.documento_beneficiario.should eql('12345678912')
    boleto_novo.pagador.should eql('Claudio Pozzebom')
    boleto_novo.pagador_documento.should eql('12345678900')
    boleto_novo.agencia.should eql('0059')
    boleto_novo.convenio.should eql('1899775')
    boleto_novo.numero_documento.should eql('90000267')
    boleto_novo.carteira.should eql('102')
  end

  it 'Gerar boleto' do
    @valid_attributes[:data_documento] = Date.parse('2011/10/08')
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)
    boleto_novo.codigo_barras_segunda_parte.should eql('9189977500000900002670102')
    boleto_novo.codigo_barras.should eql('03391511500000025009189977500000900002670102')
    boleto_novo.codigo_barras.linha_digitavel.should eql('03399.18997 77500.000904 00026.701029 1 51150000002500')

    @valid_attributes[:valor] = 54.00
    @valid_attributes[:numero_documento] = '90002720'
    @valid_attributes[:data_documento] = Date.parse('2012/09/07')
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)
    boleto_novo.codigo_barras_segunda_parte.should eql('9189977500000900027200102')
    boleto_novo.codigo_barras.should eql('03391545000000054009189977500000900027200102')
    boleto_novo.codigo_barras.linha_digitavel.should eql('03399.18997 77500.000904 00272.001025 1 54500000005400')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = Brcobranca::Boleto::Santander.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(2)
  end

  it 'Montar nosso_numero_dv' do
    @valid_attributes[:numero_documento] = '566612457800'
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)
    boleto_novo.nosso_numero_dv.should eql(2)

    @valid_attributes[:numero_documento] = '90002720'
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)
    boleto_novo.nosso_numero_dv.should eql(7)
  end

  it 'Montar nosso_numero_boleto' do
    @valid_attributes[:numero_documento] = '566612457800'
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)
    boleto_novo.nosso_numero_boleto.should eql('566612457800-2')

    @valid_attributes[:numero_documento] = '90002720'
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)
    boleto_novo.nosso_numero_boleto.should eql('000090002720-7')
  end

  it 'Busca logotipo do banco' do
    boleto_novo = Brcobranca::Boleto::Santander.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)

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
    boleto_novo = Brcobranca::Boleto::Santander.new(@valid_attributes)

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
