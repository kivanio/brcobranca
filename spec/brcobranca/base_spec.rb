# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

module Brcobranca #:nodoc:[all]
  module Boleto #:nodoc:[all]
    describe Base do
      before(:each) do
        @valid_attributes = {
            :especie_documento => 'DM',
            :moeda => '9',
            :data_documento => Date.today,
            :dias_vencimento => 1,
            :aceite => 'S',
            :quantidade => 1,
            :valor => 0.0,
            :local_pagamento => 'QUALQUER BANCO ATÉ O VENCIMENTO',
            :beneficiario => 'Kivanio Barbosa',
            :documento_beneficiario => '12345678912',
            :pagador => 'Claudio Pozzebom',
            :pagador_documento => '12345678900',
            :agencia => '4042',
            :conta_corrente => '61900',
            :convenio => 12387989,
            :numero_documento => '777700168'
        }
      end

      it 'Criar nova instancia com atributos padrões' do
        boleto_novo = Brcobranca::Boleto::Base.new
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
        boleto_novo.local_pagamento.should eql('QUALQUER BANCO ATÉ O VENCIMENTO')
        boleto_novo.valid?.should be_false
      end

      it 'Criar nova instancia com atributos válidos' do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.especie_documento.should eql('DM')
        boleto_novo.especie.should eql('R$')
        boleto_novo.moeda.should eql('9')
        boleto_novo.data_documento.should eql(Date.today)
        boleto_novo.dias_vencimento.should eql(1)
        boleto_novo.data_vencimento.should eql(Date.today + 1)
        boleto_novo.aceite.should eql('S')
        boleto_novo.quantidade.should eql(1)
        boleto_novo.valor.should eql(0.0)
        boleto_novo.valor_documento.should eql(0.00)
        boleto_novo.local_pagamento.should eql('QUALQUER BANCO ATÉ O VENCIMENTO')
        boleto_novo.beneficiario.should eql('Kivanio Barbosa')
        boleto_novo.documento_beneficiario.should eql('12345678912')
        boleto_novo.pagador.should eql('Claudio Pozzebom')
        boleto_novo.pagador_documento.should eql('12345678900')
        boleto_novo.conta_corrente.should eql('0061900')
        boleto_novo.agencia.should eql('4042')
        boleto_novo.convenio.should eql(12387989)
        boleto_novo.numero_documento.should eql('777700168')
        boleto_novo.valid?.should be_true
      end

      it 'Calcula agencia_dv' do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.agencia = '85068014982'
        boleto_novo.agencia_dv.should eql(9)
        boleto_novo.agencia = '05009401448'
        boleto_novo.agencia_dv.should eql(1)
        boleto_novo.agencia = '12387987777700168'
        boleto_novo.agencia_dv.should eql(2)
        boleto_novo.agencia = '4042'
        boleto_novo.agencia_dv.should eql(8)
        boleto_novo.agencia = '61900'
        boleto_novo.agencia_dv.should eql(0)
        boleto_novo.agencia = '0719'
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

      it 'Calcula conta_corrente_dv' do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.conta_corrente = '85068014982'
        boleto_novo.conta_corrente_dv.should eql(9)
        boleto_novo.conta_corrente = '05009401448'
        boleto_novo.conta_corrente_dv.should eql(1)
        boleto_novo.conta_corrente = '12387987777700168'
        boleto_novo.conta_corrente_dv.should eql(2)
        boleto_novo.conta_corrente = '4042'
        boleto_novo.conta_corrente_dv.should eql(8)
        boleto_novo.conta_corrente = '61900'
        boleto_novo.conta_corrente_dv.should eql(0)
        boleto_novo.conta_corrente = '0719'
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

      it 'Calcula o valor do documento' do
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
        boleto_novo.quantidade = 'gh'
        boleto_novo.valor = 135.43
        boleto_novo.valor_documento.should eql(0.0)
      end

      it 'Calcula data_vencimento' do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        boleto_novo.data_documento = Date.parse '2008-02-01'
        boleto_novo.dias_vencimento = 1
        boleto_novo.data_vencimento.to_s.should eql('2008-02-02')
        boleto_novo.data_vencimento.should eql(Date.parse('2008-02-02'))
        boleto_novo.data_documento = Date.parse '2008-02-02'
        boleto_novo.dias_vencimento = 28
        boleto_novo.data_vencimento.to_s.should eql('2008-03-01')
        boleto_novo.data_vencimento.should eql(Date.parse('2008-03-01'))
        boleto_novo.data_documento = Date.parse '2008-02-06'
        boleto_novo.dias_vencimento = 100
        boleto_novo.data_vencimento.to_s.should eql('2008-05-16')
        boleto_novo.data_vencimento.should eql(Date.parse('2008-05-16'))
        boleto_novo.data_documento = Date.parse '2008-02-06'
        boleto_novo.dias_vencimento = 'df'
        boleto_novo.data_vencimento.should eql(boleto_novo.data_documento)
      end

      it 'Mostrar aviso sobre sobrecarga de métodos padrões' do
        boleto_novo = Brcobranca::Boleto::Base.new(@valid_attributes)
        lambda { boleto_novo.codigo_barras_segunda_parte }.should raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
        lambda { boleto_novo.nosso_numero_boleto }.should raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
        lambda { boleto_novo.agencia_conta_boleto }.should raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      end

      it 'Incluir módulos de template na classe' do
        Brcobranca::Boleto::Base.respond_to?(:lote).should be_true
        Brcobranca::Boleto::Base.respond_to?(:to).should be_true
      end

      it 'Incluir módulos de template na instancia' do
        boleto_novo = Brcobranca::Boleto::Base.new
        boleto_novo.respond_to?(:lote).should be_true
        boleto_novo.respond_to?(:to).should be_true
      end

    end
  end
end
