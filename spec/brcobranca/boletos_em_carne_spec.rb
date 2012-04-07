# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Boletos em Carne" do #:nodoc:[all]

  before(:each) do
    @valid_attributes = {
      :especie_documento => "DM",
      :moeda => "9",
      :data_documento => Date.today,
      :dias_vencimento => 1,
      :aceite => "S",
      :quantidade => 1,
      :valor => 1.0,
      :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO",
      :cedente => "Kivanio Barbosa",
      :documento_cedente => "12345678912",
      :sacado => "Claudio Pozzebom",
      :sacado_documento => "12345678900",
      :agencia => "4042",
      :conta_corrente => "61900",
      :convenio => "123456",
      :numero_documento => "777700168",
      :instrucao1 => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
      :instrucao2 => "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
      :instrucao3 => "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC",
      :instrucao4 => "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
      :instrucao5 => "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
      :instrucao6 => "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" ,
      :sacado_endereco => "Av. Rubéns de Mendonça, 157 - 78008-000 - Cuiabá/MT"
    }
  end

  it "imprimir boletos em carne" do
    boleto_1 = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    boleto_2 = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    boleto_3 = Brcobranca::Boleto::Caixa.new(@valid_attributes)
    boleto_4 = Brcobranca::Boleto::Caixa.new(@valid_attributes)

    boletos = [boleto_1, boleto_2, boleto_3, boleto_4]

    %w| pdf jpg tif png ps |.each do |format|
      file_body=Brcobranca::Boleto::Base.carne(boletos, {:formato => "#{format}".to_sym})
      tmp_file=File.new("/tmp/foobar." << format, "w+")
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      #File.stat(tmp_file.path).zero?.should be_false
      #File.delete(tmp_file.path).should eql(1)
      #File.exist?(tmp_file.path).should be_false
    end
  end

end