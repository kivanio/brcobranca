# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Base do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                       data_vencimento: Date.current,
                                       nosso_numero: 123,
                                       documento_sacado: '12345678901',
                                       nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
                                       endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
                                       bairro_sacado: 'São josé dos quatro apostolos magros',
                                       cep_sacado: '12345678',
                                       cidade_sacado: 'Santa rita de cássia maria da silva',
                                       uf_sacado: 'SP')
  end
  let(:params) do
    { empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      agencia: '123',
      conta_corrente: '1234',
      pagamentos: [pagamento] }
  end
  let(:base) { subject.class.new(params) }

  context 'validacoes' do
    context '@pagamentos' do
      it 'deve ser invalido se nao possuir ao menos um pagamento' do
        objeto = subject.class.new(params.merge!(pagamentos: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Pagamentos não pode estar em branco.')
      end

      it 'deve ser invalido se nao for uma colecao (array)' do
        objeto = subject.class.new(params.merge!(pagamentos: 'teste'))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Pagamentos deve ser uma coleção (Array).')
      end

      it 'deve ser invalido se a colecao estiver vazia' do
        objeto = subject.class.new(params.merge!(pagamentos: []))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Pagamentos não pode estar vazio.')
      end

      it 'deve ser invalido se a colecao nao for de objetos Pagamento' do
        objeto = subject.class.new(params.merge!(pagamentos: ['teste']))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Pagamentos cada item deve ser um objeto Pagamento.')
      end

      it 'deve ser invalido se um objeto da colecao for invalido' do
        objeto = subject.class.new(params.merge!(pagamentos: [Brcobranca::Remessa::Pagamento.new]))
        expect(objeto.invalid?).to be true
      end
    end

    context '@empresa_mae' do
      it 'deve ser invalido se nao possuir uma empresa mae' do
        objeto = subject.class.new(params.merge!(empresa_mae: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Empresa mae não pode estar em branco.')
      end
    end
  end
end
