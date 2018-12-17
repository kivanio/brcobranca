# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::BancoNordeste do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.current,
      nosso_numero: 123,
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
      carteira: '21',
      agencia: '1234',
      conta_corrente: '1234567',
      digito_conta: '1',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '12345678910',
      pagamentos: [pagamento]
    }
  end
  let(:banco_nordeste) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        object = subject.class.new(params.merge!(agencia: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        banco_nordeste.agencia = '12345'
        expect(banco_nordeste.invalid?).to be true
        expect(banco_nordeste.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@digito_conta' do
      it 'deve ser invalido se nao possuir um digito da conta corrente' do
        objeto = subject.class.new(params.merge!(digito_conta: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Digito conta não pode estar em branco.')
      end

      it 'deve ser inválido se o dígito da conta tiver mais de 1 dígito' do
        banco_nordeste.digito_conta = '12'
        expect(banco_nordeste.invalid?).to be true
        expect(banco_nordeste.errors.full_messages).to include('Digito conta deve ter 1 dígito.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        object = subject.class.new(params.merge!(conta_corrente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se a conta corrente tiver mais de 7 digitos' do
        banco_nordeste.conta_corrente = '12345678'
        expect(banco_nordeste.invalid?).to be true
        expect(banco_nordeste.errors.full_messages).to include('Conta corrente deve ter 7 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser inválido se não possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser inválido se a carteira tiver 2 dígitos' do
        banco_nordeste.carteira = '123'
        expect(banco_nordeste.invalid?).to be true
        expect(banco_nordeste.errors.full_messages).to include('Carteira deve ter 2 dígitos.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser inválido se não possuir o documento cedente' do
        object = subject.class.new(params.merge!(documento_cedente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end

      it 'deve ser invalido se o documento do cedente nao tiver entre 11 e 14 digitos' do
        banco_nordeste.documento_cedente = '123'
        expect(banco_nordeste.invalid?).to be true
        expect(banco_nordeste.errors.full_messages).to include('Documento cedente deve ter entre 11 e 14 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 004' do
      expect(banco_nordeste.cod_banco).to eq '004'
    end

    it 'nome_banco deve ser B.DO NORDESTE com 15 posicoes' do
      nome_banco = banco_nordeste.nome_banco
      expect(nome_banco.size).to eq 15
      expect(nome_banco.strip).to eq 'B.DO NORDESTE'
    end

    it 'complemento deve retornar 294 caracteres' do
      expect(banco_nordeste.complemento.size).to eq 294
    end

    it 'info_conta deve retornar com 20 posicoes as informacoes da conta' do
      info_conta = banco_nordeste.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..3]).to eq '1234'        # num. da agencia
      expect(info_conta[6..12]).to eq '1234567'    # num. da conta
      expect(info_conta[13]).to eq '1'             # num. do digito
    end

    it 'deve retornar o codigo da carteira de acordo com o tipo de emissão' do
      banco_nordeste.carteira = 21
      banco_nordeste.emissao_boleto = 1
      expect(banco_nordeste.codigo_carteira).to eq '1'

      banco_nordeste.carteira = 41
      banco_nordeste.emissao_boleto = 1
      expect(banco_nordeste.codigo_carteira).to eq '2'

      banco_nordeste.carteira = 21
      banco_nordeste.emissao_boleto = 2
      expect(banco_nordeste.codigo_carteira).to eq '4'

      banco_nordeste.carteira = 41
      banco_nordeste.emissao_boleto = 2
      expect(banco_nordeste.codigo_carteira).to eq '5'

      banco_nordeste.carteira = 51
      expect(banco_nordeste.codigo_carteira).to eq 'I'

      banco_nordeste.carteira = 99
      expect(banco_nordeste.invalid?).to be true
      expect(banco_nordeste.errors.full_messages).to include('Carteira não é válida.')
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = banco_nordeste.monta_header
        expect(header[1]).to eq '1'             # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA'    # literal da operacao
        expect(header[26..45]).to eq banco_nordeste.info_conta # informacoes da conta
        expect(header[76..78]).to eq '004'      # codigo do banco
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = banco_nordeste.monta_detalhe pagamento, 1
        expect(detalhe[37..61]).to eq "6969".ljust(25) # documento
        expect(detalhe[62..68]).to eq '0000123'                       # nosso numero
        expect(detalhe[69]).to eq '6'                                 # digito verificador
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

      it { expect(banco_nordeste.gera_arquivo).to eq(read_remessa('remessa-banco-nordeste-cnab400.rem', banco_nordeste.gera_arquivo)) }
    end
  end
end
