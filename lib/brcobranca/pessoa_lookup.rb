# frozen_string_literal: true

module Brcobranca
  # Preenchimento automático dos dados do sacado (pagador) a partir de uma
  # consulta por CPF ou CNPJ.
  #
  # O recurso é totalmente opcional e aditivo: a gem continua funcionando sem
  # rede caso ele não seja utilizado. Nada aqui altera o núcleo do boleto ou da
  # remessa; o resolver apenas produz o conjunto de atributos do sacado que o
  # usuário passa para +Brcobranca::Boleto::Base+ ou +Brcobranca::Remessa::Pagamento+.
  #
  # == Fonte de dados
  #
  # Uma fonte de dados é qualquer objeto que responda a dois métodos:
  #
  #   consultar_cpf(cpf)   -> Hash normalizado
  #   consultar_cnpj(cnpj) -> Hash normalizado
  #
  # O Hash normalizado usa chaves em símbolo e representa uma pessoa e seu
  # endereço de forma granular:
  #
  #   {
  #     documento:   '12345678909',
  #     nome:        'Fulano de Tal',
  #     logradouro:  'Rua A',
  #     numero:      '100',
  #     complemento: 'Apto 03',
  #     bairro:      'Centro',
  #     cep:         '99999123',
  #     cidade:      'Sao Paulo',
  #     uf:          'SP'
  #   }
  #
  # Como o contrato é apenas o par de métodos, a fonte pode ser trocada por um
  # objeto de teste (mock) ou por outro provedor sem qualquer alteração no
  # resolver.
  #
  # A implementação de referência é +CpfCnpjComBrLookup+, que consome a API
  # pública de https://www.cpfcnpj.com.br usando apenas a biblioteca padrão
  # (+Net::HTTP+), sem introduzir dependências novas.
  module PessoaLookup
    # Chaves esperadas em um Hash normalizado devolvido por uma fonte de dados.
    CAMPOS = %i[documento nome logradouro numero complemento bairro cep cidade uf].freeze

    # Erro base do recurso de consulta.
    class Erro < StandardError; end

    # Documento informado não é um CPF (11 dígitos) nem um CNPJ (14 caracteres).
    class DocumentoInvalido < Erro; end

    # A fonte de dados ficou indisponível (falha de rede, resposta ilegível
    # ou erro de servidor). O recurso falha fechado: nunca devolve dados
    # parciais em caso de indisponibilidade.
    class Indisponivel < Erro; end

    # A consulta excedeu o tempo limite configurado.
    class TempoEsgotado < Indisponivel; end

    # A fonte respondeu, porém não encontrou o documento consultado.
    class NaoEncontrado < Erro; end
  end
end
