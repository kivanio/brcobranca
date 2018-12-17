# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::SicoobBancoBrasil do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(
      valor: 50.0,
      data_vencimento: Date.current,
      nosso_numero: '1234567',
      documento: 6969,
      documento_sacado: '82136760505',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      documento_avalista: '12345678901',
      nome_avalista: 'ISABEL CRISTINA LEOPOLDINA ALGUSTA MIGUELA GABRIELA RAFAELA GONZAGA DE BRAGANÇA E BOURBON',
      uf_sacado: 'SP'
    )
  end

  let(:params) do
    {
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      agencia: '4327',
      convenio: '1234567890',
      conta_corrente: '1234567890',
      codigo_cobranca: '1234567',
      documento_cedente: '74576177000177',
      sequencial_remessa: '1',
      pagamentos: [pagamento]
    }
  end

  let(:sicoob_banco_brasil) { subject.class.new(params) }

  context 'validacoes' do
    context '@agencia' do
      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        sicoob_banco_brasil.agencia = '12345'
        expect(sicoob_banco_brasil.invalid?).to be true
        expect(sicoob_banco_brasil.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@codigo_cobranca' do
      it 'deve ser invalido se o codigo cobranca tiver mais de 7 digitos' do
        sicoob_banco_brasil.codigo_cobranca = '12345678'
        expect(sicoob_banco_brasil.invalid?).to be true
        expect(sicoob_banco_brasil.errors.full_messages).to include('Codigo cobranca deve ter 7 dígitos.')
      end
    end

    context '@convenio' do
      it 'deve ser invalido se a convenio tiver mais de 10 digitos' do
        sicoob_banco_brasil.convenio = '12345678901'
        expect(sicoob_banco_brasil.invalid?).to be true
        expect(sicoob_banco_brasil.errors.full_messages).to include('Convenio deve ter 10 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se a conta corrente tiver mais de 10 digitos' do
        sicoob_banco_brasil.conta_corrente = '12345678901'
        expect(sicoob_banco_brasil.invalid?).to be true
        expect(sicoob_banco_brasil.errors.full_messages).to include('Conta corrente deve ter 10 dígitos.')
      end
    end

    context '@sequencial_remessa' do
      it 'deve ser invalido se não for informado' do
        sicoob_banco_brasil.sequencial_remessa = nil
        expect(sicoob_banco_brasil.invalid?).to be true
        expect(sicoob_banco_brasil.errors.full_messages).to include('Sequencial remessa não pode estar em branco.')
      end

      it 'deve ser invalido se o sequencial remessa tiver mais de 8 digitos' do
        sicoob_banco_brasil.sequencial_remessa = '123456789'
        expect(sicoob_banco_brasil.invalid?).to be true
        expect(sicoob_banco_brasil.errors.full_messages).to include('Sequencial remessa deve ter 8 dígitos.')
      end
    end

  end

  context 'formatacoes' do
    it 'codigo do banco deve ser 756' do
      expect(sicoob_banco_brasil.cod_banco).to eq '756'
    end

    it 'cod. cobranca deve retornar as informacoes nas posicoes corretas' do
      expect(sicoob_banco_brasil.codigo_cobranca).to eq '1234567'
    end

    it 'info conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = sicoob_banco_brasil.info_conta
      expect(info_conta[0..3]).to eq '4327'           # Agencia
      expect(info_conta[4..10]).to eq '1234567'       # Codigo cobranca
      expect(info_conta[11..21]).to eq '12345678900'  # Conta
    end

    it 'complemento header deve retornar zeros e espacos em branco' do
      info_header = sicoob_banco_brasil.complemento_header
      expect(info_header[0..10]).to eq ''.rjust(11, '0')
      expect(info_header[11..43]).to eq ''.rjust(33, ' ')
    end

    it 'formata o nosso numero' do
      nosso_numero = sicoob_banco_brasil.formata_nosso_numero 1
      expect(nosso_numero).to eq "12345678900000001"
    end
  end

  context 'header do arquivo' do
    it 'deve ter 240 posicoes' do
      expect(sicoob_banco_brasil.monta_header_arquivo.size).to eq 240
    end

    it 'header arquivo deve ter as informacoes nas posicoes corretas' do
      header = sicoob_banco_brasil.monta_header_arquivo
      expect(header[0..2]).to eq sicoob_banco_brasil.cod_banco        # cod. do banco
      expect(header[3..6]).to eq '0000'                               # cod. do banco
      expect(header[7]).to eq '1'                                     # reg. header do lote
      expect(header[8]).to eq 'R'                                     # tipo da operacao R - remessa
      expect(header[9..15]).to eq ''.rjust(7, '0')                    # zeros
      expect(header[16..17]).to eq '  '                               # brancos
      expect(header[18..39]).to eq sicoob_banco_brasil.info_conta     # informacoes da conta
      expect(header[40..69]).to eq ''.rjust(30, ' ')                  # brancos
      expect(header[70..99]).to eq 'SOCIEDADE BRASILEIRA DE ZOOLOG'   # razao social do cedente
      expect(header[100..179]).to eq ''.rjust(80, ' ')                # brancos
      expect(header[180..187]).to eq '00000001'                       # sequencial de remessa
      expect(header[188..195]).to eq Date.current.strftime('%d%m%Y')    # data gravacao
      expect(header[196..206]).to eq ''.rjust(11, '0')                # zeros
      expect(header[207..239]).to eq ''.rjust(33, ' ')                # brancos
    end
  end

  context 'segmento P' do
    it 'segmento P deve ter 240 posicoes' do
      expect(sicoob_banco_brasil.monta_segmento_p(pagamento, 2).size).to eq 240
    end

    it 'segmento P deve ter as informacos nas posicoes corretas' do
      segmento_p = sicoob_banco_brasil.monta_segmento_p(pagamento, 2)
      expect(segmento_p[0..6]).to eq ''.rjust(7, '0')                 # zeros
      expect(segmento_p[7]).to eq '3'                                 # tipo do registro
      expect(segmento_p[8..12]).to eq '00002'                         # sequencial do registro no lote
      expect(segmento_p[13]).to eq 'P'                                # cod. segmento
      expect(segmento_p[14]).to eq ' '                                # brancos
      expect(segmento_p[15..16]).to eq '01'                           # codigo da instrucao
      expect(segmento_p[17..39]).to eq ''.rjust(23, ' ')              # brancos
      expect(segmento_p[40..56]).to eq '12345678901234567'            # nosso_numero
      expect(segmento_p[57]).to eq '9'                                # carteira
      expect(segmento_p[58..59]).to eq '02'                           # tipo documento
      expect(segmento_p[60]).to eq '2'                                # emissao boleto
      expect(segmento_p[61]).to eq ' '                                # branco
      expect(segmento_p[62..76]).to eq '000000001234567'              # numero do documento de cobranca
      expect(segmento_p[77..84]).to eq Date.current.strftime('%d%m%Y')  # data de vencimento
      expect(segmento_p[85..99]).to eq '000000000005000'              # valor do documento
      expect(segmento_p[100..105]).to eq ''.rjust(6, '0')             # zeros
      expect(segmento_p[106]).to eq 'N'                               # aceite
      expect(segmento_p[107..108]).to eq '  '                         # brancos
      expect(segmento_p[109..116]).to eq Date.current.strftime('%d%m%Y')# data de emissao
      expect(segmento_p[117]).to eq '1'                               # tipo da mora
      expect(segmento_p[118..132]).to eq ''.rjust(15, '0')            # valor juros/mora
      expect(segmento_p[133..141]).to eq ''.rjust(9, '0')             # zeros
      expect(segmento_p[142..149]).to eq ''.rjust(8, '0')             # data de desconto
      expect(segmento_p[150..164]).to eq ''.rjust(15, '0')            # valor do desconto
      expect(segmento_p[165..179]).to eq ''.rjust(15, ' ')            # brancos
      expect(segmento_p[180..194]).to eq '000000000000000'            # valor do abatimento
      expect(segmento_p[195..219]).to eq ''.rjust(25, ' ')            # brancos
      expect(segmento_p[220]).to eq '0'                               # protesto automatico
      expect(segmento_p[221..222]).to eq '00'                         # dias para prostesto
      expect(segmento_p[223..226]).to eq '0000'                       # zeros
      expect(segmento_p[227..228]).to eq '09'                         # dias para prostesto
      expect(segmento_p[229..238]).to eq ''.rjust(10, '0')            # n. contr. da operacao de credito
      expect(segmento_p[239]).to eq '0'                               # zero
    end
  end

  context 'segmento Q' do
    it 'segmento Q deve ter 240 posicoes' do
      expect(sicoob_banco_brasil.monta_segmento_q(pagamento, 3).size).to eq 240
    end

    it 'segmento Q deve ter as informacoes nas posicoes corretas' do
      segmento_q = sicoob_banco_brasil.monta_segmento_q(pagamento, 3)
      expect(segmento_q[0..6]).to eq ''.rjust(7, '0')                 # zeros
      expect(segmento_q[7]).to eq '3'                                 # registo detalhe
      expect(segmento_q[8..12]).to eq '00003'                         # numero do registro no lote
      expect(segmento_q[13]).to eq 'Q'                                # cod. segmento
      expect(segmento_q[14]).to eq ' '                                # brancos
      expect(segmento_q[15..16]).to eq '01'                           # codigo instrucao
      expect(segmento_q[17..18]).to eq '01'                           # tipo insc. sacado
      expect(segmento_q[19..32]).to eq '00082136760505'               # documento sacado
      expect(segmento_q[33..72]).to eq 'PABLO DIEGO JOSE FRANCISCO DE PAULA JUAN'  # nome do sacado
      expect(segmento_q[73..112]).to eq 'RUA RIO GRANDE DO SUL Sao paulo Minas ca' # endereco do sacado
      expect(segmento_q[113..127]).to eq 'Sao jose dos qu'            # bairro do sacado
      expect(segmento_q[128..132]).to eq '12345'                      # CEP do sacado
      expect(segmento_q[133..135]).to eq '678'                        # sufixo CEP do sacado
      expect(segmento_q[136..150]).to eq 'Santa rita de c'            # cidade do sacado
      expect(segmento_q[151..152]).to eq 'SP'                         # UF do sacado
      expect(segmento_q[153..154]).to eq '01'                         # tipo inscricao avalista
      expect(segmento_q[155..168]).to eq '00012345678901'             # documento avalista
      expect(segmento_q[169..208]).to eq 'ISABEL CRISTINA LEOPOLDINA ALGUSTA MIGUE' # nome do avalista
      expect(segmento_q[209..239]).to eq ''.rjust(31, ' ')              # brancos
    end
  end

  context 'trailer arquivo' do
    it 'trailer arquivo deve ter 240 posicoes' do
      expect(sicoob_banco_brasil.monta_trailer_arquivo(1, 5).size).to eq 240
    end

    it 'trailer arquivo deve ter as informacoes nas posicoes corretas' do
      trailer = sicoob_banco_brasil.monta_trailer_arquivo 1, 5
      expect(trailer[0..6]).to eq ''.rjust(7, '0')                  # zeros
      expect(trailer[7]).to eq '5'                                  # registo detalhe
      expect(trailer[8..16]).to eq ''.rjust(9, ' ')                 # brancos
      expect(trailer[17..22]).to eq '000001'                        # qtde de registros do lote
      expect(trailer[23..39]).to eq '00000000000005000'             # valor total dos titulos do lote
      expect(trailer[40..45]).to eq ''.rjust(6, '0')                # zeros
      expect(trailer[46..239]).to eq ''.rjust(194, ' ')             # brancos
    end
  end

  context 'monta lote' do
    it 'retorno de lote deve ser uma colecao com os registros' do
      lote = sicoob_banco_brasil.monta_lote(1)

      expect(lote.is_a?(Array)).to be true
      expect(lote.count).to be 2 # segmento p e segmento q
    end

    it 'contador de registros deve acrescer 1 a cada registro' do
      lote = sicoob_banco_brasil.monta_lote(1)

      expect(lote[0][8..12]).to eq '00001' # segmento P
      expect(lote[1][8..12]).to eq '00002' # segmento Q
    end
  end

  context 'gera arquivo' do
    it 'deve falhar se o sicoob_banco_brasil for invalido' do
      expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
    end

    it 'remessa deve conter os registros mais as quebras de linha' do
      remessa = sicoob_banco_brasil.gera_arquivo

      expect(remessa.size).to eq 966
      # quebras de linha
      expect(remessa[240..241]).to eq "\r\n"
      expect(remessa[482..483]).to eq "\r\n"
      expect(remessa[724..725]).to eq "\r\n"
    end
  end

  context 'geracao remessa' do
    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(sicoob_banco_brasil.gera_arquivo).to eq(read_remessa('remessa-sicoob-correspondente-bb-cnab240.rem', sicoob_banco_brasil.gera_arquivo)) }
    end
  end
end
