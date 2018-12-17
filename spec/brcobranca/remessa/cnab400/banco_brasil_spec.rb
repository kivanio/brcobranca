# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::BancoBrasil do
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
    { carteira: '12',
      agencia: '1234',
      variacao_carteira: '123',
      convenio: '1234567',
      convenio_lider: '7654321',
      conta_corrente: '1234',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '12345678910',
      sequencial_remessa: '1',
      pagamentos: [pagamento],
      tipo_cobranca: '04DSC' }
  end
  let(:banco_brasil) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        object = subject.class.new(params.merge!(agencia: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        banco_brasil.agencia = '12345'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Agencia deve ser igual a 4 digítos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        object = subject.class.new(params.merge!(conta_corrente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se a conta corrente tiver mais de 5 digitos' do
        banco_brasil.conta_corrente = '123456789'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Conta corrente deve ser menor ou igual a 8 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser invalido se nao possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira nao tiver 2 digitos' do
        banco_brasil.carteira = '123'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Carteira deve ser igual a 2 digítos.')
      end
    end

    context '@convenio' do
      it 'deve ser invalido se nao possuir o convenio' do
        object = subject.class.new(params.merge!(convenio: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Convenio não pode estar em branco.')
      end
    end

    context '@variacao_carteira' do
      it 'deve ser invalido se nao possuir a variacao da carteira' do
        object = subject.class.new(params.merge!(variacao_carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Variacao carteira não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira nao tiver 3 digitos' do
        banco_brasil.variacao_carteira = '1234'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Variacao carteira deve ser igual a 3 digítos.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser invalido se nao possuir o documento cedente' do
        object = subject.class.new(params.merge!(documento_cedente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end

      it 'deve ser invalido se o documento do cedente nao tiver entre 11 e 14 digitos' do
        banco_brasil.documento_cedente = '123'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Documento cedente deve ter entre 11 e 14 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 001' do
      expect(banco_brasil.cod_banco).to eq '001'
    end

    it 'nome_banco deve ser BANCODOBRASIL com 15 posicoes' do
      nome_banco = banco_brasil.nome_banco
      expect(nome_banco.size).to eq 15
      expect(nome_banco.strip).to eq 'BANCODOBRASIL'
    end

    it 'complemento deve retornar 294 posicoes com as suas informacoes' do
      complemento = banco_brasil.complemento
      expect(complemento.size).to eq 294
      expect(complemento[0..6]).to eq '0000001'    # sequencial de remessa
      expect(complemento[29..35]).to eq '7654321'  # numero do convenio lider
    end

    it 'info_conta deve retornar com 20 posicoes as informacoes da conta' do
      info_conta = banco_brasil.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..3]).to eq '1234'                              # num. da agencia
      expect(info_conta[4]).to eq banco_brasil.agencia_dv.to_s           # digito da agencia
      expect(info_conta[5..12]).to eq '00001234'                         # num. da conta corrente
      expect(info_conta[13]).to eq banco_brasil.conta_corrente_dv.to_s   # digito da conta corrente
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = banco_brasil.monta_header
        expect(header[1]).to eq '1'                                                 # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA'                                        # literal da operacao
        expect(header[26..45]).to eq banco_brasil.info_conta                        # informacoes da conta
        expect(header[46..75]).to eq 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA'[0..29] # nome da empresa cedente
        expect(header[76..78]).to eq '001'                                          # codigo do banco
        expect(header[79..93]).to eq 'BANCODOBRASIL'.ljust(15, ' ')                 # nome do banco
        expect(header[100..393]).to eq banco_brasil.complemento                     # complemento
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = banco_brasil.monta_detalhe pagamento, 1
        expect(detalhe[3..16]).to eq '00012345678910'                           # documento do cedente
        expect(detalhe[17..20]).to eq '1234'                                    # agencia
        expect(detalhe[21]).to eq banco_brasil.agencia_dv.to_s                  # digito da agencia
        expect(detalhe[22..29]).to eq '00001234'                                # num. da conta corrente
        expect(detalhe[30]).to eq banco_brasil.conta_corrente_dv.to_s           # digito da conta corrente
        expect(detalhe[31..37]).to eq '1234567'                                 # convenio da empresa
        expect(detalhe[70..79]).to eq '0000000123'                              # nosso numero
        expect(detalhe[91..93]).to eq '123'                                     # variacao da carteira
        expect(detalhe[101..105]).to eq '04DSC'                                 # tipo de cobranca
        expect(detalhe[106..107]).to eq '12'                                    # carteira
        expect(detalhe[120..125]).to eq Date.current.strftime('%d%m%y')         # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990'                         # valor do titulo
        expect(detalhe[156..157]).to eq '00'                                    # primeira instrucao
        expect(detalhe[158..159]).to eq '00'                                    # segunda instrucao
        expect(detalhe[220..233]).to eq '00012345678901'                        # documento do pagador
        expect(detalhe[234..270]).to eq 'PABLO DIEGO JOSE FRANCISCO DE PAULA J' # nome do pagador
      end
    end

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(banco_brasil.gera_arquivo).to eq(read_remessa('remessa-banco-brasil-cnab400.rem', banco_brasil.gera_arquivo)) }
    end
  end
end
