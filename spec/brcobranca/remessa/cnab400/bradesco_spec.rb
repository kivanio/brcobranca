# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'shared_examples/cnab400'

describe Brcobranca::Remessa::Cnab400::Bradesco do
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
    { carteira: '01',
      agencia: '12345',
      conta_corrente: '1234567',
      digito_conta: '1',
      empresa_mae: 'asd',
      sequencial_remessa: '1',
      codigo_empresa: '123',
      pagamentos: [pagamento] }
  end
  let(:bradesco_cnab400) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        objeto = subject.class.new(params.merge!(agencia: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser invalido se a agencia tiver mais de 5 digitos' do
        bradesco_cnab400.agencia = '123456'
        expect(bradesco_cnab400.invalid?).to be true
        expect(bradesco_cnab400.errors.full_messages).to include('Agencia deve ter 5 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        objeto = subject.class.new(params.merge!(conta_corrente: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se a conta corrente tiver mais de 8 digitos' do
        bradesco_cnab400.conta_corrente = '12345678'
        expect(bradesco_cnab400.invalid?).to be true
        expect(bradesco_cnab400.errors.full_messages).to include('Conta corrente deve ter 7 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser invalido se nao possuir uma carteira' do
        objeto = subject.class.new(params.merge!(carteira: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira tiver mais de 2 digitos' do
        bradesco_cnab400.carteira = '123'
        expect(bradesco_cnab400.invalid?).to be true
        expect(bradesco_cnab400.errors.full_messages).to include('Carteira deve ter no máximo 2 dígitos.')
      end
    end

    context '@sequencial_remessa' do
      it 'deve ser invalido se nao possuir um num. sequencial de remessa' do
        objeto = subject.class.new(params.merge!(sequencial_remessa: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Sequencial remessa não pode estar em branco.')
      end

      it 'deve ser invalido se sequencial de remessa tiver mais de 8 digitos' do
        bradesco_cnab400.sequencial_remessa = '12345678'
        expect(bradesco_cnab400.invalid?).to be true
        expect(bradesco_cnab400.errors.full_messages).to include('Sequencial remessa deve ter 7 dígitos.')
      end
    end

    context '@codigo_empresa' do
      it 'deve ser invalido se nao possuir um codigo da empresa' do
        objeto = subject.class.new(params.merge!(codigo_empresa: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Codigo empresa não pode estar em branco.')
      end

      it 'deve ser invalido se codigo da empresa tiver mais de 20 digitos' do
        bradesco_cnab400.codigo_empresa = ''.rjust(21, '0')
        expect(bradesco_cnab400.invalid?).to be true
        expect(bradesco_cnab400.errors.full_messages).to include('Codigo empresa deve ser menor ou igual a 20 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 237' do
      expect(bradesco_cnab400.cod_banco).to eq '237'
    end

    it 'nome_banco deve ser BRADESCO com 15 posicoes' do
      nome_banco = bradesco_cnab400.nome_banco
      expect(nome_banco.size).to eq 15
      expect(nome_banco.strip).to eq 'BRADESCO'
    end

    it 'complemento deve ter 294 caracteres com as informacoes nas posicoes corretas' do
      complemento = bradesco_cnab400.complemento
      expect(complemento.size).to eq 294
      expect(complemento[8..9]).to eq 'MX'
      expect(complemento[10..16]).to eq '0000001'
    end

    it 'info_conta deve ter 20 posicoes' do
      expect(bradesco_cnab400.info_conta.size).to eq 20
    end

    it 'identificacao da empresa deve ter as informacoes nas posicoes corretas' do
      id_empresa = bradesco_cnab400.identificacao_empresa
      expect(id_empresa[1..3]).to eq '001'        # carteira (com 3 digitos)
      expect(id_empresa[4..8]).to eq '12345'      # agencia
      expect(id_empresa[9..15]).to eq '1234567'   # conta corrente
      expect(id_empresa[16]).to eq '1'            # digito da conta corrente
    end

    it 'calcula o digito verificador do nosso numero' do
      # Calculo do digito:
      # * multiplicar o nosso numero acrescido da carteira a esquerda
      #   pelo modulo 11, com base 7
      #
      # carteira(2) + nosso numero(11)
      # => 0 1 0 0 0 0 0 0 0 0 1 2 3
      # x  2 7 6 5 4 3 2 7 6 5 4 3 2
      # =  0 7 0 0 0 0 0 0 0 0 4 6 6 = 23
      # 23/11 = 2 com resto 1
      # quando resto 1 codigo sera P
      #
      expect(bradesco_cnab400.digito_nosso_numero(123)).to eq 'P'
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = bradesco_cnab400.monta_header
        expect(header[1]).to eq '1'                                # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA'                       # literal da operacao
        expect(header[26..45]).to eq bradesco_cnab400.info_conta   # informacoes da conta
        expect(header[76..78]).to eq '237'                         # codigo do banco
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = bradesco_cnab400.monta_detalhe pagamento, 1
        expect(detalhe[70..80]).to eq '00000000123'                                                 # nosso numero
        expect(detalhe[81]).to eq 'P'                                                               # digito nosso numero (para nosso numero 123 o digito e P)
        expect(detalhe[120..125]).to eq Date.today.strftime('%d%m%y')                               # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990'                                             # valor do documento
        expect(detalhe[220..233]).to eq '00012345678901'                                            # documento do pagador
        expect(detalhe[234..273]).to eq 'NOME'.ljust(40, ' ')                                       # nome do pagador
        expect(detalhe[274..313]).to eq bradesco_cnab400.formata_endereco_sacado(pagamento).upcase  # endereco do pagador
      end
    end
  end
end
