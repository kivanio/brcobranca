require File.dirname(__FILE__) + '/../spec_helper.rb'

module Brcobranca #:nodoc:[all]
  module Boleto #:nodoc:[all]
    describe Base do
      before(:each) do
        @valid_attributes = {
          :especie_documento => "DM",
          :moeda => "9",
          :banco => "001",
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

      it "should create a new default instance" do
        boleto_novo = Brcobranca::Boleto::Base.new
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
        boleto_novo.should be_instance_of(Brcobranca::Boleto::Base)
      end

      it "should create a new instance given valid attributes" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.banco.should eql("001")
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
        boleto_novo.cedente.should eql("Kivanio Barbosa")
        boleto_novo.documento_cedente.should eql("12345678912")
        boleto_novo.sacado.should eql("Claudio Pozzebom")
        boleto_novo.sacado_documento.should eql("12345678900")
        boleto_novo.conta_corrente.should eql("61900")
        boleto_novo.agencia.should eql("4042")
        boleto_novo.convenio.should eql(12387989)
        boleto_novo.numero_documento.should eql("777700168")
        boleto_novo.should be_instance_of(Brcobranca::Boleto::Base)
      end

      it "should calculate bando_dv" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.banco = "85068014982"
        boleto_novo.banco_dv.should eql(9)
        boleto_novo.banco = "05009401448"
        boleto_novo.banco_dv.should eql(1)
        boleto_novo.banco = "12387987777700168"
        boleto_novo.banco_dv.should eql(2)
        boleto_novo.banco = "4042"
        boleto_novo.banco_dv.should eql(8)
        boleto_novo.banco = "61900"
        boleto_novo.banco_dv.should eql(0)
        boleto_novo.banco = "0719"
        boleto_novo.banco_dv.should eql(6)
        boleto_novo.banco = 85068014982
        boleto_novo.banco_dv.should eql(9)
        boleto_novo.banco = 5009401448
        boleto_novo.banco_dv.should eql(1)
        boleto_novo.banco = 12387987777700168
        boleto_novo.banco_dv.should eql(2)
        boleto_novo.banco = 4042
        boleto_novo.banco_dv.should eql(8)
        boleto_novo.banco = 61900
        boleto_novo.banco_dv.should eql(0)
        boleto_novo.banco = 719
        boleto_novo.banco_dv.should eql(6)
      end

      it "should calculate agencia_dv" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.agencia = "85068014982"
        boleto_novo.agencia_dv.should eql(9)
        boleto_novo.agencia = "05009401448"
        boleto_novo.agencia_dv.should eql(1)
        boleto_novo.agencia = "12387987777700168"
        boleto_novo.agencia_dv.should eql(2)
        boleto_novo.agencia = "4042"
        boleto_novo.agencia_dv.should eql(8)
        boleto_novo.agencia = "61900"
        boleto_novo.agencia_dv.should eql(0)
        boleto_novo.agencia = "0719"
        boleto_novo.agencia_dv.should eql(6)
        boleto_novo.agencia = 85068014982
        boleto_novo.agencia_dv.should eql(9)
        boleto_novo.agencia = 5009401448
        boleto_novo.agencia_dv.should eql(1)
        boleto_novo.agencia = 12387987777700168
        boleto_novo.agencia_dv.should eql(2)
        boleto_novo.agencia = 4042
        boleto_novo.agencia_dv.should eql(8)
        boleto_novo.agencia = 61900
        boleto_novo.agencia_dv.should eql(0)
        boleto_novo.agencia = 719
        boleto_novo.agencia_dv.should eql(6)
      end

      it "should calculate conta_corrente_dv" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.conta_corrente = "85068014982"
        boleto_novo.conta_corrente_dv.should eql(9)
        boleto_novo.conta_corrente = "05009401448"
        boleto_novo.conta_corrente_dv.should eql(1)
        boleto_novo.conta_corrente = "12387987777700168"
        boleto_novo.conta_corrente_dv.should eql(2)
        boleto_novo.conta_corrente = "4042"
        boleto_novo.conta_corrente_dv.should eql(8)
        boleto_novo.conta_corrente = "61900"
        boleto_novo.conta_corrente_dv.should eql(0)
        boleto_novo.conta_corrente = "0719"
        boleto_novo.conta_corrente_dv.should eql(6)
        boleto_novo.conta_corrente = 85068014982
        boleto_novo.conta_corrente_dv.should eql(9)
        boleto_novo.conta_corrente = 5009401448
        boleto_novo.conta_corrente_dv.should eql(1)
        boleto_novo.conta_corrente = 12387987777700168
        boleto_novo.conta_corrente_dv.should eql(2)
        boleto_novo.conta_corrente = 4042
        boleto_novo.conta_corrente_dv.should eql(8)
        boleto_novo.conta_corrente = 61900
        boleto_novo.conta_corrente_dv.should eql(0)
        boleto_novo.conta_corrente = 719
        boleto_novo.conta_corrente_dv.should eql(6)
      end

      it "should calculate nosso_numero_dv" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.numero_documento = "85068014982"
        boleto_novo.nosso_numero.should eql("85068014982")
        boleto_novo.nosso_numero_dv.should eql(9)
        boleto_novo.numero_documento = "05009401448"
        boleto_novo.nosso_numero_dv.should eql(1)
        boleto_novo.numero_documento = "12387987777700168"
        boleto_novo.nosso_numero_dv.should eql(2)
        boleto_novo.numero_documento = "4042"
        boleto_novo.nosso_numero_dv.should eql(8)
        boleto_novo.numero_documento = "61900"
        boleto_novo.nosso_numero_dv.should eql(0)
        boleto_novo.numero_documento = "0719"
        boleto_novo.nosso_numero_dv.should eql(6)
        boleto_novo.numero_documento = 85068014982
        boleto_novo.nosso_numero_dv.should eql(9)
        boleto_novo.numero_documento = 5009401448
        boleto_novo.nosso_numero_dv.should eql(1)
        boleto_novo.numero_documento = 12387987777700168
        boleto_novo.nosso_numero_dv.should eql(2)
        boleto_novo.numero_documento = 4042
        boleto_novo.nosso_numero_dv.should eql(8)
        boleto_novo.numero_documento = 61900
        boleto_novo.nosso_numero_dv.should eql(0)
        boleto_novo.numero_documento = 719
        boleto_novo.nosso_numero_dv.should eql(6)
      end

      it "should return document value in float" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.quantidade = 1
        boleto_novo.valor = 1
        boleto_novo.valor_documento.should eql(1.0)
        boleto_novo.quantidade = 1
        boleto_novo.valor = 1.0
        boleto_novo.valor_documento.should eql(1.0)
        boleto_novo.quantidade = 100
        boleto_novo.valor = 1
        boleto_novo.valor_documento.should eql(100.0)
        boleto_novo.quantidade = 1
        boleto_novo.valor = 1.2
        boleto_novo.valor_documento.should eql(1.2)
        boleto_novo.quantidade = 1
        boleto_novo.valor = 135.43
        boleto_novo.valor_documento.should eql(135.43)
        boleto_novo.quantidade = "gh"
        boleto_novo.valor = 135.43
        boleto_novo.valor_documento.should eql(0)
      end

      it "should return data_vencimento" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.data_documento = Date.parse "2008-02-01"
        boleto_novo.dias_vencimento = 1
        boleto_novo.data_vencimento.to_s.should eql("2008-02-02")
        boleto_novo.data_vencimento.should eql(Date.parse("2008-02-02"))
        boleto_novo.data_documento = Date.parse "2008-02-02"
        boleto_novo.dias_vencimento = 28
        boleto_novo.data_vencimento.to_s.should eql("2008-03-01")
        boleto_novo.data_vencimento.should eql(Date.parse("2008-03-01"))
        boleto_novo.data_documento = Date.parse "2008-02-06"
        boleto_novo.dias_vencimento = 100
        boleto_novo.data_vencimento.to_s.should eql("2008-05-16")
        boleto_novo.data_vencimento.should eql(Date.parse("2008-05-16"))
        boleto_novo.data_documento = Date.parse "2008-02-06"
        boleto_novo.dias_vencimento = "df"
        boleto_novo.data_vencimento.should be_nil
      end

      it "should give a mensage" do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.monta_codigo_43_digitos.should eql("Sobreescreva este método na classe referente ao banco que você esta criando")
        boleto_novo.nosso_numero_boleto.should eql("Sobreescreva este método na classe referente ao banco que você esta criando")
        boleto_novo.agencia_conta_boleto.should eql("Sobreescreva este método na classe referente ao banco que você esta criando")
      end

      it "should validade module's inclusion" do
        Brcobranca::Config::OPCOES[:gerador] = 'rghost'
        boleto_novo = Brcobranca::Boleto::Base.new
        boleto_novo.class.included_modules.include?(RGhost).should be_true
        boleto_novo.class.included_modules.include?(Brcobranca::Boleto::Template::Rghost).should be_true
        boleto_novo.class.included_modules.include?(Brcobranca::Boleto::Template::Util).should be_true
      end
      
      it "Incluir módulos de template na classe" do
        Brcobranca::Boleto::Base.respond_to?(:imprimir_lista).should be_true
        Brcobranca::Boleto::Base.respond_to?(:to).should be_true
      end

    end
  end
end