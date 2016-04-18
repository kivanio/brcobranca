# -*- encoding: utf-8 -*-
require "spec_helper"

RSpec.describe Brcobranca::Boleto::Sicoob do #:nodoc:[all]
  let(:valid_attributes) {
    {
      data_documento: Date.parse("2016-02-16"),
      data_vencimento: Date.parse("2016-02-18"),
      aceite: "N",
      valor: 50.0,
      cedente: "Kivanio Barbosa",
      documento_cedente: "12345678912",
      sacado: "Claudio Pozzebom",
      sacado_documento: "12345678900",
      agencia: "4327",
      conta_corrente: "417270",
      convenio: '229385',
      numero_documento: "2"
    }
  }

  it "Criar nova instancia com atributos padrões" do
    boleto_novo = described_class.new

    expect(boleto_novo.banco).to eql("756")
    expect(boleto_novo.especie_documento).to eql("DM")
    expect(boleto_novo.especie).to eql("R$")
    expect(boleto_novo.moeda).to eql("9")
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.data_vencimento).to eql(Date.today)
    expect(boleto_novo.aceite).to eql("S")
    expect(boleto_novo.quantidade).to eql("001")
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    expect(boleto_novo.carteira).to eql("1")
    expect(boleto_novo.codigo_servico).to be_falsey
  end

  it "Criar nova instancia com atributos válidos" do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.banco).to eql("756")
    expect(boleto_novo.especie_documento).to eql("DM")
    expect(boleto_novo.especie).to eql("R$")
    expect(boleto_novo.moeda).to eql("9")
    expect(boleto_novo.data_documento).to eql(Date.parse("2016-02-16"))
    expect(boleto_novo.data_vencimento).to eql(Date.parse("2016-02-18"))
    expect(boleto_novo.aceite).to eql("N")
    expect(boleto_novo.quantidade).to eql("001")
    expect(boleto_novo.valor).to eql(50.0)
    expect(boleto_novo.valor_documento).to eql(50.0)
    expect(boleto_novo.local_pagamento).to eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    expect(boleto_novo.cedente).to eql("Kivanio Barbosa")
    expect(boleto_novo.documento_cedente).to eql("12345678912")
    expect(boleto_novo.sacado).to eql("Claudio Pozzebom")
    expect(boleto_novo.sacado_documento).to eql("12345678900")
    expect(boleto_novo.conta_corrente).to eql("0417270")
    expect(boleto_novo.agencia).to eql("4327")
    expect(boleto_novo.convenio).to eql("0229385")
    expect(boleto_novo.numero_documento).to eql("0000002")
    expect(boleto_novo.carteira).to eql("1")
    expect(boleto_novo.codigo_servico).to be_falsey
  end

  it "Não permitir gerar boleto com atributos inválido" do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eql(3)
  end

  it "Validar a presença do campo variacao" do
    @valid_attributes[:variacao] = ""
    boleto_novo = described_class.new(@valid_attributes)
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to eql(1)
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql("4327 / 0229385")
  end

  it "Montar nosso numero dv" do
    valid_attributes[:numero_documento] = "1"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(7)

    valid_attributes[:numero_documento] = "2"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(4)
    
    valid_attributes[:numero_documento] = "3"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(1)
    
    valid_attributes[:numero_documento] = "4"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(9)
    
    valid_attributes[:numero_documento] = "5"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(6)
    
    valid_attributes[:numero_documento] = "6"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(3)
    
    valid_attributes[:numero_documento] = "7"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(0)

    valid_attributes[:numero_documento] = "8"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(8)
    
    valid_attributes[:numero_documento] = "9"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(5)
    
    valid_attributes[:numero_documento] = "10"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(3)
    
    valid_attributes[:numero_documento] = "11"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(0)
    
    valid_attributes[:numero_documento] = "12"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(8)
    
    valid_attributes[:numero_documento] = "13"
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_dv).to eql(5)
  end


  it 'Montar código de barras' do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('75691.43279 01022.938508 00000.240010 2 67080000005000')
    expect(boleto_novo.codigo_barras_segunda_parte).to eql('1432701022938500000024001')
    expect(boleto_novo.codigo_barras_segunda_parte.size).to eql(25)

  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it "Gerar boleto nos formatos válidos com método to_" do
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
