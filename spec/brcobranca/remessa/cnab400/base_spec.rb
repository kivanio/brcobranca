# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::Base do
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
  let(:pagamento_2) do
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
      digito_conta: '1',
      pagamentos: [pagamento, pagamento_2] }
  end
  let(:cnab400) { subject.class.new(params) }

  context 'sobrescrita dos metodos' do
    it 'mostrar aviso sobre sobrecarga de métodos padrões' do
      expect { cnab400.monta_detalhe(Brcobranca::Remessa::Pagamento.new, 1) }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab400.info_conta }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab400.cod_banco }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab400.nome_banco }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab400.complemento }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
    end
  end

  context '#valor_total_titulos' do
    it { expect(cnab400.valor_titulos_carteira(13)).to eq('0000000039980') }
  end
end
