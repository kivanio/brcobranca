# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::Unicred do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.current,
      nosso_numero: '072000031',
      documento: 6969,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'SP')
  end
  let(:params) do
    {
      carteira: '03',
      agencia: '1234',
      conta_corrente: '12345',
      digito_conta: '1',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '12345678910',
      codigo_transmissao: '12345678901234567890',
      byte_idt: '2',
      pagamentos: [pagamento]
    }
  end
  let(:unicred) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        object = subject.class.new(params.merge!(agencia: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        unicred.agencia = '12345'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@digito_conta' do
      it 'deve ser invalido se nao possuir um digito da conta corrente' do
        objeto = subject.class.new(params.merge!(digito_conta: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Digito conta não pode estar em branco.')
      end

      it 'deve ser inválido se o dígito da conta tiver mais de 1 dígito' do
        unicred.digito_conta = '12'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Digito conta deve ter 1 dígito.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        object = subject.class.new(params.merge!(conta_corrente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se a conta corrente tiver mais de 5 digitos' do
        unicred.conta_corrente = '123456'

        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Conta corrente deve ter 5 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser inválido se não possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser inválido se a carteira tiver mais de 2 dígitos' do
        unicred.carteira = '123'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Carteira deve ter 2 dígitos.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser inválido se não possuir o documento cedente' do
        object = subject.class.new(params.merge!(documento_cedente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end

      it 'deve ser invalido se o documento do cedente nao tiver entre 11 e 14 digitos' do
        unicred.documento_cedente = '123'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Documento cedente deve ter entre 11 e 14 dígitos.')
      end
    end

    context '@codigo_transmissao' do
      it 'deve ser inválido se não existir' do
        object = subject.class.new(params.merge!(codigo_transmissao: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Codigo transmissao não pode estar em branco.')
      end

      it 'deve ser inválido quando não possuir até 20 dígitos' do
        object = subject.class.new(params.merge!(codigo_transmissao: '123456789012345678901'))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Codigo transmissao deve ter 20 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 748' do
      expect(unicred.cod_banco).to eq '748'
    end

    it 'nome_banco deve ser UNICRED com 15 posicoes' do
      nome_banco = unicred.nome_banco
      expect(nome_banco.size).to eq 15
      expect(nome_banco.strip).to eq 'UNICRED'
    end

    it 'complemento deve retornar 294 caracteres' do
      expect(unicred.complemento.size).to eq 294
    end

    it 'info_conta deve retornar com 20 posicoes as informacoes da conta' do
      info_conta = unicred.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..19]).to eq '12345678901234567890'
    end

    it 'deve retornar o codigo da carteira de acordo com o tipo de emissão' do
      unicred.carteira = '03'
      expect(unicred.codigo_carteira).to eq '3'

      unicred.carteira = '09'
      expect(unicred.invalid?).to be true
      expect(unicred.errors.full_messages).to include('Carteira não existente para este banco.')
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = unicred.monta_header
        expect(header[1]).to eq '1'             # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA'    # literal da operacao
        expect(header[26..45]).to eq unicred.info_conta # informacoes da conta
        expect(header[76..78]).to eq '748'      # codigo do banco
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = unicred.monta_detalhe pagamento, 1
        expect(detalhe[37..61]).to eq "6969".ljust(25) # documento
        expect(detalhe[62..81]).to eq '072000031'.rjust(20, ' ')      # nosso numero
        expect(detalhe[120..125]).to eq Date.current.strftime('%d%m%y') # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990'               # valor do titulo
        expect(detalhe[142..145]).to eq '0000'                        # agência cobradora
        expect(detalhe[156..159]).to eq '0000'                        # instrução
        expect(detalhe[220..233]).to eq '00012345678901'              # documento do pagador
        expect(detalhe[234..263]).to eq 'PABLO DIEGO JOSE FRANCISCO DE ' # nome do pagador
      end
    end

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(unicred.gera_arquivo).to eq(read_remessa('remessa-unicred-cnab400.rem', unicred.gera_arquivo)) }
    end
  end
end
