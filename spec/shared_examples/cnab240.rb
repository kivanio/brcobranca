shared_examples_for 'cnab240' do
  let(:pagamento) { Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                                       data_vencimento: Date.today,
                                                       nosso_numero: 123,
                                                       documento_sacado: '12345678901',
                                                       nome_sacado: 'nome',
                                                       endereco_sacado: 'endereco',
                                                       bairro_sacado: 'bairro',
                                                       cep_sacado: '12345678',
                                                       cidade_sacado: 'cidade',
                                                       uf_sacado: 'SP',
                                                       valor_iof: 9.9,
                                                       valor_abatimento: 24.35,
                                                       documento_avalista: '12345678901',
                                                       nome_avalista: 'avalista') }
  let(:params) do
    p = {empresa_mae: 'teste',
         agencia: '1234',
         conta_corrente: '12345',
         documento_cedente: '12345678901',
         convenio: '123456',
         sequencial_remessa: '1',
         mensagem_1: 'mensagem 1',
         mensagem_2: 'mensagem 2',
         pagamentos: [pagamento]}
    if subject.class == Brcobranca::Remessa::Cnab240::Caixa then
      p.merge!({versao_aplicativo: '1234',
                digito_agencia: '1'})
    else
      p.merge!({carteira: '12',
                variacao: '123'})
    end
  end
  let(:objeto) { subject.class.new(params) }

  context 'header arquivo' do
    it 'header arquivo deve ter 240 posicoes' do
      expect(objeto.monta_header_arquivo.size).to eq 240
    end

    it 'header arquivo deve ter as informacoes nas posicoes corretas' do
      header = objeto.monta_header_arquivo
      expect(header[0..2]).to eq objeto.cod_banco            # cod. do banco
      expect(header[17]).to eq '1'                           # tipo inscricao do cedente
      expect(header[18..31]).to eq '00012345678901'          # documento do cedente
      expect(header[32..51]).to eq objeto.codigo_convenio    # informacoes do convenio
      expect(header[52..71]).to eq objeto.info_conta         # informacoes da conta
      expect(header[72..101]).to eq 'TESTE'.ljust(30, ' ')   # razao social do cedente
      expect(header[157..162]).to eq '000001'                # sequencial de remessa
      expect(header[163..165]).to eq objeto.versao_layout    # versao do layout
    end
  end

  context 'header lote' do
    it 'header lote deve ter 240 posicoes' do
      expect(objeto.monta_header_lote(1).size).to eq 240
    end

    it 'header lote deve ter as informacoes nas posicoes corretas' do
      header = objeto.monta_header_lote 1
      expect(header[0..2]).to eq objeto.cod_banco                   # cod. do banco
      expect(header[3..6]).to eq '0001'                             # numero do lote
      expect(header[13..15]).to eq objeto.versao_layout             # versao do layout
      expect(header[17]).to eq '1'                                  # tipo inscricao do cedente
      expect(header[18..32]).to eq '000012345678901'                # documento do cedente
      expect(header[33..52]).to eq objeto.convenio_lote             # informacoes do convenio
      expect(header[53..72]).to eq objeto.info_conta                # informacoes da conta
      expect(header[73..102]).to eq 'TESTE'.ljust(30, ' ')          # razao social do cedente
      expect(header[103..142]).to eq 'MENSAGEM 1'.ljust(40, ' ')    # 1a mensagem
      expect(header[143..182]).to eq 'MENSAGEM 2'.ljust(40, ' ')    # 2a mensagem
      expect(header[183..190]).to eq '00000001'                     # sequencial de remessa
    end
  end

  context 'segmento P' do
    it 'segmento P deve ter 240 posicoes' do
      expect(objeto.monta_segmento_p(pagamento, 1, 2).size).to eq 240
    end

    it 'segmento P deve ter as informacos nas posicoes corretas' do
      segmento_p = objeto.monta_segmento_p pagamento, 1, 2
      expect(segmento_p[0..2]).to eq objeto.cod_banco                   # codigo do banco
      expect(segmento_p[3..6]).to eq '0001'                             # numero do lote
      expect(segmento_p[8..12]).to eq '00002'                           # sequencial do registro no lote
      expect(segmento_p[17..21]).to eq '01234'                          # agencia
      expect(segmento_p[22]).to eq objeto.digito_agencia.to_s           # digito da agencia
      expect(segmento_p[23..56]).to eq objeto.complemento_p(pagamento)  # complemento do segmento P
      expect(segmento_p[62..72]).to eq '00000000123'                    # nosso numero
      expect(segmento_p[77..84]).to eq Date.today.strftime('%d%m%Y')    # data de vencimento
      expect(segmento_p[85..99]).to eq '000000000019990'                # valor
      expect(segmento_p[109..116]).to eq Date.today.strftime('%d%m%Y')  # data de emissao
      # mora
      expect(segmento_p[141]).to eq '0'                                 # codigo do desconto
      expect(segmento_p[142..149]).to eq '00000000'                     # data de desconto
      expect(segmento_p[150..164]).to eq ''.rjust(15, '0')              # valor do desconto
      expect(segmento_p[165..179]).to eq '000000000000990'              # valor do IOF
      expect(segmento_p[180..194]).to eq '000000000002435'              # valor do abatimento
    end
  end

  context 'segmento Q' do
    it 'segmento Q deve ter 240 posicoes' do
      expect(objeto.monta_segmento_q(pagamento, 1, 3).size).to eq 240
    end

    it 'segmento Q deve ter as informacoes nas posicoes corretas' do
      segmento_q = objeto.monta_segmento_q pagamento, 1, 3
      expect(segmento_q[0..2]).to eq objeto.cod_banco                # codigo do banco
      expect(segmento_q[3..6]).to eq '0001'                          # numero do lote
      expect(segmento_q[8..12]).to eq '00003'                        # numero do registro no lote
      expect(segmento_q[17]).to eq '1'                               # tipo inscricao sacado
      expect(segmento_q[18..32]).to eq '000012345678901'             # documento do sacado
      expect(segmento_q[33..72]).to eq 'NOME'.ljust(40, ' ')         # nome do sacado
      expect(segmento_q[73..112]).to eq 'ENDERECO'.ljust(40, ' ')    # endereco do sacado
      expect(segmento_q[113..127]).to eq 'BAIRRO'.ljust(15, ' ')     # bairro do sacado
      expect(segmento_q[128..132]).to eq '12345'                     # CEP do sacado
      expect(segmento_q[133..135]).to eq '678'                       # sufixo CEP do sacado
      expect(segmento_q[136..150]).to eq 'CIDADE'.ljust(15, ' ')     # cidade do sacado
      expect(segmento_q[151..152]).to eq 'SP'                        # UF do sacado
      expect(segmento_q[153]).to eq '1'                              # tipo inscricao avalista
      expect(segmento_q[154..168]).to eq '000012345678901'           # documento avalista
      expect(segmento_q[169..208]).to eq 'AVALISTA'.ljust(40, ' ')   # nome do avalista
    end
  end

  context 'trailer lote' do
    it 'trailer lote deve ter 240 posicoes' do
      expect(objeto.monta_trailer_lote(1, 4).size).to eq 240
    end

    it 'trailer lote deve ter as informacoes nas posicoes corretas' do
      trailer = objeto.monta_trailer_lote 1, 4
      expect(trailer[0..2]).to eq objeto.cod_banco                # cod. do banco
      expect(trailer[3..6]).to eq '0001'                          # numero do lote
      expect(trailer[17..22]).to eq '000004'                      # qtde de registros no lote
      expect(trailer[23..239]).to eq objeto.complemento_trailer   # complemento do registro trailer
    end
  end

  context 'trailer arquivo' do
    it 'trailer arquivo deve ter 240 posicoes' do
      expect(objeto.monta_trailer_arquivo(1, 6).size).to eq 240
    end

    it 'trailer arquivo deve ter as informacoes nas posicoes corretas' do
      trailer = objeto.monta_trailer_arquivo 1, 6
      expect(trailer[0..2]).to eq objeto.cod_banco   # cod. do banco
      expect(trailer[17..22]).to eq '000001'         # qtde de lotes
      expect(trailer[23..28]).to eq '000006'         # qtde de registros
    end
  end

  context 'monta lote' do
    it 'deve falhar se o pagamento passado nao for valido' do
      expect { objeto.monta_lote(Brcobranca::Remessa::Pagamento.new, 1) }.to raise_error(Brcobranca::RemessaInvalida)
    end

    it 'retorno de lote deve ser uma colecao com os registros' do
      lote = objeto.monta_lote pagamento, 1

      expect(lote.is_a?(Array)).to be true
      expect(lote.count).to be 4  # header, segmento p, segmento q e trailer
    end

    it 'contador de registros deve acrescer 1 a cada registro' do
      lote = objeto.monta_lote pagamento, 1

      expect(lote[1][8..12]).to eq '00002'     # segmento P
      expect(lote[2][8..12]).to eq '00003'     # segmento Q
      expect(lote[3][17..22]).to eq '000004'   # trailer do lote
    end
  end

  context 'gera arquivo' do
    it 'deve falhar se o objeto for invalido' do
      expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
    end

    it 'remessa deve conter os registros mais as quebras de linha' do
      remessa = objeto.gera_arquivo

      expect(remessa.size).to eq 1450
      # quebras de linha
      expect(remessa[240..241]).to eq '\n'
      expect(remessa[482..483]).to eq '\n'
      expect(remessa[724..725]).to eq '\n'
      expect(remessa[966..967]).to eq '\n'
      expect(remessa[1208..1209]).to eq '\n'
    end

    it 'pode ser adicionado varios lotes' do
      objeto.pagamentos << pagamento
      remessa = objeto.gera_arquivo
      lote1 = remessa[242..1207]
      lote2 = remessa[1210..2175]

      # 10 registros (2400) + 9 quebras de linha (18)
      expect(remessa.size).to eq 2418
      expect(lote1).to eq objeto.monta_lote(pagamento, 1).join('\n')
      expect(lote2).to eq objeto.monta_lote(pagamento, 2).join('\n')
    end
  end
end