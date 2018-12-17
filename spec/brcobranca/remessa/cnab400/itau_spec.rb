# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::Itau do
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
      codigo_multa: '1',
      percentual_multa: 2.00,
      uf_sacado: 'SP')
  end
  let(:params) do
    { carteira: '123',
      agencia: '1234',
      conta_corrente: '12345',
      digito_conta: '1',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '12345678910',
      pagamentos: [pagamento] }
  end
  let(:itau) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        object = subject.class.new(params.merge!(agencia: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        itau.agencia = '12345'
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@digito_conta' do
      it 'deve ser invalido se nao possuir um digito da conta corrente' do
        objeto = subject.class.new(params.merge!(digito_conta: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Digito conta não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira tiver mais de 1 digito' do
        itau.digito_conta = '12'
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).to include('Digito conta deve ter 1 dígito.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        object = subject.class.new(params.merge!(conta_corrente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se a conta corrente tiver mais de 5 digitos' do
        itau.conta_corrente = '123456'
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).to include('Conta corrente deve ter 5 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser invalido se nao possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira tiver mais de 3 digitos' do
        itau.carteira = '1234'
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).to include('Carteira deve ter no máximo 3 dígitos.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser invalido se nao possuir o documento cedente' do
        object = subject.class.new(params.merge!(documento_cedente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end

      it 'deve ser invalido se o documento do cedente nao tiver entre 11 e 14 digitos' do
        itau.documento_cedente = '123'
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).to include('Documento cedente deve ter entre 11 e 14 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 341' do
      expect(itau.cod_banco).to eq '341'
    end

    it 'nome_banco deve ser BANCO ITAU SA com 15 posicoes' do
      nome_banco = itau.nome_banco
      expect(nome_banco.size).to eq 15
      expect(nome_banco.strip).to eq 'BANCO ITAU SA'
    end

    it 'complemento deve retornar 294 caracteres' do
      expect(itau.complemento.size).to eq 294
    end

    it 'info_conta deve retornar com 20 posicoes as informacoes da conta' do
      info_conta = itau.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..3]).to eq '1234' # num. da agencia
      expect(info_conta[6..10]).to eq '12345' # num. da conta
      expect(info_conta[11]).to eq '1' # num. do digito
    end

    it 'deve retornar o codigo da carteira' do
      # de acordo com a documentacao,
      # o codigo da carteira 150 é U
      itau.carteira = 150
      expect(itau.codigo_carteira).to eq 'U'
      # o codigo da carteira 191 é 1
      itau.carteira = 191
      expect(itau.codigo_carteira).to eq '1'
      # o codigo da carteira 147 é E
      itau.carteira = 147
      expect(itau.codigo_carteira).to eq 'E'
      # para as demais carteiras presentes na documentacao
      # o codigo é I
      itau.carteira = 109
      expect(itau.codigo_carteira).to eq 'I'
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = itau.monta_header
        expect(header[1]).to eq '1' # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA' # literal da operacao
        expect(header[26..45]).to eq itau.info_conta # informacoes da conta
        expect(header[76..78]).to eq '341' # codigo do banco
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = itau.monta_detalhe pagamento, 2
        expect(detalhe[37..61]).to eq "6969".ljust(25)
        expect(detalhe[62..69]).to eq '00000123' # nosso numero
        expect(detalhe[120..125]).to eq Date.current.strftime('%d%m%y') # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990' # valor do titulo
        expect(detalhe[142..146]).to eq '00000' # agência cobradora
        expect(detalhe[156..157]).to eq '00' # instrução 1
        expect(detalhe[158..159]).to eq '00' # instrução 2
        expect(detalhe[220..233]).to eq '00012345678901' # documento do pagador
        expect(detalhe[234..263]).to eq 'PABLO DIEGO JOSE FRANCISCO DE ' # nome do pagador
      end

      it 'informacoes devem estar posicionadas corretamente no detalhe opcional de multa' do
        detalhe_multa = itau.monta_detalhe_multa pagamento, 3
                                                                          # Significado                        Posição     Picture
        expect(detalhe_multa[0]).to eq '2'                                # Identificação do reg. transação    [001..001]  9(001)
        expect(detalhe_multa[1]).to eq '1'                                # Código da multa                    [002..002]  X(001)
        expect(detalhe_multa[2..9]).to eq Date.current.strftime('%d%m%Y')   # Data da multa                      [003..010]  9(008)
        expect(detalhe_multa[10..22]).to eq '0000000000200'               # Valor da multa                     [011..023]  9(013)
        expect(detalhe_multa[23..393]).to eq ''.rjust(371, ' ')           # Complemento                        [024..394]  X(370)
        expect(detalhe_multa[394..399]).to eq '000003'                    # Número sequencial                  [395..400]  9(006)
      end
    end

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(itau.gera_arquivo).to eq(read_remessa('remessa-itau-cnab400.rem', itau.gera_arquivo)) }
    end
  end
end
