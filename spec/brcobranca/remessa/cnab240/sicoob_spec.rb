# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Sicoob do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(
      valor: 50,
      data_vencimento: Date.today,
      nosso_numero: '429715',
      documento_sacado: '82136760505',
      nome_sacado: 'Jose da Silva',
      endereco_sacado: 'Av. Burkhard Hehn Simoes',
      bairro_sacado: 'Sao Francisco',
      cep_sacado: '24360440',
      cidade_sacado: 'Rio de Janeiro',
      uf_sacado: 'RJ'
    )
  end

  let(:params) do
    {
      empresa_mae: 'SEBASTIAN ELIAS PUBLICIDADE',
      agencia: '4327',
      conta_corrente: '03666',
      documento_cedente: '74576177000177',
      modalidade_carteira: '01',
      pagamentos: [pagamento]
    }
  end

  let(:sicoob) { subject.class.new(params) }

  context 'validacoes' do
    context '@modalidade_carteira' do
      it 'deve ser invalido se nao possuir a modalidade da carteira' do
        objeto = subject.class.new(params.merge(modalidade_carteira: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Modalidade carteira não pode estar em branco.')
      end
    end

    context '@tipo_formulario' do
      it 'deve ser invalido se nao possuir o tipo de formulario' do
        objeto = subject.class.new(params.merge(tipo_formulario: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Tipo formulario não pode estar em branco.')
      end
    end

    context '@parcela' do
      it 'deve ser invalido se nao possuir a parcela' do
        objeto = subject.class.new(params.merge(parcela: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Parcela não pode estar em branco.')
      end
    end

    context '@agencia' do
      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        sicoob.agencia = '12345'
        expect(sicoob.invalid?).to be true
        expect(sicoob.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se a conta corrente tiver mais de 5 digitos' do
        sicoob.conta_corrente = '123456'
        expect(sicoob.invalid?).to be true
        expect(sicoob.errors.full_messages).to include('Conta corrente deve ter 5 dígitos.')
      end
    end
  end

  context 'formatacoes' do
    it 'codigo do banco deve ser 001' do
      expect(sicoob.cod_banco).to eq '756'
    end

    it 'nome do banco deve ser Sicoob com 30 posicoes' do
      nome_banco = sicoob.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..19]).to eq 'SICOOB              '
    end

    it 'versao do layout do arquivo deve ser 081' do
      expect(sicoob.versao_layout_arquivo).to eq '081'
    end

    it 'versao do layout do lote deve ser 040' do
      expect(sicoob.versao_layout_lote).to eq '040'
    end

    it 'deve calcular o digito da agencia' do
      # digito calculado a partir do modulo 11 com base 9
      #
      # agencia = 1  2  3  4
      #
      #           4  3  2  1
      # x         9  8  7  6
      # =         36 24 14 6 = 80
      # 80 / 11 = 7 com resto 3
      expect(sicoob.digito_agencia).to eq '3'
    end

    it 'deve calcular  digito da conta' do
      # digito calculado a partir do modulo 11 com base 9
      #
      # conta = 1  2  3  4  5
      #
      #         5  4  3  2  1
      # x       9  8  7  6  5
      # =       45 32 21 12 5 = 116
      # 116 / 11 = 10 com resto 5
      expect(sicoob.digito_conta).to eq '8'
    end

    it 'cod. convenio deve retornar as informacoes nas posicoes corretas' do
      cod_convenio = sicoob.codigo_convenio
      expect(cod_convenio[0..19]).to eq '                    '
    end

    it 'info conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = sicoob.info_conta
      expect(info_conta[0..4]).to eq '04327'
      expect(info_conta[5]).to eq '3'
      expect(info_conta[6..17]).to eq '000000003666'
      expect(info_conta[18]).to eq '8'
    end

    it 'complemento header deve retornar espacos em branco' do
      expect(sicoob.complemento_header).to eq ''.rjust(29, ' ')
    end

    it 'complemento trailer deve retornar espacos em branco' do
      expect(sicoob.complemento_trailer).to eq ''.rjust(217, ' ')
    end

    it 'formata o nosso numero' do
      nosso_numero = sicoob.formata_nosso_numero 1
      expect(nosso_numero).to eq "000000000101014     "
    end
  end

  context 'geracao remessa' do
    it_behaves_like 'cnab240'

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(sicoob.gera_arquivo).to eq(read_remessa('remessa-bancoob.rem', sicoob.gera_arquivo)) }
    end
  end
end
