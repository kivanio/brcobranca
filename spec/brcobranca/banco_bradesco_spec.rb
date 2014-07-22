# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Brcobranca::Boleto::Bradesco do
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
      :cedente => "Kivanio Barbosa",
      :documento_cedente => "12345678912",
      :sacado => "Claudio Pozzebom",
      :sacado_documento => "12345678900",
      :agencia => "4042",
      :conta_corrente => "61900",
      :convenio => 12387989,
      :numero_documento => "777700168"
    }
  end

  it "Criar nova instancia com atributos padrões" do
    boleto_novo = Brcobranca::Boleto::Bradesco.new
    expect(boleto_novo.banco).to eql("237")
    expect(boleto_novo.especie_documento).to eql("DM")
    expect(boleto_novo.especie).to eql("R$")
    expect(boleto_novo.moeda).to eql("9")
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.dias_vencimento).to eql(1)
    expect(boleto_novo.data_vencimento).to eql(Date.today + 1)
    expect(boleto_novo.aceite).to eql("S")
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    expect(boleto_novo.carteira).to eql("06")

  end

  it "Criar nova instancia com atributos válidos" do
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)
    expect(boleto_novo.banco).to eql("237")
    expect(boleto_novo.especie_documento).to eql("DM")
    expect(boleto_novo.especie).to eql("R$")
    expect(boleto_novo.moeda).to eql("9")
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.dias_vencimento).to eql(1)
    expect(boleto_novo.data_vencimento).to eql(Date.today + 1)
    expect(boleto_novo.aceite).to eql("S")
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    expect(boleto_novo.cedente).to eql("Kivanio Barbosa")
    expect(boleto_novo.documento_cedente).to eql("12345678912")
    expect(boleto_novo.sacado).to eql("Claudio Pozzebom")
    expect(boleto_novo.sacado_documento).to eql("12345678900")
    expect(boleto_novo.conta_corrente).to eql("0061900")
    expect(boleto_novo.agencia).to eql("4042")
    expect(boleto_novo.convenio).to eql(12387989)
    expect(boleto_novo.numero_documento).to eql("00777700168")
    expect(boleto_novo.carteira).to eql("06")
  end

  it "Montar código de barras para carteira número 06" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "75896452"
    @valid_attributes[:conta_corrente] = "0403005"
    @valid_attributes[:agencia] = "1172"
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql("1172060007589645204030050")
    expect(boleto_novo.codigo_barras).to eql("23795422300002952951172060007589645204030050")
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql("23791.17209 60007.589645 52040.300502 5 42230000295295")
  end

  it "Montar código de barras para carteira número 03" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:dias_vencimento] = 1
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:numero_documento] = "777700168"
    @valid_attributes[:conta_corrente] = "61900"
    @valid_attributes[:agencia] = "4042"
    @valid_attributes[:carteira] = "03"
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql("4042030077770016800619000")
    expect(boleto_novo.codigo_barras).to eql("23791377000000135004042030077770016800619000")
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql("23794.04201 30077.770011 68006.190000 1 37700000013500")
  end

  it "Não permitir gerar boleto com atributos inválido" do
    boleto_novo = Brcobranca::Boleto::Bradesco.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eql(3)
  end

  it "Montar nosso_numero_boleto" do
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    boleto_novo.numero_documento = "4042"
    boleto_novo.carteira = "06"
    expect(boleto_novo.nosso_numero_boleto).to eql("06/00000004042-8")
    expect(boleto_novo.nosso_numero_dv).to eql(8)
    boleto_novo.numero_documento = "61900"
    boleto_novo.carteira = "05"
    expect(boleto_novo.nosso_numero_boleto).to eql("05/00000061900-0")
    expect(boleto_novo.nosso_numero_dv).to eql(0)
    boleto_novo.numero_documento = "0719"
    boleto_novo.carteira = "07"
    expect(boleto_novo.nosso_numero_boleto).to eql("07/00000000719-6")
    expect(boleto_novo.nosso_numero_dv).to eql(6)
    boleto_novo.numero_documento = 4042
    boleto_novo.carteira = "06"
    expect(boleto_novo.nosso_numero_boleto).to eql("06/00000004042-8")
    expect(boleto_novo.nosso_numero_dv).to eql(8)
    boleto_novo.numero_documento = 61900
    boleto_novo.carteira = "05"
    expect(boleto_novo.nosso_numero_boleto).to eql("05/00000061900-0")
    expect(boleto_novo.nosso_numero_dv).to eql(0)
    boleto_novo.numero_documento = 719
    boleto_novo.carteira = "07"
    expect(boleto_novo.nosso_numero_boleto).to eql("07/00000000719-6")
    expect(boleto_novo.nosso_numero_dv).to eql(6)
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql("4042-8 / 0061900-0")
    boleto_novo.agencia = "0719"
    expect(boleto_novo.agencia_conta_boleto).to eql("0719-6 / 0061900-0")
    boleto_novo.agencia = "0548"
    boleto_novo.conta_corrente = "1448"
    expect(boleto_novo.agencia_conta_boleto).to eql("0548-7 / 0001448-6")
  end

  it "Busca logotipo do banco" do
    boleto_novo = Brcobranca::Boleto::Bradesco.new
    expect(File.exist?(boleto_novo.logotipo)).to be_truthy
    expect(File.stat(boleto_novo.logotipo).zero?).to be_falsey
  end

  it "Gerar boleto nos formatos válidos com método to_" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "75896452"
    @valid_attributes[:conta_corrente] = "0403005"
    @valid_attributes[:agencia] = "1172"
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    %w| pdf jpg tif png |.each do |format|
      file_body=boleto_novo.send("to_#{format}".to_sym)
      tmp_file=Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end

  it "Gerar boleto nos formatos válidos" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "75896452"
    @valid_attributes[:conta_corrente] = "0403005"
    @valid_attributes[:agencia] = "1172"
    boleto_novo = Brcobranca::Boleto::Bradesco.new(@valid_attributes)

    %w| pdf jpg tif png |.each do |format|
      file_body=boleto_novo.to(format)
      tmp_file=Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end

end
