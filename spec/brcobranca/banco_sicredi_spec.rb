# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Boleto::Sicredi do
  before(:each) do
    @valid_attributes = {
      :especie_documento => "A",
      :moeda => "9",
      :data_documento => Date.parse('2012-01-18'),
      :dias_vencimento => 1,
      :aceite => "S",
      :quantidade => 1,
      :valor => 0.0,
      :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO",
      :beneficiario => "Kivanio Barbosa",
      :documento_beneficiario => "12345678912",
      :pagador => "Claudio Pozzebom",
      :pagador_documento => "12345678900",
      :agencia => "4042",
      :conta_corrente => "61900",
      :convenio => 12387989,
      :numero_documento => "00168",
      :posto => '18',
      :byte_idt => '2'
    }
  end

  it "Criar nova instancia com atributos padrões" do
    boleto_novo = Brcobranca::Boleto::Sicredi.new
    boleto_novo.banco.should eql("748")
    boleto_novo.especie_documento.should eql("A")
    boleto_novo.especie.should eql("R$")
    boleto_novo.moeda.should eql("9")
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql("N")
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    boleto_novo.carteira.should eql("03")

  end

  it "Criar nova instancia com atributos válidos" do
    boleto_novo = Brcobranca::Boleto::Sicredi.new(@valid_attributes)
    boleto_novo.banco.should eql("748")
    boleto_novo.especie_documento.should eql("A")
    boleto_novo.especie.should eql("R$")
    boleto_novo.moeda.should eql("9")
    boleto_novo.data_documento.should eql(Date.parse('2012-01-18'))
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.parse('2012-01-18') + 1)
    boleto_novo.aceite.should eql("S")
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    boleto_novo.beneficiario.should eql("Kivanio Barbosa")
    boleto_novo.documento_beneficiario.should eql("12345678912")
    boleto_novo.pagador.should eql("Claudio Pozzebom")
    boleto_novo.pagador_documento.should eql("12345678900")
    boleto_novo.conta_corrente.should eql("61900")
    boleto_novo.agencia.should eql("4042")
    boleto_novo.convenio.should eql(12387989)
    boleto_novo.numero_documento.should eql("00168")
    boleto_novo.carteira.should eql("03")
  end

  it "Montar código de barras para carteira número 03" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:data_documento] = Date.parse("2012-01-19")
    @valid_attributes[:numero_documento] = "13871"
    @valid_attributes[:conta_corrente] = "12345"
    @valid_attributes[:agencia] = "1234"
    @valid_attributes[:carteira] = "03"
    @valid_attributes[:posto] = "18"
    @valid_attributes[:aceite] = "N"
    @valid_attributes[:byte_idt] = "2"
    boleto_novo = Brcobranca::Boleto::Sicredi.new(@valid_attributes)

    boleto_novo.codigo_barras.linha_digitavel.should eql("74893.11220 13871.512342 18123.451009 1 52220000295295")
    boleto_novo.codigo_barras_segunda_parte.should eql("3112213871512341812345100")
    #boleto_novo.codigo_barras.should eql("23791377000000135004042030077770016800619000")
  end

  it "Não permitir gerar boleto com atributos inválido" do
    boleto_novo = Brcobranca::Boleto::Sicredi.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(3)
  end

  it "Montar nosso_numero_boleto" do
    boleto_novo = Brcobranca::Boleto::Sicredi.new(@valid_attributes)

    boleto_novo.byte_idt = "2"
    boleto_novo.agencia = "1234"
    boleto_novo.posto = "18"
    boleto_novo.conta_corrente = "12345"
    boleto_novo.numero_documento = "13871"
    boleto_novo.carteira = "03"
    boleto_novo.nosso_numero_boleto.should eql("12/213871-5")
    boleto_novo.nosso_numero_dv.should eql(5)
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = Brcobranca::Boleto::Sicredi.new(@valid_attributes)

    boleto_novo.agencia = "1234"
    boleto_novo.posto = "18"
    boleto_novo.conta_corrente = "12345"
    boleto_novo.agencia_conta_boleto.should eql("1234.18.12345")
  end

  it "Busca logotipo do banco" do
    boleto_novo = Brcobranca::Boleto::Sicredi.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it "Gerar boleto nos formatos válidos com método to_" do
    boleto_novo = Brcobranca::Boleto::Sicredi.new(@valid_attributes)

    %w| pdf jpg tif png ps |.each do |format|
      file_body=boleto_novo.send("to_#{format}".to_sym)
      tmp_file=Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      File.stat(tmp_file.path).zero?.should be_false
      File.delete(tmp_file.path).should eql(1)
      File.exist?(tmp_file.path).should be_false
    end
  end

  it "Gerar boleto nos formatos válidos" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "86452"
    @valid_attributes[:conta_corrente] = "03005"
    @valid_attributes[:agencia] = "1172"
    boleto_novo = Brcobranca::Boleto::Sicredi.new(@valid_attributes)

    %w| pdf jpg tif png ps |.each do |format|
      file_body=boleto_novo.to(format)
      tmp_file=Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      File.stat(tmp_file.path).zero?.should be_false
      File.delete(tmp_file.path).should eql(1)
      File.exist?(tmp_file.path).should be_false
    end
  end

end

