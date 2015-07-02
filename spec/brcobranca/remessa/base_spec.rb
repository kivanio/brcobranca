# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Brcobranca::Remessa::Base do

  let(:pagamento) { Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                                       data_vencimento: Date.today,
                                                       nosso_numero: 123,
                                                       documento_sacado: '12345678901',
                                                       nome_sacado: 'nome',
                                                       endereco_sacado: 'endereco',
                                                       bairro_sacado: 'bairro',
                                                       cep_sacado: '12345678',
                                                       cidade_sacado: 'cidade',
                                                       uf_sacado: 'SP') }
  let(:params) { {empresa_mae: 'teste',
                  agencia: '123',
                  conta_corrente: '1234',
                  pagamentos: [pagamento]} }
  let(:base) { subject.class.new(params) }

  context 'validacoes' do
    context '@pagamentos' do
      it 'deve ser invalido se nao for uma colecao (array)' do
        objeto = subject.class.new(params.merge!({pagamentos: 'teste'}))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Pagamentos deve ser uma coleção (Array).')
      end

      it 'deve ser invalido se a colecao estiver vazia' do
        objeto = subject.class.new(params.merge!(pagamentos: []))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Pagamentos não pode estar vazio.')
      end

      it 'deve ser invalido se a colecao nao for de objetos Pagamento' do
        objeto = subject.class.new(params.merge!({pagamentos: ['teste']}))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Pagamentos cada item deve ser um objeto Pagamento.')
      end

      it 'deve ser invalido se um objeto da colecao for invalido' do
        objeto = subject.class.new(params.merge!({pagamentos: [Brcobranca::Remessa::Pagamento.new]}))
        expect(objeto.invalid?).to be true
      end
    end

    context '@empresa_mae' do
      it 'deve ser invalido se nao possuir uma empresa mae' do
        objeto = subject.class.new(params.merge!({empresa_mae: nil}))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Empresa mae não pode estar em branco.')
      end

      it 'deve ser invalido se a empresa tiver mais de 30 caracteres' do
        base.empresa_mae = 'teste'.ljust(40, ' ')
        expect(base.invalid?).to be true
        expect(base.errors.full_messages).to include('Empresa mae deve ser menor ou igual a 30 caracteres.')
      end
    end

    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        objeto = subject.class.new(params.merge!({agencia: nil}))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Agencia não pode estar em branco.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        objeto = subject.class.new(params.merge!({conta_corrente: nil}))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end
    end
  end
end