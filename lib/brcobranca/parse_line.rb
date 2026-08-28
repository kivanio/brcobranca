# frozen_string_literal: true

module Brcobranca
  # Modulo para parsear linhas de arquivos de retorno e remessa.
  # Ele e utilizado para definir o layout de cada banco e depois ler as linhas do arquivo de acordo com esse layout.
  #
  # Originalmente baseado em: https://github.com/shairontoledo/parseline
  module ParseLine
    # Campos definidos para a classe.
    #
    # Uma subclasse comeca com uma copia dos campos da classe pai e a partir
    # dai tem vida propria: definir um campo na filha nunca altera o layout da
    # mae. E o que permite ao Retorno::Cnab240::Caixa reaproveitar o layout
    # generico do CNAB 240 sobrescrevendo apenas alguns campos.
    #
    # @return [Array<Array>] lista de [campo, range, transformador].
    def parse_values
      @parse_values ||= parse_values_herdados
    end

    # Define o layout de cada linha do arquivo de acordo com as posicoes de cada campo.
    # Exemplo:
    #     class BancoX < Base
    #       extend ParseLine
    #
    #       fixed_width_layout do |layout|
    #         layout.field :campo1, 0...10
    #         layout.field :campo2, 10...20 do |value|
    #           value.to_i
    #         end
    #       end
    #     end
    def fixed_width_layout
      yield self if block_given?
    end

    # Define um campo do layout, indicando o nome do campo,
    # a posicao (range) e opcionalmente um bloco para processar o valor do campo.
    # Exemplo:
    #     layout.field :campo1, 0...10
    #     layout.field :campo2, 10...20 do |value|
    #       value.to_i
    #     end
    #
    # @param [Symbol] field O nome do campo a ser definido.
    # @param [Range] range O intervalo de caracteres onde o campo esta localizado na linha do arquivo.
    # @param [Proc] proc (opcional) Um bloco para processar o valor do campo antes de atribui-lo ao objeto.
    def field(field, range, proc = nil, &block)
      parse_values << [field, range, proc || block]
    end

    # Le as linhas de um arquivo e retorna um array de objetos com os campos preenchidos de acordo com o layout definido.
    # Opcoes:
    # - :except => [1, 3] (ignora as linhas 1 e 3)
    # - :except => /regex/ (ignora as linhas que correspondem ao regex)
    # - :length => 100 (considera apenas as linhas com tamanho igual a 100 caracteres)
    #
    # @param [String] filepath O caminho do arquivo a ser lido.
    # @param [Hash] options Opcoes para filtrar as linhas a serem processadas.
    def load_lines(filepath, options = {})
      if options[:except].is_a?(Array)
        return load_lines_except_array(filepath, options[:except], options[:length])
      elsif options[:except].is_a?(Regexp)
        return load_lines_except_regex(filepath, options[:except], options[:length])
      end

      File.open(filepath) do |file|
        file.each_with_object([]) do |line, lines|
          lines << load_line(line) if line_valid?(line, options[:length])
        end
      end
    end

    def load_lines_except_array(filepath, except, length = nil)
      lines = []

      File.open(filepath) do |file|
        file.each_with_index do |line, i|
          next if except.include?(i + 1)
          next unless line_valid?(line, length)

          lines << load_line(line)
        end
      end

      lines
    end

    def load_lines_except_regex(filepath, except, length = nil)
      lines = []

      File.open(filepath) do |file|
        file.each do |line|
          next if except.match?(line)
          next unless line_valid?(line, length)

          lines << load_line(line)
        end
      end

      lines
    end

    # Processa uma linha do arquivo de acordo com o layout definido e retorna um objeto com os campos preenchidos.
    # Se a linha nao corresponder ao layout definido, uma excecao e levantada.
    # @param [String] line A linha do arquivo a ser processada.
    # @return [Object] Um objeto com os campos preenchidos de acordo com o layout definido.
    def load_line(line)
      instance = new

      parse_values.each do |field_name, range, transformer|
        value = transformer ? transformer.call(line[range]) : line[range].to_s.strip
        instance.public_send("#{field_name}=", value)
      end

      instance
    rescue StandardError => e
      raise Brcobranca::MalformedLayoutOrLine, "Linha malformada ou layout incorreto: '#{line}', tamanho: #{line.size} " \
                                               "Erro original: (#{e.class}): #{e.message}"
    end

    # Linha em branco nunca vira registro, com ou sem filtro.
    def line_valid?(line, expected_length = nil)
      !line.blank? && line_length_valid?(line, expected_length)
    end

    # Compara o tamanho da linha sem a quebra de linha (\n ou \r\n).
    #
    # Nao usar strip aqui: registros CNAB sao preenchidos com brancos a
    # direita e seriam descartados por engano.
    def line_length_valid?(line, expected_length = nil)
      return true if expected_length.nil?

      line.to_s.chomp.length == expected_length.to_i
    end

    private

    # Copia dos campos da classe pai, quando ela tambem usa o ParseLine.
    def parse_values_herdados
      return [] unless is_a?(Class)

      pai = superclass
      pai.respond_to?(:parse_values) ? pai.parse_values.dup : []
    end
  end
end
