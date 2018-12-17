# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Caixa do
  before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
  after { Timecop.return }

  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.current,
      nosso_numero: 123,
      numero: 123,
      documento: 6969,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      tipo_mora: "1",
      codigo_multa: "2",
      uf_sacado: 'SP')
  end
  let(:params) do
    { empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      agencia: '12345',
      conta_corrente: '1234',
      versao_aplicativo: '1234',
      documento_cedente: '12345678901',
      convenio: '123456',
      digito_agencia: '1',
      sequencial_remessa: '000001',
      pagamentos: [pagamento] }
  end
  let(:caixa) { subject.class.new(params) }

  context 'validacoes' do
    context '@digito_agencia' do
      it 'deve ser invalido se nao possuir o digito da agencia' do
        objeto = subject.class.new(params.merge!(digito_agencia: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Digito agencia não pode estar em branco.')
      end

      it 'deve ser invalido se o digito da agencia nao tiver 1 digito' do
        caixa.digito_agencia = '12'
        expect(caixa.invalid?).to be true
        expect(caixa.errors.full_messages).to include('Digito agencia deve ter 1 dígito.')
      end
    end

    context '@convenio' do
      it 'deve ser invalido se nao possuir o convenio' do
        objeto = subject.class.new(params.merge!(convenio: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Convenio não pode estar em branco.')
      end

      it 'deve ser invalido se o convenio tiver mais de 6 digitos' do
        caixa.convenio = '1234567'
        expect(caixa.invalid?).to be true
        expect(caixa.errors.full_messages).to include('Convenio deve ter 6 dígitos.')
      end
    end

    context '@modalidade_carteira' do
      it 'padrao da modalidade deve ser 14' do
        expect(subject.class.new.modalidade_carteira).to eq '14'
      end

      it 'deve ser invalido se a modalidade de carteira tiver mais de 2 digitos' do
        caixa.modalidade_carteira = '123'
        expect(caixa.invalid?).to be true
        expect(caixa.errors.full_messages).to include('Modalidade carteira deve ter 2 dígitos.')
      end
    end
  end

  context 'formatacao' do
    it 'codigo do banco deve retornar 104' do
      expect(caixa.cod_banco).to eq '104'
    end

    it 'nome do banco deve ser Caixa com 30 posicoes' do
      nome_banco = caixa.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..22]).to eq 'CAIXA ECONOMICA FEDERAL'
    end

    it 'versao do layout do arquivo deve retornar 050' do
      expect(caixa.versao_layout_arquivo).to eq '050'
    end

    it 'versao do layout do lote deve ser 040' do
      expect(caixa.versao_layout_lote).to eq '030'
    end

    it 'codigo do convenio deve ser 20 zeros' do
      expect(caixa.codigo_convenio).to eq ''.rjust(20, '0')
    end

    it 'convenio lote deve retornar as informacoes nas posicoes corretas' do
      conv_lote = caixa.convenio_lote
      expect(conv_lote[0..5]).to eq '123456'
      expect(conv_lote[6..19]).to eq ''.rjust(14, '0')
    end

    it 'info_conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = caixa.info_conta
      expect(info_conta[0..4]).to eq '12345' # agencia
      expect(info_conta[5]).to eq '1' # digito agencia
      expect(info_conta[6..11]).to eq '123456' # convenio
    end

    it 'complemento header deve retornar as informacoes nas posicoes corretas' do
      comp_header = caixa.complemento_header
      expect(comp_header.size).to eq 29
      expect(comp_header[0..3]).to eq '1234' # versao do aplicativo
    end

    it 'complemento trailer deve retornar as informacoes nas posicoes corretas' do
      comp_trailer = caixa.complemento_trailer
      expect(comp_trailer.size).to eq 217
      expect(comp_trailer[0..68]).to eq ''.rjust(69, '0')
      expect(comp_trailer[69..216]).to eq ''.rjust(148, ' ')
    end

    it 'complemento P deve retornar as informacoes nas posicoes corretas' do
      comp_p = caixa.complemento_p pagamento
      expect(comp_p.size).to eq 34
      expect(comp_p[0..5]).to eq '123456' # convenio
      expect(comp_p[17..18]).to eq '14' # modalidade carteira
      expect(comp_p[19..33]).to eq '000000000000123' # nosso numero
    end

    it 'tipo do documento deve ser 2 - Escritural' do
      expect(caixa.tipo_documento).to eq '2'
    end

    it 'deve conter a identificacao do titulo da empresa' do
      segmento_p = caixa.monta_segmento_p(pagamento, 1, 2)
      expect(segmento_p[195..205]).to eq "00000006969"
    end

    it 'data da mora deve ser no dia posterior ao vencimento' do
      segmento_p = caixa.monta_segmento_p(pagamento, 1, 2)
      expect(segmento_p[118..125]).to eq "15072015"
    end

    it 'data da multa deve ser no dia posterior ao vencimento' do
      segmento_r = caixa.monta_segmento_r(pagamento, 1, 4)
      expect(segmento_r[66..73]).to eq "15072015"
    end
  end

  context 'geracao remessa' do
    it_behaves_like 'cnab240'

    context 'arquivo' do
      it { expect(caixa.gera_arquivo).to eq(read_remessa('remessa-caixa-cnab240.rem', caixa.gera_arquivo)) }
    end
  end
end
