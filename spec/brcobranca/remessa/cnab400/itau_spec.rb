# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'shared_examples/cnab400'

describe Brcobranca::Remessa::Cnab400::Itau do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                       data_vencimento: Date.today,
                                       nosso_numero: 123,
                                       documento_sacado: '12345678901',
                                       nome_sacado: 'nome',
                                       endereco_sacado: 'endereco',
                                       bairro_sacado: 'bairro',
                                       cep_sacado: '12345678',
                                       cidade_sacado: 'cidade',
                                       uf_sacado: 'SP')
  end
  let(:params) do
    { carteira: '123',
      agencia: '1234',
      conta_corrente: '12345',
      digito_conta: '1',
      empresa_mae: 'asd',
      documento_cedente: '12345678910',
      pagamentos: [pagamento] }
  end
  let(:itau_cnab400) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        object = subject.class.new(params.merge!(agencia: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        itau_cnab400.agencia = '12345'
        expect(itau_cnab400.invalid?).to be true
        expect(itau_cnab400.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        object = subject.class.new(params.merge!(conta_corrente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se a conta corrente tiver mais de 5 digitos' do
        itau_cnab400.conta_corrente = '123456'
        expect(itau_cnab400.invalid?).to be true
        expect(itau_cnab400.errors.full_messages).to include('Conta corrente deve ter 5 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser invalido se nao possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira tiver mais de 3 digitos' do
        itau_cnab400.carteira = '1234'
        expect(itau_cnab400.invalid?).to be true
        expect(itau_cnab400.errors.full_messages).to include('Carteira deve ter no máximo 3 dígitos.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser invalido se nao possuir o documento cedente' do
        object = subject.class.new(params.merge!(documento_cedente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end

      it 'deve ser invalido se o documento do cedente nao tiver entre 11 e 14 digitos' do
        itau_cnab400.documento_cedente = '123'
        expect(itau_cnab400.invalid?).to be true
        expect(itau_cnab400.errors.full_messages).to include('Documento cedente deve ter entre 11 e 14 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 341' do
      expect(itau_cnab400.cod_banco).to eq '341'
    end

    it 'nome_banco deve ser BANCO ITAU SA com 15 posicoes' do
      nome_banco = itau_cnab400.nome_banco
      expect(nome_banco.size).to eq 15
      expect(nome_banco.strip).to eq 'BANCO ITAU SA'
    end

    it 'complemento deve retornar 294 caracteres' do
      expect(itau_cnab400.complemento.size).to eq 294
    end

    it 'info_conta deve retornar com 20 posicoes as informacoes da conta' do
      info_conta = itau_cnab400.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..3]).to eq '1234'   # num. da agencia
      expect(info_conta[6..10]).to eq '12345' # num. da conta
      expect(info_conta[11]).to eq '1'        # num. do digito
    end

    it 'deve retornar o tipo da empresa (fisica ou juridica)' do
      # teste pessoa fisica
      expect(itau_cnab400.tipo_empresa).to eq '01'
      # teste pessoa juridica
      itau_cnab400.documento_cedente = '12345678910111'
      expect(itau_cnab400.tipo_empresa).to eq '02'
    end

    it 'deve retornar o codigo da carteira' do
      # de acordo com a documentacao,
      # o codigo da carteira 150 é U
      itau_cnab400.carteira = 150
      expect(itau_cnab400.codigo_carteira).to eq 'U'
      # o codigo da carteira 191 é 1
      itau_cnab400.carteira = 191
      expect(itau_cnab400.codigo_carteira).to eq '1'
      # o codigo da carteira 147 é E
      itau_cnab400.carteira = 147
      expect(itau_cnab400.codigo_carteira).to eq 'E'
      # para as demais carteiras presentes na documentacao
      # o codigo é I
      itau_cnab400.carteira = 109
      expect(itau_cnab400.codigo_carteira).to eq 'I'
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = itau_cnab400.monta_header
        expect(header[1]).to eq '1'                            # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA'                   # literal da operacao
        expect(header[26..45]).to eq itau_cnab400.info_conta   # informacoes da conta
        expect(header[76..78]).to eq '341'                     # codigo do banco
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = itau_cnab400.monta_detalhe pagamento, 1
        expect(detalhe[62..69]).to eq '00000123'                       # nosso numero
        expect(detalhe[120..125]).to eq Date.today.strftime('%d%m%y')  # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990'                # valor do titulo
        expect(detalhe[220..233]).to eq '00012345678901'               # documento do pagador
        expect(detalhe[234..263]).to eq 'NOME'.ljust(30, ' ')          # nome do pagador
      end
    end
  end
end
