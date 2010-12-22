# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Brcobranca::Boleto::Caixa do #:nodoc:[all]
  
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
      :cedente => "Túlio Ornelas",
      :documento_cedente => "200874000687",
      :sacado => "Ana Carolina Mascarenhas",
      :sacado_documento => "93463665751",
      :agencia => "1565",
      :conta_corrente => "13877",
      :convenio => "87000000414",
      :numero_documento => "1"
    }
  end
  
  it "Criar nova instancia com atributos padrões" do
    boleto_novo = Brcobranca::Boleto::Caixa.new
    boleto_novo.banco.should eql("104")
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
    boleto_novo.carteira.should eql(Brcobranca::Boleto::Caixa::CARTEIRAS[14])
    boleto_novo.codigo_servico.should be_false
  end
  
  it "Criar nova instancia com atributos válidos" do
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    boleto_novo.banco.should eql("104")
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
    boleto_novo.cedente.should eql("Túlio Ornelas")
    boleto_novo.documento_cedente.should eql("200874000687")
    boleto_novo.sacado.should eql("Ana Carolina Mascarenhas")
    boleto_novo.sacado_documento.should eql("93463665751")
    boleto_novo.conta_corrente.should eql("0013877")
    boleto_novo.agencia.should eql("1565")
    boleto_novo.convenio.should eql("87000000414")
    boleto_novo.numero_documento.should eql("8200000001")
    boleto_novo.carteira.should eql(Brcobranca::Boleto::Caixa::CARTEIRAS[14])
    boleto_novo.codigo_servico.should be_false
  end
  
  it "Montar código de barras para convenio de 11 digitos e nosso número de 10" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql("8200000001156587000000414")  
    boleto_novo.codigo_barras.should eql("10494376900000135008200000001156587000000414")
    boleto_novo.codigo_barras.linha_digitavel.should eql("10498.20002 00001.156587 70000.004146 4 37690000013500")
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.nosso_numero_dv.should eql(3)

    @valid_attributes[:dias_vencimento] = 1
    @valid_attributes[:numero_documento] = "2"
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)

    boleto_novo.codigo_barras_segunda_parte.should eql("8200000002156587000000414")  
    boleto_novo.codigo_barras.should eql("10491377000000135008200000002156587000000414")
    boleto_novo.codigo_barras.linha_digitavel.should eql("10498.20002 00002.156586 70000.004146 1 37700000013500")
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.nosso_numero_dv.should eql(1)
  end

  it "Não permitir gerar boleto com atributos inválidos" do
    boleto_novo = Brcobranca::Boleto::Caixa.new
    lambda { boleto_novo.codigo_barras }.should raise_error(Brcobranca::BoletoInvalido)
    boleto_novo.errors.count.should eql(3)
  end

  it "Montar nosso_numero_boleto" do
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    boleto_novo.numero_documento = "1"
    boleto_novo.nosso_numero_boleto.should eql("82000000013")
    boleto_novo.nosso_numero_dv.should eql(3)
    boleto_novo.numero_documento = "2"
    boleto_novo.nosso_numero_boleto.should eql("82000000021")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = "3"
    boleto_novo.nosso_numero_boleto.should eql("82000000031")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = 10
    boleto_novo.nosso_numero_boleto.should eql("82000000102")
    boleto_novo.nosso_numero_dv.should eql(2)
    boleto_novo.numero_documento = 20
    boleto_novo.nosso_numero_boleto.should eql("82000000201")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = 30
    boleto_novo.nosso_numero_boleto.should eql("82000000307")
    boleto_novo.nosso_numero_dv.should eql(7)
  end

  it "Montar agencia_conta_boleto" do
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
                   
    boleto_novo.agencia_conta_boleto.should eql("1565/0013877-0")
    boleto_novo.agencia = "1314"
    boleto_novo.agencia_conta_boleto.should eql("1314/0013877-0")
    boleto_novo.agencia = "2030"
    boleto_novo.conta_corrente = "067164"
    boleto_novo.agencia_conta_boleto.should eql("2030/0067164-9")
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
    @valid_attributes[:numero_documento] = "77700168"
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
    @valid_attributes[:numero_documento] = "77700168"
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
     
  it 'deveria possuir o campo livre igual a segunda parte do codigo de barras' do
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    boleto_novo.codigo_barras_segunda_parte.should eql(boleto_novo.campo_livre)
  end
  
  it 'deveria retornar a carteira sempre com a sigla' do
    boleto_novo = Brcobranca::Boleto::Caixa.new :carteira => 14
    boleto_novo.carteira.should eql(Brcobranca::Boleto::Caixa::CARTEIRAS[14])
    
    boleto_novo = Brcobranca::Boleto::Caixa.new :carteira => 'SR'
    boleto_novo.carteira.should eql(Brcobranca::Boleto::Caixa::CARTEIRAS[14])
  end
  
  it 'deveria retornar o numero_documento com base na carteira' do
    @valid_attributes[:numero_documento] = "1"
    @valid_attributes[:carteira] = 14
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    
    boleto_novo.numero_documento.should eql("8200000001")
    
    @valid_attributes[:carteira] = 11
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    lambda { boleto_novo.numero_documento }.should raise_error(Brcobranca::NaoImplementado)
    
    @valid_attributes[:carteira] = 12
    boleto_novo = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    lambda { boleto_novo.numero_documento }.should raise_error(Brcobranca::NaoImplementado)
  end
  
  it "deveria calcular o banco_dv corretamente, com base no modulo10" do
    boleto_novo = Brcobranca::Boleto::Caixa.new
    boleto_novo.banco.should eql("104")
    boleto_novo.banco_dv.should eql(0)
    boleto_novo.banco_dv.should eql(boleto_novo.banco.modulo10)
  end
  
end




































