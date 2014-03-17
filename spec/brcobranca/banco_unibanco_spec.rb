# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Boleto::Unibanco do
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
      :convenio => 2031671,
      :numero_documento => "777700168"
    }
  end

  it "Criar nova instancia com atributos padrões" do
    boleto_novo = Brcobranca::Boleto::Unibanco.new
    boleto_novo.banco.should eql("409")
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
    boleto_novo.carteira.should eql("5")

  end

  it "Criar nova instancia com atributos válidos" do
    boleto_novo = Brcobranca::Boleto::Unibanco.new(@valid_attributes)
    boleto_novo.banco.should eql("409")
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
    boleto_novo.convenio.should eql("2031671")
    boleto_novo.numero_documento.should eql("00000777700168")
    boleto_novo.carteira.should eql("5")

  end

  it "Gerar boleto para carteira registrada" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "1803029901"
    @valid_attributes[:carteira] = "4"
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    @valid_attributes[:convenio] = 2031671
    boleto_novo = Brcobranca::Boleto::Unibanco.new(@valid_attributes)

    boleto_novo.nosso_numero_dv.should eql(5)
    boleto_novo.codigo_barras_segunda_parte.should eql("0409043001236018030299015")
    boleto_novo.codigo_barras.should eql("40997422300002952950409043001236018030299015")
    boleto_novo.codigo_barras.linha_digitavel.should eql("40990.40901 43001.236017 80302.990157 7 42230000295295")
  end

  it "Gerar boleto para carteira sem registro" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:carteira] = "5"
    @valid_attributes[:numero_documento] = "1803029901"
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    boleto_novo = Brcobranca::Boleto::Unibanco.new(@valid_attributes)

    boleto_novo.nosso_numero_dv.should eql(5)
    boleto_novo.codigo_barras_segunda_parte.should eql("5203167100000018030299015")
    boleto_novo.codigo_barras.should eql("40995422300002952955203167100000018030299015")
    boleto_novo.codigo_barras.linha_digitavel.should eql("40995.20316 67100.000016 80302.990157 5 42230000295295")
  end

  it "Não permitir gerar boleto com atributos inválido" do
    boleto_novo = Brcobranca::Boleto::Unibanco.new(:numero_documento => "18030299444444444401")
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(3)
  end

  it "Montar nosso_numero_boleto" do
    boleto_novo = Brcobranca::Boleto::Unibanco.new(@valid_attributes)

    boleto_novo.numero_documento = "85068014982"
    boleto_novo.nosso_numero_boleto.should eql("00085068014982-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = "05009401448"
    boleto_novo.nosso_numero_boleto.should eql("00005009401448-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = "12387987777700168"
    boleto_novo.nosso_numero_boleto.should eql("12387987777700168-2")
    boleto_novo.nosso_numero_dv.should eql(2)
    boleto_novo.numero_documento = "4042"
    boleto_novo.nosso_numero_boleto.should eql("00000000004042-8")
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = "61900"
    boleto_novo.nosso_numero_boleto.should eql("00000000061900-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = "0719"
    boleto_novo.nosso_numero_boleto.should eql("00000000000719-6")
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.numero_documento = 85068014982
    boleto_novo.nosso_numero_boleto.should eql("00085068014982-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = 5009401448
    boleto_novo.nosso_numero_boleto.should eql("00005009401448-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = 12387987777700168
    boleto_novo.nosso_numero_boleto.should eql("12387987777700168-2")
    boleto_novo.nosso_numero_dv.should eql(2)
    boleto_novo.numero_documento = 4042
    boleto_novo.nosso_numero_boleto.should eql("00000000004042-8")
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = 61900
    boleto_novo.nosso_numero_boleto.should eql("00000000061900-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = 719
    boleto_novo.nosso_numero_boleto.should eql("00000000000719-6")
    boleto_novo.nosso_numero_dv.should eql(6)
  end

  it "Montar agencia_conta_boleto" do
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    boleto_novo = Brcobranca::Boleto::Unibanco.new(@valid_attributes)

    boleto_novo.agencia_conta_boleto.should eql("0123 / 0100618-5")
    boleto_novo.agencia = "0548"
    boleto_novo.conta_corrente = "1448"
    boleto_novo.agencia_conta_boleto.should eql("0548 / 0001448-6")
  end

  it "Busca logotipo do banco" do
    boleto_novo = Brcobranca::Boleto::Unibanco.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it "Gerar boleto nos formatos válidos com método to_" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "1803029901"
    @valid_attributes[:carteira] = "4"
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    boleto_novo = Brcobranca::Boleto::Unibanco.new(@valid_attributes)

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
    @valid_attributes[:numero_documento] = "1803029901"
    @valid_attributes[:carteira] = "4"
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    boleto_novo = Brcobranca::Boleto::Unibanco.new(@valid_attributes)

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
