# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Brcobranca::Boleto::Caixa do #:nodoc:[all]
  
  before do
    @valid_attributes = {
      :especie_documento => 'DM',
      :moeda => '9',
      :data_documento => Date.today,
      :dias_vencimento => 1,
      :aceite => 'S',
      :quantidade => 1,
      :valor => 10.00,
      :beneficiario => 'PREFEITURA MUNICIPAL DE VILHENA',
      :documento_beneficiario => '04092706000181',
      :pagador => 'João Paulo Barbosa',
      :pagador_documento => '77777777777',
      :agencia => '1825',
      :conta_corrente => '0000528',
      :convenio => '245274',
      :numero_documento => '000000000000001'
    }
  end
  
  it 'Criar nova instância com atributos padrões' do
    boleto_novo = Brcobranca::Boleto::Caixa.new
    boleto_novo.banco.should eql('104')
    boleto_novo.banco_dv.should eql('0')
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
    boleto_novo.local_pagamento.should eql('PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE')
    boleto_novo.codigo_servico.should be_false
    carteira = "#{Brcobranca::Boleto::Caixa::MODALIDADE_COBRANCA[:sem_registro]}" <<
               "#{Brcobranca::Boleto::Caixa::EMISSAO_BOLETO[:beneficiario]}"
    boleto_novo.carteira.should eql(carteira)
  end
  
  it "Criar nova instancia com atributos válidos" do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes
    @valid_attributes.keys.each do |key|
      boleto_novo.send(key).should eql(@valid_attributes[key])
    end
    boleto_novo.should be_valid
  end

  it 'Gerar o dígito verificador do convênio' do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes
    boleto_novo.convenio_dv.should_not be_nil
    boleto_novo.convenio_dv.should == '0'
  end
  
  it "Gerar o código de barras" do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes
    lambda { boleto_novo.codigo_barras }.should_not raise_error
    boleto_novo.codigo_barras_segunda_parte.should_not be_blank
    boleto_novo.codigo_barras_segunda_parte.should eql('2452740000200040000000010')
  end

  it "Não permitir gerar boleto com atributos inválidos" do
    boleto_novo = Brcobranca::Boleto::Caixa.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
  end

  it 'Tamanho do número de convênio deve ser de 6 dígitos' do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes.merge(:convenio => '1234567')
    boleto_novo.should_not be_valid
  end

  it 'Número do convênio deve ser preenchido com zeros à esquerda quando menor que 6 dígitos' do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes.merge(:convenio => '12345')
    boleto_novo.convenio.should == '012345'
    boleto_novo.should be_valid
  end
  
  it 'Tamanho da carteira deve ser de 2 dígitos' do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes.merge(:carteira => '145')
    boleto_novo.should_not be_valid

    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes.merge(:carteira => '1')
    boleto_novo.should_not be_valid
  end

  it 'Tamanho do número documento deve ser de 15 dígitos' do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes.merge(:numero_documento => '1234567891234567')
    boleto_novo.should_not be_valid
  end

  it 'Número do documento deve ser preenchido com zeros à esquerda quando menor que 15 dígitos' do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes.merge(:numero_documento => '1')
    boleto_novo.numero_documento.should == '000000000000001'
    boleto_novo.should be_valid
  end

  it "Montar nosso_numero_boleto" do
    boleto_novo = Brcobranca::Boleto::Caixa.new @valid_attributes
    boleto_novo.nosso_numero_boleto.should == "#{boleto_novo.carteira}" << 
                                              "#{boleto_novo.numero_documento}" <<
                                              "-#{boleto_novo.nosso_numero_dv}"
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)

    boleto_novo.agencia_conta_boleto.should eql("1825/245274-0")

    boleto_novo.convenio = "123456"
    boleto_novo.agencia_conta_boleto.should eql("1825/123456-0")

    boleto_novo.agencia = "2030"
    boleto_novo.convenio = "654321"
    boleto_novo.agencia_conta_boleto.should eql("2030/654321-9")
  end
  
  it "Busca logotipo do banco" do
    boleto_novo = Brcobranca::Boleto::Caixa.new
    File.exist?(boleto_novo.logotipo).should be_true
    File.stat(boleto_novo.logotipo).zero?.should be_false
  end
  
  it "Gerar boleto nos formatos válidos com método to_" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 2
    @valid_attributes[:numero_documento] = "000000077700168"
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
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
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 2
    @valid_attributes[:numero_documento] = "000000077700168"
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
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
