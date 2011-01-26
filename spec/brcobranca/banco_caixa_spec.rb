# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'tempfile'

describe BancoCaixa do #:nodoc:[all]

  before do
    @valid_attributes = {
      :especie_documento => 'DM',
      :moeda => '9',
      :data_documento => Date.today,
      :dias_vencimento => 1,
      :aceite => 'S',
      :quantidade => 1,
      :valor => 1.23,
      :local_pagamento => 'QUALQUER BANCO ATÉ O VENCIMENTO',
      :cedente => 'Túlio Ornelas',
      :documento_cedente => '200874000687',
      :sacado => 'Ana Carolina Mascarenhas',
      :sacado_documento => '93463665751',
      :agencia => '1565',
      :conta_corrente => '0013877',
      :convenio => '100000',
      :numero_documento => '123456789123456'
    }
  end
  
  it 'Criar nova instância com atributos padrões' do
    boleto_novo = BancoCaixa.new
    boleto_novo.banco.should eql('104')
    boleto_novo.banco_dv.should eql('0')
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
    boleto_novo.codigo_servico.should be_false
    carteira = "#{BancoCaixa::MODALIDADE_COBRANCA[:sem_registro]}" <<
               "#{BancoCaixa::EMISSAO_BOLETO[:cedente]}"
    boleto_novo.carteira.should eql(carteira)
  end
  
  it "Criar nova instancia com atributos válidos" do
    boleto_novo = BancoCaixa.new @valid_attributes
    @valid_attributes.keys.each do |key|
      boleto_novo.send(key).should eql(@valid_attributes[key])
    end
  end

  it 'Gerar o dígito verificador do convênio' do
    boleto_novo = BancoCaixa.new @valid_attributes
    boleto_novo.convenio_dv.should_not be_nil
    boleto_novo.convenio_dv.should == '4'
  end
  
  it "Gerar o código de barras" do
    boleto_novo = BancoCaixa.new @valid_attributes
    lambda { boleto_novo.codigo_barras }.should_not raise_error
    boleto_novo.codigo_barras_segunda_parte.should_not be_nil
    boleto_novo.codigo_barras_segunda_parte.should eql('1000004123245647891234568')
  end

  it "Não permitir gerar boleto com atributos inválidos" do
    boleto_novo = BancoCaixa.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
  end

  it 'Número do convênio deve ser preenchido com zeros à esquerda quando menor que 6 dígitos' do
    boleto_novo = BancoCaixa.new @valid_attributes.merge(:convenio => '12345')
    boleto_novo.convenio.should == '012345'
    boleto_novo = BancoCaixa.new @valid_attributes.merge(:convenio => 12345)
    boleto_novo.convenio.should == '012345'
  end

  it 'Número do documento deve ser preenchido com zeros à esquerda quando menor que 15 dígitos' do
    boleto_novo = BancoCaixa.new @valid_attributes.merge(:numero_documento => '1')
    boleto_novo.numero_documento.should == '000000000000001'
    boleto_novo = BancoCaixa.new @valid_attributes.merge(:numero_documento => 1)
    boleto_novo.numero_documento.should == '000000000000001'
  end

  it "Montar nosso_numero_boleto" do
    boleto_novo = BancoCaixa.new @valid_attributes
    boleto_novo.nosso_numero_boleto.should == "#{boleto_novo.carteira}" << 
                                              "#{boleto_novo.numero_documento}" <<
                                              "-#{boleto_novo.nosso_numero_dv}"
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = BancoCaixa.new(@valid_attributes)
                   
    boleto_novo.agencia_conta_boleto.should eql("1565/100000-4")

    boleto_novo.convenio = "123456"
    boleto_novo.agencia_conta_boleto.should eql("1565/123456-1")

    boleto_novo.agencia = "2030"
    boleto_novo.convenio = "654321"
    boleto_novo.agencia_conta_boleto.should eql("2030/654321-9")
  end
  
  it "Busca logotipo do banco" do
    boleto_novo = BancoCaixa.new
    File.exist?(boleto_novo.monta_logo).should be_true
    File.stat(boleto_novo.monta_logo).zero?.should be_false
  end
  
  it "Gerar boleto nos formatos válidos" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 2
    @valid_attributes[:numero_documento] = "77700168"
    boleto_novo = BancoCaixa.new(@valid_attributes)
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

  it 'Gerar um lote de boletos' do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 2
    @valid_attributes[:numero_documento] = "77700168"
    boletos = []
    boletos << BancoCaixa.new(@valid_attributes)
    boletos << BancoCaixa.new(@valid_attributes)
    
    file_body = Brcobranca::Boleto::Base.imprimir_lista(boletos)
    tmp_file=Tempfile.new("foobar.pdf")
    tmp_file.puts file_body
    tmp_file.close
    File.exist?(tmp_file.path).should be_true
    File.stat(tmp_file.path).zero?.should be_false
    File.delete(tmp_file.path).should eql(1)
    File.exist?(tmp_file.path).should be_false
  end

end
