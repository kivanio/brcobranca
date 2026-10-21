# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Pagamento do
  let(:pagamento) do
    subject.class.new(valor: 199.9,
                      data_vencimento: Date.parse('2015-06-25'),
                      nosso_numero: 123,
                      documento_sacado: '12345678901',
                      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
                      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
                      bairro_sacado: 'São josé dos quatro apostolos magros',
                      cep_sacado: '12345678',
                      cidade_sacado: 'Santa rita de cássia maria da silva',
                      uf_sacado: 'SP')
  end

  context 'validacoes' do
    it 'deve ser invalido se nao possuir nosso numero' do
      pagamento.nosso_numero = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Nosso numero não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir data de vencimento' do
      pagamento.data_vencimento = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Data vencimento não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir valor do documento' do
      pagamento.valor = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Valor não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir documento do sacado' do
      pagamento.documento_sacado = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Documento sacado não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir nome do sacado' do
      pagamento.nome_sacado = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Nome sacado não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir endereco do sacado' do
      pagamento.endereco_sacado = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Endereco sacado não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir cidade do sacado' do
      pagamento.cidade_sacado = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Cidade sacado não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir UF do sacado' do
      pagamento.uf_sacado = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Uf sacado não pode estar em branco.')
    end

    context '@cep' do
      it 'deve ser invalido se nao possuir CEP' do
        pagamento.cep_sacado = nil
        expect(pagamento.invalid?).to be true
        expect(pagamento.errors.full_messages).to include('Cep sacado não pode estar em branco.')
      end

      it 'deve ser invalido se CEP nao tiver 8 digitos' do
        pagamento.cep_sacado = '123456789'
        expect(pagamento.invalid?).to be true
        expect(pagamento.errors.full_messages).to include('Cep sacado deve ter 8 dígitos.')
      end
    end

    it 'deve ser invalido se codigo do desconto tiver mais de 1 digito' do
      pagamento.cod_desconto = '123'
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Cod desconto deve ter 1 dígito.')
    end

    it 'deve ser invalido se informar apenas um dos valores do Split Payment' do
      # O CBS e o IBS Informado precisam ser informados em conjunto, mesmo que
      # um deles seja zero, veja o Layout Padrao Febraban 240 posicoes V11.0
      pagamento.valor_cbs = 1.8
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Valor cbs deve ser informado em conjunto com o IBS Informado.')
    end

    it 'deve ser invalido se a soma do CBS e do IBS for superior ao valor do titulo' do
      # Codigo 'X1' dos motivos da ocorrencia, veja a pag. 85 do layout
      pagamento.valor_cbs = 100.0
      pagamento.valor_ibs = 100.0
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages)
        .to include('Valor cbs a soma do CBS e do IBS Informado não pode ser superior ao valor do título.')
    end

    it 'deve ser valido se a soma do CBS e do IBS for igual ao valor do titulo' do
      pagamento.valor_cbs = 100.0
      pagamento.valor_ibs = 99.9
      expect(pagamento.valid?).to be true
    end

    it 'deve ser valido quando a soma em Float passar do valor do titulo por arredondamento' do
      # Em Float, 0.1 + 0.2 > 0.3: a soma e comparada em centavos (inteiros)
      # para o titulo nao ser recusado por engano, veja o codigo 'X1'
      pagamento.valor = 0.3
      pagamento.valor_cbs = 0.1
      pagamento.valor_ibs = 0.2
      expect(pagamento.valid?).to be true
    end

    it 'deve ser valido quando o campo X102 arredondar o valor para dentro do titulo' do
      # 5.005 e escrito como 5.00 no campo X102: a validacao compara os
      # centavos que vao para o arquivo, e nao o Float de origem
      pagamento.valor = 5.00
      pagamento.valor_cbs = 5.005
      pagamento.valor_ibs = 0.0
      expect(pagamento.valid?).to be true
    end

    it 'deve ser invalido se a soma do CBS e do IBS for positiva em titulo de valor zero' do
      # A regra vale para o valor nominal: o valor zero do titulo nao isenta a
      # comparacao, a soma nao pode ser superior a ele
      pagamento.valor = 0.0
      pagamento.valor_cbs = 1.0
      pagamento.valor_ibs = 0.0
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages)
        .to include('Valor cbs a soma do CBS e do IBS Informado não pode ser superior ao valor do título.')
    end
  end

  context 'informacoes padrao' do
    it 'data de emissao padrao deve ser o dia corrente' do
      expect(pagamento.data_emissao).to eq Date.current
    end

    it 'nome do avalista padrao deve ser vazio' do
      expect(pagamento.nome_avalista).to eq ''
    end

    it 'valor da mora padrao deve ser zero' do
      expect(pagamento.valor_mora).to eq 0.0
    end

    it 'valor do desconto padrao deve ser zero' do
      expect(pagamento.valor_desconto).to eq 0.0
    end

    it 'valor do IOF padrao deve ser zero' do
      expect(pagamento.valor_iof).to eq 0.0
    end

    it 'valor do abatimento padrao deve ser zero' do
      expect(pagamento.valor_abatimento).to eq 0.0
    end

    it 'valores do CBS e do IBS do Split Payment nao tem valor padrao' do
      # Sem valor padrao para diferenciar "nao informado" de "informado como
      # zero", veja Brcobranca::Remessa::Pagamento#split_payment?
      expect(pagamento.valor_cbs).to be_nil
      expect(pagamento.valor_ibs).to be_nil
    end
  end

  context 'formatacoes dos valores' do
    context 'formata data do desconto' do
      it 'formata data limite do desconto de acordo com o formato passado' do
        pagamento.data_desconto = Date.parse('2015-06-25')
        # formato padrao: DDMMAA
        expect(pagamento.formata_data_desconto).to eq '250615'
        # outro formato
        expect(pagamento.formata_data_desconto('%d%m%Y')).to eq '25062015'
      end

      it 'retorna zeros se a data estiver vazia' do
        pagamento.data_desconto = nil
        expect(pagamento.formata_data_desconto).to eq '000000'
      end
    end

    it 'formata valor com o numero de posicoes passadas' do
      # padrao com 13 posicoes
      expect(pagamento.formata_valor).to eq '0000000019990'
      # formata com o numero passado
      expect(pagamento.formata_valor(8)).to eq '00019990'
    end

    it 'formata valor de mora com o numero de posicoes passadas' do
      # padrao com 13 posicoes
      pagamento.valor_mora = 9.0
      expect(pagamento.formata_valor_mora).to eq '0000000000900'
    end

    it 'formata valor de desconto com o numero de posicoes passadas' do
      # padrao com 13 posicoes
      pagamento.valor_desconto = 129.0
      expect(pagamento.formata_valor_desconto).to eq '0000000012900'
      # formata com o numero passado
      expect(pagamento.formata_valor_desconto(5)).to eq '12900'
    end

    it 'formata valor do IOF com o numero de posicoes passadas' do
      # padrao com 13 posicoes
      pagamento.valor_iof = 1.84
      expect(pagamento.formata_valor_iof).to eq '0000000000184'
      # formata com o numero passado
      expect(pagamento.formata_valor_iof(15)).to eq '000000000000184'
    end

    it 'formata valor do abatimento com o numero de posicoes passadas' do
      # padrao com 13 posicoes
      pagamento.valor_abatimento = 34.9
      expect(pagamento.formata_valor_abatimento).to eq '0000000003490'
      # formata com o numero passado
      expect(pagamento.formata_valor_abatimento(10)).to eq '0000003490'
    end

    it 'formata valor do CBS informado com o numero de posicoes passadas' do
      # padrao com 15 posicoes (13 digitos e 2 decimais), campo X102
      pagamento.valor_cbs = 1.8
      expect(pagamento.formata_valor_cbs).to eq '000000000000180'
      # formata com o numero passado
      expect(pagamento.formata_valor_cbs(10)).to eq '0000000180'
    end

    it 'formata valor do IBS informado com o numero de posicoes passadas' do
      # padrao com 15 posicoes (13 digitos e 2 decimais), campo X103
      pagamento.valor_ibs = 0.2
      expect(pagamento.formata_valor_ibs).to eq '000000000000020'
      # formata com o numero passado
      expect(pagamento.formata_valor_ibs(13)).to eq '0000000000020'
    end

    it 'formata o CBS e o IBS informado zerados por um zero negativo' do
      # O -0.0 e igual a zero, mas o format manteria o sinal e o campo ficaria
      # com um hifen no lugar de um digito
      pagamento.valor_cbs = -0.0
      expect(pagamento.formata_valor_cbs).to eq '000000000000000'
      pagamento.valor_ibs = -0.0
      expect(pagamento.formata_valor_ibs).to eq '000000000000000'
    end

    context 'com valores do CBS/IBS informado que nao cabem no campo' do
      it 'rejeita valor negativo' do
        # Um valor negativo colocaria um sinal no campo numerico
        pagamento.valor_ibs = -0.2
        expect { pagamento.formata_valor_ibs(15) }.to raise_error(Brcobranca::ValorInvalido)
      end

      it 'rejeita valor maior que as 13 posicoes do campo' do
        # Um valor maior deixaria o registro com mais de 240 posicoes
        pagamento.valor_cbs = 10_000_000_000_000.0
        expect { pagamento.formata_valor_cbs(15) }.to raise_error(Brcobranca::ValorInvalido)
      end

      it 'rejeita valor que nao e um numero' do
        pagamento.valor_cbs = Float::INFINITY
        expect { pagamento.formata_valor_cbs(15) }.to raise_error(Brcobranca::ValorInvalido)
      end

      it 'rejeita valor que nao e numerico, como uma String' do
        # So o Numeric e aceito: o to_f de uma String devolveria 1.0 para
        # '1,80' (ou 0.0 para 'abc') e o campo sairia preenchido com um valor
        # que o Recebedor nao informou
        pagamento.valor_cbs = '1,80'
        expect { pagamento.formata_valor_cbs(15) }.to raise_error(Brcobranca::ValorInvalido)
        pagamento.valor_ibs = 'abc'
        expect { pagamento.formata_valor_ibs(15) }.to raise_error(Brcobranca::ValorInvalido)
      end

      it 'formata o maior valor que cabe no campo' do
        # 13 digitos inteiros com 2 decimais, veja o campo X102
        pagamento.valor_cbs = 9_999_999_999_999.99
        expect(pagamento.formata_valor_cbs(15)).to eq '999999999999999'
      end
    end

    context 'formata a chave do Documento Fiscal do Split Payment' do
      before do
        pagamento.documento_fiscal = '35260647906085000135550010000012341000012345'
      end

      it 'deve formatar em 50 posicoes por padrao' do
        expect(pagamento.formata_documento_fiscal).to eq '35260647906085000135550010000012341000012345'.ljust(50, ' ')
      end

      it 'deve formatar com o numero de posicoes passado' do
        expect(pagamento.formata_documento_fiscal(10)).to eq '3526064790'
      end

      it 'deve manter as letras da chave do Documento Fiscal' do
        # O campo X101 e Alfa: a chave do DF-e pode ter letras (o CNPJ
        # alfanumerico entra na composicao da chave), entao so a pontuacao e
        # removida, sem truncar a chave
        pagamento.documento_fiscal = '352606AB.CD-EF01/0001'
        expect(pagamento.formata_documento_fiscal).to eq '352606ABCDEF010001'.ljust(50, ' ')
      end

      it 'deve rejeitar a chave que nao cabe nas posicoes do campo X101' do
        # A chave cortada identificaria outro Documento Fiscal para o Banco
        pagamento.documento_fiscal = '1' * 51
        expect { pagamento.formata_documento_fiscal }.to raise_error(Brcobranca::ValorInvalido)

        # A chave do tamanho do campo e aceita
        pagamento.documento_fiscal = '1' * 50
        expect(pagamento.formata_documento_fiscal).to eq '1' * 50
      end
    end

    context 'com o registro opcional do Split Payment (IBS/CBS)' do
      it 'nao e gerado quando nenhum dado do Split Payment e informado' do
        expect(pagamento.split_payment?).to be false
      end

      it 'nao e gerado quando apenas a Chave do Documento Fiscal e informada' do
        # O Documento Fiscal (X101) e opcional: a opcao pelo Split Payment e
        # sinalizada pelo CBS e o IBS Informado (X102/X103)
        pagamento.documento_fiscal = '35260647906085000135550010000012341000012345'
        expect(pagamento.split_payment?).to be false
      end

      it 'e gerado quando o CBS e o IBS Informado sao informados em conjunto' do
        pagamento.valor_cbs = 1.8
        pagamento.valor_ibs = 0.0
        expect(pagamento.split_payment?).to be true
      end

      it 'nao depende do Codigo de Movimento (C004) do titulo' do
        # Cada Banco escolhe os codigos de movimento que aceita, entao quem
        # decide enviar o Segmento X-03 e quem preenche o CBS/IBS Informado
        pagamento.valor_cbs = 1.8
        pagamento.valor_ibs = 0.2

        %w[01 02 68].each do |movimento|
          pagamento.identificacao_ocorrencia = movimento
          expect(pagamento.split_payment?).to be true
        end
      end
    end

    it 'formata valor dos juros com o numero de posicoes passadas' do
      # padrao com 13 posicoes
      pagamento.valor_mora = 49.2
      expect(pagamento.formata_valor_mora).to eq '0000000004920'
      # formata com o tamanho passado
      expect(pagamento.formata_valor_mora(15)).to eq '000000000004920'
    end

    context 'formata valor do campo documento' do
      before { pagamento.documento = '2345' }

      it 'deve formatar assumindo os valores padrao para os parametros tamanho e caracter' do
        expect(pagamento.formata_documento_ou_numero).to eql '2345'.rjust(25, ' ')
      end

      it 'deve formatar com os parametros tamanho e caracter' do
        expect(pagamento.formata_documento_ou_numero(15, '0')).to eql '2345'.rjust(15, '0')
      end

      it 'deve extrair somente o valor do campo no tamanho informado' do
        pagamento.documento = '12345678901234567890'
        expect(pagamento.formata_documento_ou_numero(15, '0')).to eql '123456789012345'
        expect(pagamento.formata_documento_ou_numero(15, '0').length).to be 15
      end

      it 'deve remover caracteres especiais ou acentuação' do
        pagamento.documento = 'JOÃO DEve R$ 900.00'
        expect(pagamento.formata_documento_ou_numero).to eql '         JOO DEve R 90000'
        expect(pagamento.formata_documento_ou_numero.length).to be 25
      end
    end

    context 'identificacao sacado' do
      it 'verifica a identificacao do sacado (pessoa fisica ou juridica)' do
        # pessoa fisica
        expect(pagamento.identificacao_sacado).to eq '01'
        # pessoa juridica
        pagamento.documento_sacado = '123456789101112'
        expect(pagamento.identificacao_sacado).to eq '02'
        pagamento.documento_sacado = '123456789101112'
        expect(pagamento.identificacao_sacado(false)).to eq '2'
      end
    end

    context 'identificacao avalista' do
      it 'verifica a identificacao do avalista (pessoa fisica ou juridica)' do
        # pessoa fisica
        pagamento.documento_avalista = '12345678901'
        expect(pagamento.identificacao_avalista).to eq '01'
        # pessoa juridica
        pagamento.documento_avalista = '123456789101112'
        expect(pagamento.identificacao_avalista).to eq '02'
      end

      it 'formata a identificacao com o numero de caracteres informados' do
        pagamento.documento_avalista = '12345678901'
        expect(pagamento.identificacao_avalista(false)).to eq '1'
      end
    end
  end
end
