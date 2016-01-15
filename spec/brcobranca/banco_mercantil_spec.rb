# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Brcobranca::Boleto::Mercantil do
  before(:each) do
    @valid_attributes = {
      data_documento: Date.new(2012, 11, 15),
      dias_vencimento: 0,
      aceite: "N",
      valor: 1.00,
      local_pagamento: "nota_fiscal",
      cedente: "Thauan Zatta",
      documento_cedente: "00.981.069/000658",
      sacado: "Lésio Pinheiro",
      sacado_documento: "",
      agencia: "0165",
      conta_corrente: "25179",
      numero_documento: "82475",
      sacado_endereco: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor"
    }
  end

  it "deve conter logotipo do banco" do
    boleto_novo = Brcobranca::Boleto::Mercantil.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end

  it "deve gerar nosso numero para o boleto com o digito verificador" do
    boleto_novo = Brcobranca::Boleto::Mercantil.new(@valid_attributes)
    boleto_novo.nosso_numero_boleto.should eql("0000082475-4")
  end

  it "deve gerar numero de codigo de barras" do
    boleto_novo = Brcobranca::Boleto::Mercantil.new(@valid_attributes)
    boleto_novo.codigo_barras.linha_digitavel_mercantil.should eql("38990.16509 00008.247546 00002.517928 1 55180000000100")
  end

  it "deve gerar codigo de barras mesmo que a conta corrente possua menos digitos" do
    @valid_attributes[:conta_corrente] = "25179"
    @valid_attributes[:numero_documento] = "82475"
    boleto_novo = Brcobranca::Boleto::Mercantil.new(@valid_attributes)
    boleto_novo.codigo_barras.linha_digitavel_mercantil.should eql("38990.16509 00008.247546 00002.517928 1 55180000000100")
  end

  it "não deve gerar boleto com attributos invalidos" do
    @valid_attributes[:conta_corrente] = nil
    @valid_attributes[:agencia] = nil
    @valid_attributes[:numero_documento] = nil
    boleto_novo = Brcobranca::Boleto::Mercantil.new(@valid_attributes)
    boleto_novo.should_not be_valid
  end
end
