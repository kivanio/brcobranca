# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Boleto::Hsbc do

  before(:each) do
    @valid_attributes = {
      :especie_documento => "DM",
      :moeda => "9",
      :data_documento => Date.today,
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
      :numero_documento => "777700168"
    }
  end


  it "Criar nova instancia com atributos padrões" do
    boleto_novo = Brcobranca::Boleto::Hsbc.new
    boleto_novo.banco.should eql("399")
    boleto_novo.especie_documento.should eql("DM")
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
    boleto_novo.carteira.should eql("CNR")

  end

  it "Criar nova instancia com atributos válidos" do
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)
    boleto_novo.banco.should eql("399")
    boleto_novo.especie_documento.should eql("DM")
    boleto_novo.especie.should eql("R$")
    boleto_novo.moeda.should eql("9")
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql("S")
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    boleto_novo.beneficiario.should eql("Kivanio Barbosa")
    boleto_novo.documento_beneficiario.should eql("12345678912")
    boleto_novo.pagador.should eql("Claudio Pozzebom")
    boleto_novo.pagador_documento.should eql("12345678900")
    boleto_novo.conta_corrente.should eql("0061900")
    boleto_novo.agencia.should eql("4042")
    boleto_novo.convenio.should eql(12387989)
    boleto_novo.numero_documento.should eql("0000777700168")
    boleto_novo.carteira.should eql("CNR")
  end

  it "Gerar boleto" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-03")
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:numero_documento] = "12345678"
    @valid_attributes[:conta_corrente] = "1122334"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql("1122334000001234567809892")
    boleto_novo.codigo_barras.should eql("39998420100002952951122334000001234567809892")
    boleto_novo.codigo_barras.linha_digitavel.should eql("39991.12232 34000.001239 45678.098927 8 42010000295295")

    @valid_attributes[:valor] = 934.23
    @valid_attributes[:data_documento] = Date.parse("2004-09-03")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "07778899"
    @valid_attributes[:conta_corrente] = "0016324"
    @valid_attributes[:agencia] = "1234"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql("0016324000000777889924742")
    boleto_novo.codigo_barras.should eql("39993252300000934230016324000000777889924742")
    boleto_novo.codigo_barras.linha_digitavel.should eql("39990.01633 24000.000778 78899.247429 3 25230000093423")
  end

  it "Não permitir gerar boleto com atributos inválido" do
    boleto_novo = Brcobranca::Boleto::Hsbc.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(3)
  end

  it "Montar nosso número" do
    @valid_attributes[:data_documento] = Date.parse("2000-07-04")
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:numero_documento] = "12345678"
    @valid_attributes[:conta_corrente] = "1122334"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    boleto_novo.nosso_numero.should eql("0000012345678942")

    @valid_attributes[:data_documento] = Date.parse("2000-07-04")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "39104766"
    @valid_attributes[:conta_corrente] = "351202"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    boleto_novo.nosso_numero.should eql("0000039104766340")

    @valid_attributes[:data_documento] = Date.parse("2009-04-03")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "39104766"
    @valid_attributes[:conta_corrente] = "351202"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    boleto_novo.nosso_numero.should eql("0000039104766346")

    @valid_attributes[:data_documento] = nil
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "39104766"
    @valid_attributes[:conta_corrente] = "351202"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    lambda { boleto_novo.nosso_numero }.should raise_error(ArgumentError)
  end

  it "Montar nosso_numero_boleto" do
     @valid_attributes[:data_documento] = Date.parse("2009-08-14")
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    boleto_novo.numero_documento = "4042"
    boleto_novo.carteira = "06"
    boleto_novo.nosso_numero_boleto.should eql("0000000004042847")
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = "61900"
    boleto_novo.carteira = "05"
    boleto_novo.nosso_numero_boleto.should eql("0000000061900049")
    boleto_novo.nosso_numero_dv.should eql(0)
    boleto_novo.numero_documento = "0719"
    boleto_novo.carteira = "07"
    boleto_novo.nosso_numero_boleto.should eql("0000000000719640")
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.numero_documento = 4042
    boleto_novo.carteira = "06"
    boleto_novo.nosso_numero_boleto.should eql("0000000004042847")
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = 61900
    boleto_novo.carteira = "05"
    boleto_novo.nosso_numero_boleto.should eql("0000000061900049")
    boleto_novo.nosso_numero_dv.should eql(0)
    boleto_novo.numero_documento = 719
    boleto_novo.carteira = "07"
    boleto_novo.nosso_numero_boleto.should eql("0000000000719640")
    boleto_novo.nosso_numero_dv.should eql(6)
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

    boleto_novo.agencia_conta_boleto.should eql("0061900")
    boleto_novo.agencia = "0719"
    boleto_novo.agencia_conta_boleto.should eql("0061900")
    boleto_novo.agencia = "0548"
    boleto_novo.conta_corrente = "1448"
    boleto_novo.agencia_conta_boleto.should eql("0001448")
  end

  it "Busca logotipo do banco" do
    boleto_novo = Brcobranca::Boleto::Hsbc.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it "Gerar boleto nos formatos válidos com método to_" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-03")
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:numero_documento] = "12345678"
    @valid_attributes[:conta_corrente] = "1122334"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

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
    @valid_attributes[:data_documento] = Date.parse("2009-04-03")
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:numero_documento] = "12345678"
    @valid_attributes[:conta_corrente] = "1122334"
    boleto_novo = Brcobranca::Boleto::Hsbc.new(@valid_attributes)

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
