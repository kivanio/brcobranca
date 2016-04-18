# -*- encoding: utf-8 -*-
require "spec_helper"

RSpec.describe Brcobranca::Boleto::Banestes do #:nodoc:[all]

  let(:valid_attributes) { {
    data_vencimento: Date.parse("2015-06-26"),
    valor: 1278.90,
    cedente: "Kivanio Barbosa",
    documento_cedente: "12345678912",
    sacado: "Claudio Pozzebom",
    sacado_documento: "12345678900",
    agencia: "274",
    conta_corrente: "14542047",
    numero_documento: "69240101"
  } }

  it "Criar nova instancia com atributos padrões" do
    boleto_novo = described_class.new

    expect(boleto_novo.banco).to eql("021")
    expect(boleto_novo.especie_documento).to eql("DM")
    expect(boleto_novo.especie).to eql("R$")
    expect(boleto_novo.moeda).to eql("9")
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql("S")
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    expect(boleto_novo.carteira).to eql("11")
  end

  it "Criar nova instancia com atributos válidos" do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.banco).to eql("021")
    expect(boleto_novo.especie_documento).to eql("DM")
    expect(boleto_novo.especie).to eql("R$")
    expect(boleto_novo.moeda).to eql("9")
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.parse("2015-06-26"))
    expect(boleto_novo.aceite).to eql("S")
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(1278.9)
    expect(boleto_novo.valor_documento).to eql(1278.9)
    expect(boleto_novo.local_pagamento).to eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    expect(boleto_novo.cedente).to eql("Kivanio Barbosa")
    expect(boleto_novo.documento_cedente).to eql("12345678912")
    expect(boleto_novo.sacado).to eql("Claudio Pozzebom")
    expect(boleto_novo.sacado_documento).to eql("12345678900")
    expect(boleto_novo.conta_corrente).to eql("00014542047")
    expect(boleto_novo.agencia).to eql("0274")
    expect(boleto_novo.numero_documento).to eql("69240101")
    expect(boleto_novo.nosso_numero_boleto).to eql("69240101-68")
    expect(boleto_novo.carteira).to eql("11")
    expect(boleto_novo.codigo_barras).to eql("02191647100001278906924010100014542047202198")
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql("02196.92407 10100.014546 20472.021987 1 64710000127890")
  end

  it "Não permitir gerar boleto com atributos inválido" do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eql(3)
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql("0274 / 00014542047")
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it "Gerar boleto nos formatos válidos com método to_" do
    valid_attributes[:valor] = 135.00
    valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    valid_attributes[:numero_documento] = "240"

    boleto_novo = described_class.new(valid_attributes)

    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.send("to_#{format}".to_sym)
      tmp_file = Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close

      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end

  it "Gerar boleto nos formatos válidos" do
    valid_attributes[:valor] = 135.00
    valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    valid_attributes[:numero_documento] = "240"

    boleto_novo = described_class.new(valid_attributes)

    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.to(format)
      tmp_file = Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close

      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end
end
