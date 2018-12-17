# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Base do
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
      documento_cedente: '12345678901',
      convenio: '123',
      pagamentos: [pagamento] }
  end
  let(:cnab240) { subject.class.new(params) }

  context 'validacoes' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        objeto = subject.class.new(params.merge!(agencia: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Agencia não pode estar em branco.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        objeto = subject.class.new(params.merge!(conta_corrente: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser invalido se nao possuir o documento do cedente' do
        objeto = subject.class.new(params.merge!(documento_cedente: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end
    end

    context '@codigo_carteira' do
      it 'valor padrao deve ser 1 (cobranca simples)' do
        expect(cnab240.codigo_carteira).to eq '1'
      end

      it 'deve ser invalido se codigo da carteira nao tiver 1 digito' do
        cnab240.codigo_carteira = '12'
        expect(cnab240.invalid?).to be true
        expect(cnab240.errors.full_messages).to include('Codigo carteira deve ter 1 dígito.')
      end
    end

    context '@forma_cadastramento' do
      it 'valor padrao deve ser 1 (cobranca registrada)' do
        expect(cnab240.forma_cadastramento).to eq '1'
      end

      it 'deve ser invalido se a forma de cadastramento nao tiver 1 digito' do
        cnab240.forma_cadastramento = '12'
        expect(cnab240.invalid?).to be true
        expect(cnab240.errors.full_messages).to include('Forma cadastramento deve ter 1 dígito.')
      end
    end
  end

  context 'sobrescrita dos metodos' do
    it 'mostrar aviso sobre sobrecarga de métodos padrões' do
      expect { cnab240.complemento_header }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab240.versao_layout_arquivo }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab240.versao_layout_lote }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab240.convenio_lote }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab240.nome_banco }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab240.cod_banco }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab240.info_conta }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
      expect { cnab240.codigo_convenio }.to raise_error(Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando')
    end
  end
end
