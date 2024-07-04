# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Santander do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                       data_vencimento: Date.current,
                                       nosso_numero: 1_234_567,
                                       documento: 9999,
                                       documento_sacado: '12345678901',
                                       nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
                                       endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
                                       bairro_sacado: 'São josé dos quatro apostolos magros',
                                       cep_sacado: '12345678',
                                       cidade_sacado: 'Santa rita de cássia maria da silva',
                                       uf_sacado: 'SP',
                                       numero: '123',
                                       codigo_baixa: '3',
                                       dias_baixa: '0')
  end
  let(:params) do
    { empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '28254225000193',
      codigo_transmissao: '000100001234567',
      agencia: '0001',
      conta_corrente: '013001234',
      digito_conta: '3',
      sequencial_remessa: '1',
      pagamentos: [pagamento] }
  end
  let(:santander) { subject.class.new(params) }

  context 'validacoes' do
    context '@codigo_transmissao' do
      it 'deve ser invalido se nao possuir o codigo_transmissao' do
        object = subject.class.new(params.merge!(codigo_transmissao: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Codigo transmissao não pode estar em branco.')
      end

      it 'deve ser invalido se o codigo_transmissao tiver mais de 15 digitos' do
        santander.codigo_transmissao = '01234567890123456789'
        expect(santander.invalid?).to be true
        expect(santander.errors.full_messages).to include('Codigo transmissao deve ter no máximo 15 dígitos.')
      end
    end

    context '@agencia' do
      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        santander.agencia = '12345'
        expect(santander.invalid?).to be true
        expect(santander.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se a conta_corrente tiver mais de 9 digitos' do
        santander.conta_corrente = '1234567890'
        expect(santander.invalid?).to be true
        expect(santander.errors.full_messages).to include('Conta corrente deve ter 9 dígitos.')
      end
    end
  end

  context 'formatacoes' do
    it 'codigo do banco deve ser 033' do
      expect(santander.cod_banco).to eq '033'
    end

    it 'nome do banco deve BANCO SANTANDER com 30 posicoes' do
      nome_banco = santander.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..14]).to eq 'BANCO SANTANDER'
    end

    it 'versao do layout do arquivo deve ser 040' do
      expect(santander.versao_layout_arquivo).to eq '040'
    end

    it 'versao do layout do lote deve ser 030' do
      expect(santander.versao_layout_lote).to eq '030'
    end

    it 'convenio lote deve retornar as informacoes nas posicoes corretas' do
      convenio_lote = santander.convenio_lote
      expect(convenio_lote[0..19]).to eq ''.rjust(20, ' ')
      expect(convenio_lote[20..34]).to eq '000100001234567'
      expect(convenio_lote[35..40]).to eq ''.rjust(5, ' ')
    end

    it 'codigo convenio deve retornar as informacoes nas posicoes corretas' do
      codigo_convenio = santander.codigo_convenio
      expect(codigo_convenio[0..14]).to eq '000100001234567'
      expect(codigo_convenio[15..40]).to eq ''.rjust(25, ' ')
    end

    it 'info conta deve retornar branco' do
      expect(santander.info_conta).to eq ''
    end

    it 'complemento header deve retornar espacos em branco' do
      expect(santander.complemento_header).to eq ''.rjust(29, ' ')
    end

    it 'complemento trailer deve retornar espacos em branco' do
      expect(santander.complemento_trailer).to eq ''.rjust(217, ' ')
    end

    it 'identificador do titulo deve ter as informacoes nas posicoes corretas' do
      identificador = santander.identificador_titulo(1_234_567)
      expect(identificador).to eq '0000012345679'
    end
  end

  context 'geracao remessa' do
    before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }

    after { Timecop.return }

    context 'header arquivo' do
      it 'header arquivo deve ter 240 posicoes' do
        expect(santander.monta_header_arquivo.size).to eq 240
      end

      it 'header arquivo deve ter as informacoes nas posicoes corretas' do
        header = santander.monta_header_arquivo
        expect(header[0..2]).to eq santander.cod_banco # cod. do banco
        expect(header[16]).to eq '2' # tipo inscricao do cedente
        expect(header[18..31]).to eq '28254225000193' # documento do cedente
        expect(header[32..71]).to eq santander.codigo_convenio # informacoes do convenio
        expect(header[72..101]).to eq 'SOCIEDADE BRASILEIRA DE ZOOLOG' # razao social do cedente
        expect(header[157..162]).to eq '000001' # sequencial de remessa
        expect(header[163..165]).to eq santander.versao_layout_arquivo # versao do layout
      end
    end

    context 'header lote' do
      it 'header lote deve ter 240 posicoes' do
        expect(santander.monta_header_lote(1).size).to eq 240
      end

      it 'header lote deve ter as informacoes nas posicoes corretas' do
        header = santander.monta_header_lote(1)
        expect(header[0..2]).to eq santander.cod_banco # cod. do banco
        expect(header[3..6]).to eq '0001' # numero do lote
        expect(header[13..15]).to eq santander.versao_layout_lote # versao do layout
        expect(header[17]).to eq '2' # tipo inscricao do cedente
        expect(header[18..32]).to eq '028254225000193' # documento do cedente
        expect(header[33..72]).to eq santander.convenio_lote # informacoes do convenio
        expect(header[73..102]).to eq 'SOCIEDADE BRASILEIRA DE ZOOLOG' # razao social do cedente
        expect(header[103..142]).to eq ''.rjust(40, ' ') # 1a mensagem
        expect(header[143..182]).to eq ''.rjust(40, ' ') # 2a mensagem
        expect(header[183..190]).to eq '00000001' # sequencial de remessa
      end
    end

    context 'segmento P' do
      it 'segmento P deve ter 240 posicoes' do
        expect(santander.monta_segmento_p(pagamento, 1, 2).size).to eq 240
      end

      it 'segmento P deve ter as informacos nas posicoes corretas' do
        segmento_p = santander.monta_segmento_p(pagamento, 1, 2)
        expect(segmento_p[0..2]).to eq santander.cod_banco # codigo do banco
        expect(segmento_p[3..6]).to eq '0001' # numero do lote
        expect(segmento_p[8..12]).to eq '00002' # sequencial do registro no lote
        expect(segmento_p[17..20]).to eq santander.agencia # agencia
        expect(segmento_p[21]).to eq santander.digito_agencia.to_s # digito da agencia
        expect(segmento_p[22..56]).to eq santander.complemento_p(pagamento) # complemento do segmento P
        expect(segmento_p[62..76]).to eq '9999           ' # numero do documento
        expect(segmento_p[77..84]).to eq Date.current.strftime('%d%m%Y') # data de vencimento
        expect(segmento_p[85..99]).to eq '000000000019990' # valor
        expect(segmento_p[109..116]).to eq Date.current.strftime('%d%m%Y') # data de emissao
        expect(segmento_p[141]).to eq '0' # codigo do desconto
        expect(segmento_p[142..149]).to eq '00000000' # data de desconto
        expect(segmento_p[150..164]).to eq ''.rjust(15, '0') # valor do desconto
        expect(segmento_p[165..179]).to eq ''.rjust(15, '0') # valor do IOF
        expect(segmento_p[180..194]).to eq ''.rjust(15, '0') # valor do abatimento
      end

      it 'segmento P deve ter as informações sobre o protesto' do
        pagamento.codigo_protesto = '3'
        pagamento.dias_protesto = '6'
        segmento_p = santander.monta_segmento_p(pagamento, 1, 2)

        expect(segmento_p[220]).to eq '3'
        expect(segmento_p[221..222]).to eq '06'
      end
    end

    context 'segmento Q' do
      it 'segmento Q deve ter 240 posicoes' do
        expect(santander.monta_segmento_q(pagamento, 1, 3).size).to eq 240
      end

      it 'segmento Q deve ter as informacoes nas posicoes corretas' do
        segmento_q = santander.monta_segmento_q(pagamento, 1, 3)
        expect(segmento_q[0..2]).to eq santander.cod_banco # codigo do banco
        expect(segmento_q[3..6]).to eq '0001' # numero do lote
        expect(segmento_q[8..12]).to eq '00003' # numero do registro no lote
        expect(segmento_q[17]).to eq '1' # tipo inscricao sacado
        expect(segmento_q[18..32]).to eq '000012345678901' # documento do sacado
        expect(segmento_q[33..72]).to eq 'PABLO DIEGO JOSE FRANCISCO DE PAULA JUAN' # nome do sacado
        expect(segmento_q[73..112]).to eq 'RUA RIO GRANDE DO SUL Sao paulo Minas ca' # endereco do sacado
        expect(segmento_q[113..127]).to eq 'Sao jose dos qu' # bairro do sacado
        expect(segmento_q[128..132]).to eq '12345' # CEP do sacado
        expect(segmento_q[133..135]).to eq '678' # sufixo CEP do sacado
        expect(segmento_q[136..150]).to eq 'Santa rita de c' # cidade do sacado
        expect(segmento_q[151..152]).to eq 'SP' # UF do sacado
      end
    end

    context 'segmento R' do
      it 'segmento R deve ter 240 posicoes' do
        expect(santander.monta_segmento_r(pagamento, 1, 4).size).to eq 240
      end

      it 'segmento R deve ter as informacoes nas posicoes corretas' do
        segmento_r = santander.monta_segmento_r(pagamento, 1, 4)
        expect(segmento_r[0..2]).to eq santander.cod_banco # codigo banco
        expect(segmento_r[3..6]).to eq '0001'                   # lote de servico
        expect(segmento_r[7]).to eq '3'                         # tipo de registro
        expect(segmento_r[8..12]).to eq '00004'                 # nro seq. registro no lote
        expect(segmento_r[13]).to eq 'R'                        # cod. segmento
        expect(segmento_r[14]).to eq ' '                        # branco
        expect(segmento_r[15..16]).to eq '01'                   # cod. movimento remessa
        expect(segmento_r[17..40]).to eq ''.rjust(24,  '0')   # desconto 2
        expect(segmento_r[41..64]).to eq ''.rjust(24,  '0')   # desconto 3
        expect(segmento_r[65]).to eq '0'                        # cod. multa
        expect(segmento_r[66..73]).to eq ''.rjust(8, '0')       # data multa
        expect(segmento_r[74..88]).to eq ''.rjust(15, '0')      # valor multa
        expect(segmento_r[89..98]).to eq ''.rjust(10, ' ')      # info pagador
        expect(segmento_r[99..138]).to eq ''.rjust(40, ' ')     # mensagem 3
        expect(segmento_r[139..178]).to eq ''.rjust(40, ' ')    # mensagem 4
        expect(segmento_r[179..239]).to eq santander.complemento_r # complemento do segmento
      end
    end

    context 'trailer lote' do
      it 'trailer lote deve ter 240 posicoes' do
        expect(santander.monta_trailer_lote(1, 4).size).to eq 240
      end

      it 'trailer lote deve ter as informacoes nas posicoes corretas' do
        trailer = santander.monta_trailer_lote(1, 4)
        expect(trailer[0..2]).to eq santander.cod_banco # cod. do banco
        expect(trailer[3..6]).to eq '0001' # numero do lote
        expect(trailer[17..22]).to eq '000004' # qtde de registros no lote
        expect(trailer[23..239]).to eq santander.complemento_trailer # complemento do registro trailer
      end
    end

    context 'trailer arquivo' do
      it 'trailer arquivo deve ter 240 posicoes' do
        expect(santander.monta_trailer_arquivo(1, 6).size).to eq 240
      end

      it 'trailer arquivo deve ter as informacoes nas posicoes corretas' do
        trailer = santander.monta_trailer_arquivo(1, 6)
        expect(trailer[0..2]).to eq santander.cod_banco # cod. do banco
        expect(trailer[17..22]).to eq '000001' # qtde de lotes
        expect(trailer[23..28]).to eq '000006' # qtde de registros
      end
    end

    context 'monta lote' do
      it 'retorno de lote deve ser uma colecao com os registros' do
        lote = santander.monta_lote(1)

        expect(lote.is_a?(Array)).to be true
        expect(lote.count).to be 5 # header, segmento p, segmento q, segmento r e trailer
      end

      it 'contador de registros deve acrescer 1 a cada registro' do
        lote = santander.monta_lote(1)

        expect(lote[1][8..12]).to eq '00001' # segmento P
        expect(lote[2][8..12]).to eq '00002' # segmento Q
        expect(lote[3][8..12]).to eq '00003' # segmento R
        expect(lote[4][17..22]).to eq '000005' # trailer do lote
      end
    end

    context 'gera arquivo' do
      it 'deve falhar se o objeto for invalido' do
        expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
      end

      it 'remessa deve conter os registros mais as quebras de linha' do
        remessa = santander.gera_arquivo

        expect(remessa.size).to eq 1694
        # quebras de linha
        expect(remessa[240..241]).to eq "\r\n"
        expect(remessa[482..483]).to eq "\r\n"
        expect(remessa[724..725]).to eq "\r\n"
        expect(remessa[966..967]).to eq "\r\n"
        expect(remessa[1208..1209]).to eq "\r\n"
      end

      it { expect(santander.gera_arquivo).to eq(read_remessa('remessa-santander-cnab240.rem', santander.gera_arquivo)) }
    end
  end
end
