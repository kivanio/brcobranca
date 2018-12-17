# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Unicred do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(
      valor: 50.0,
      data_vencimento: Date.current,
      nosso_numero: '072000031',
      numero: '00003',
      documento: 6969,
      documento_sacado: '82136760505',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'RJ'
    )
  end

  let(:params) do
    {
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      agencia: '0165',
      conta_corrente: '00623',
      digito_conta: '8',
      documento_cedente: '74576177000177',
      modalidade_carteira: '01',
      posto: '02',
      byte_idt: '2',
      pagamentos: [pagamento]
    }
  end

  let(:unicred) { subject.class.new(params) }

  before { Timecop.freeze(Time.local(2007, 7, 14, 16, 15, 15)) }
  after { Timecop.return }

  context 'validacoes' do
    context '@posto' do
      it 'deve ser invalido se nao possuir o valor do posto' do
        objeto = subject.class.new(params.merge(posto: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Posto não pode estar em branco.')
      end

      it 'deve ser invalido se o posto tiver mais de 2 dígitos' do
        unicred.posto = '123'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Posto deve ter 2 dígitos.')
      end
    end

    context '@byte_idt' do
      it 'deve ser invalido se nao possuir o valor da byte de geracao' do
        objeto = subject.class.new(params.merge(byte_idt: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Byte idt não pode estar em branco.')
      end

      it 'deve ser invalido se o byte idt tiver mais de 1 dígito' do
        unicred.byte_idt = '12'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages)
          .to include('Byte idt deve ser 1 se o numero foi gerado pela agencia ou 2-9 se foi gerado pelo beneficiário')
      end
    end

    context '@modalidade_carteira' do
      it 'deve ser invalido se nao possuir a modalidade da carteira' do
        objeto = subject.class.new(params.merge(modalidade_carteira: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Modalidade carteira não pode estar em branco.')
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
        unicred.agencia = '12345'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se a conta corrente tiver mais de 5 digitos' do
        unicred.conta_corrente = '123456'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Conta corrente deve ter 5 dígitos.')
      end
    end

    context '@digito_conta' do
      it 'deve ser inválido se o dígito conta não for informado' do
        unicred.digito_conta = nil
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Digito conta não pode estar em branco.')
      end

      it 'deve ser inválido se o dígito conta tiver mais de 1 dígito' do
        unicred.digito_conta = '12'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Digito conta deve ter 1 dígito.')
      end
    end
  end

  context 'formatacoes' do
    it 'codigo do banco deve ser 001' do
      expect(unicred.cod_banco).to eq '748'
    end

    it 'nome do banco deve ser unicred com 30 posicoes' do
      nome_banco = unicred.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..19]).to eq 'SICREDI             '
    end

    it 'versao do layout do arquivo deve ser 081' do
      expect(unicred.versao_layout_arquivo).to eq '081'
    end

    it 'versao do layout do lote deve ser 040' do
      expect(unicred.versao_layout_lote).to eq '040'
    end

    it 'deve calcular o digito da agencia' do
      expect(unicred.digito_agencia).to eq ' '
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
      expect(unicred.digito_conta).to eq '8'
    end

    it 'cod. convenio deve retornar as informacoes nas posicoes corretas' do
      cod_convenio = unicred.codigo_convenio
      expect(cod_convenio[0..19]).to eq ''.rjust(20, ' ')
    end

    it 'info conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = unicred.info_conta
      expect(info_conta[0..4]).to eq '00165'
      expect(info_conta[5]).to eq ' '
      expect(info_conta[6..17]).to eq '000000000623'
      expect(info_conta[18]).to eq '8'
    end

    it 'complemento header deve retornar espacos em branco' do
      expect(unicred.complemento_header).to eq ''.rjust(29, ' ')
    end

    it 'complemento trailer deve retornar espacos em branco com a totalização das cobranças' do
      total_cobranca_simples    = "".rjust(23, "0")
      total_cobranca_vinculada  = "".rjust(23, "0")
      total_cobranca_caucionada = "".rjust(23, "0")
      total_cobranca_descontada = "".rjust(23, "0")

      expect(unicred.complemento_trailer).to eq "#{total_cobranca_simples}#{total_cobranca_vinculada}"\
        "#{total_cobranca_caucionada}#{total_cobranca_descontada}".ljust(217, ' ')
    end

    it 'formata o nosso numero' do
      nosso_numero = unicred.formata_nosso_numero "072000031"
      expect(nosso_numero.strip).to eq "072000031"
    end
  end

  context 'geracao remessa' do
    it_behaves_like 'cnab240'

    context 'arquivo' do
      it { expect(unicred.gera_arquivo).to eq(read_remessa('remessa-unicred-cnab240.rem', unicred.gera_arquivo)) }
    end
  end
end
