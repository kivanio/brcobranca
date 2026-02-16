# frozen_string_literal: true

module Brcobranca
  module Boleto
    module Template
      # Implementação de template utilizando a gem Prawn
      module Prawn
        extend self

        require 'prawn'
        require 'barby'
        require 'barby/outputter/prawn_outputter'
        require 'barby/barcode/code_25_interleaved'

        COLORS = { light: 'E9E9E9', dark: '000000' }.freeze
        FONT_SIZE = { important: 13, body: 8, small: 6 }.freeze

        HEIGHT_CELLS = 23
        WIDTH_CELLS_RIGHT = 135
        PADDING_CELLS_RIGHT = 30
        QRCODE_WIDTH = WIDTH_CELLS_RIGHT

        # Gera o boleto em PDF utilizando a gem Prawn
        #
        # @param formato [Symbol] O formato de saída (somente :pdf e :prawn são suportados para este template)
        # @param options [Hash] Opções adicionais para geração do PDF.
        # @return [Stream, Prawn::Document]
        def to(formato, options = {})
          raise NotImplementedError, 'O formato PDF é o único suportado para este template' unless formato == :pdf

          modelo_generico([self], options.merge(formato: formato))
        end

        # Gera um lote de boletos em PDF utilizando a gem Prawn
        #
        # @param boletos [Array<Boleto>] Uma lista de objetos boleto para serem gerados
        # @param options [Hash] Opções adicionais para geração do PDF.
        # - :formato [Symbol] O formato de saída (somente :pdf e :prawn são suportados para este template)
        # @return [Stream, Prawn::Document]
        def lote(boletos, options = {})
          modelo_generico(boletos, options)
        end

        def respond_to_missing?(method_name, include_private = false)
          method_name.to_s.start_with?('to_') || super
        end

        #  Cria o métodos dinâmicos (to_pdf, to_gif e etc) com todos os fomátos válidos.
        #  @example
        #    @@boleto.to_pdf
        #
        # @return [Stream, Prawn::Document]
        def method_missing(name, *args)
          method = name.to_s
          if method.start_with?('to_')
            modelo_generico(self, (args.first || {}).merge!(formato: method[3..].to_sym))
          else
            super
          end
        end

        private

        # Retorna um stream pronto para gravação em arquivo.
        #
        # @param [Array<Boleto>] boletos Uma lista de objetos boleto para serem gerados
        # @param [Hash] options Opção para a criação do boleto.
        # @return [Stream, Prawn::Document]
        def modelo_generico(boletos, options = {})
          create_doc
          boletos.each { |boleto| desenha(boleto) }
          formato = options.delete(:formato) || Brcobranca.configuration.formato

          if formato == :pdf
            @doc.render
          elsif formato == :prawn
            @doc
          else
            raise NotImplementedError, 'Somente os formatos :pdf e :prawn são suportados para este template'
          end
        end

        def create_doc
          @doc = ::Prawn::Document.new(
            page_layout: :portrait,
            page_size: 'A4',
            skip_page_creation: true,
            left_margin: 15,
            right_margin: 15,
            top_margin: 20,
            bottom_margin: 20
          )

          @doc.font_families.update(
            'Roboto' => {
              normal: File.expand_path('../../arquivos/fontes/roboto/Roboto-Regular.ttf', __dir__)
            }
          )
        end

        def desenha(boleto)
          @boleto = boleto

          @doc.start_new_page
          @doc.font 'Roboto'
          @doc.font_size FONT_SIZE[:body]
          @doc.fill_color COLORS[:dark]

          desenha_cabecalho
          desenha_cabecalho_recibo
          desenha_pagador
          desenha_demonstrativo_com_qr_code
          desenha_recibo_cheque_com_autenticacao
          desenha_linha_corte
          desenha_cabecalho
          desenha_rodape
          desenha_pagador(height: 45, cod_baixa: true)
          desenha_ficha_compensacao
          desenha_codigo_barras

          remove_instance_variable(:@boleto)
        end

        def desenha_linha_corte(left: @doc.bounds.left, right: @doc.bounds.right)
          @doc.bounding_box([left, @doc.cursor], width: right - left) do
            @doc.stroke_color(COLORS[:dark])
            @doc.dash(5, space: 3, phase: 0)
            @doc.stroke_horizontal_line(left, right, at: @doc.cursor)
            @doc.undash

            @doc.text_box(
              'Corte na linha pontilhada',
              at: [0, 7],
              size: FONT_SIZE[:small],
              align: :right,
              width: right - left
            )
          end

          @doc.move_down(5)
        end

        def desenha_cabecalho
          @doc.move_down(20)

          @doc.bounding_box([@doc.bounds.left, @doc.cursor], width: @doc.bounds.width) do
            @doc.image(@boleto.logotipo, fit: [130, 30])

            desenha_divisoria(130, 18, 24)
            @doc.text_box(
              "#{@boleto.banco}-#{@boleto.banco_dv}",
              at: [130, 12],
              width: 40,
              size: FONT_SIZE[:important],
              align: :center
            )

            desenha_divisoria(170, 18, 24)
            @doc.text_box(
              @boleto.codigo_barras.linha_digitavel,
              at: [170, 12],
              size: FONT_SIZE[:important],
              align: :right
            )
          end

          @doc.move_down(5)
        end

        def desenha_cabecalho_recibo # rubocop:disable Metrics/MethodLength
          pos_y = @doc.cursor.to_i
          pos_x = 0
          width_big = @doc.bounds.width - WIDTH_CELLS_RIGHT

          # -------------------------
          # Linha 1
          # -------------------------
          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, width_big,
            label: 'Beneficiário', text: @boleto.cedente
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: 'Agência/Código do Beneficiário',
            text: @boleto.agencia_conta_boleto,
            padding_start: PADDING_CELLS_RIGHT
          )

          # -------------------------
          # Linha 2
          # -------------------------
          pos_x = 0
          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, width_big,
            label: 'Endereço do Beneficiário',
            text: @boleto.cedente_endereco
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: 'Nosso número',
            text: @boleto.nosso_numero_boleto,
            padding_start: PADDING_CELLS_RIGHT
          )

          # -------------------------
          # Linha 3
          # -------------------------
          pos_x = 0
          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: 'Número do documento',
            text: @boleto.documento_numero
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(10, width_big),
            label: 'Espécie',
            text: @boleto.especie
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(15, width_big),
            label: 'Quantidade',
            text: @boleto.quantidade
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: 'CPF/CNPJ',
            text: @boleto.documento_cedente.formata_documento.to_s
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: 'Vencimento',
            text: @boleto.data_vencimento.to_s_br
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: 'Valor documento',
            text: @boleto.valor_documento.to_currency,
            padding_start: PADDING_CELLS_RIGHT
          )

          # -------------------------
          # Linha 4
          # -------------------------
          pos_x = 0
          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: '(-) Descontos/Abatimentos',
            text: ''
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: '(-) Outras deduções',
            text: ''
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: '(+) Mora/Multa',
            text: ''
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: '(+) Outros acréscimos',
            text: ''
          )

          desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: '(=) Valor cobrado',
            text: '',
            padding_start: PADDING_CELLS_RIGHT,
            bg_color: COLORS[:light]
          )
        end

        def desenha_pagador(height: HEIGHT_CELLS, cod_baixa: false)
          @doc.bounding_box([0, @doc.cursor], width: @doc.bounds.width, height: height) do
            @doc.bounding_box([3, height - 3], width: 50) do
              @doc.text('Pagador', size: FONT_SIZE[:small])
            end

            @doc.bounding_box([@doc.bounds.left + 40, height - 3], width: @doc.bounds.right - 60) do
              if @boleto.sacado && @boleto.sacado_documento
                @doc.text(
                  "#{@boleto.sacado} - CPF/CNPJ: #{@boleto.sacado_documento.formata_documento}"
                )
              end

              @doc.text(@boleto.sacado_endereco.to_s)
            end

            if cod_baixa
              @doc.bounding_box([@doc.bounds.right - WIDTH_CELLS_RIGHT, 10], width: 50) do
                @doc.text('Cód. Baixa', size: FONT_SIZE[:small])
              end
            end

            @doc.stroke_bounds
          end

          @doc.move_down(2)
        end

        def desenha_demonstrativo_com_qr_code
          initial_cursor = @doc.cursor.dup
          height = 200

          @doc.bounding_box([0, initial_cursor], width: @doc.bounds.width, height: height) do
            @doc.bounding_box([0, height - 5], width: @doc.bounds.width - QRCODE_WIDTH) do
              @doc.bounding_box([5, 0], width: @doc.bounds.width) do
                @doc.text('Demonstrativo', size: FONT_SIZE[:small])
              end

              @doc.bounding_box([10, 0], width: @doc.bounds.right - 80) do
                @doc.text(
                  @boleto.demonstrativo,
                  leading: 2,
                  inline_format: true
                )
              end
            end

            if @boleto.emv
              @doc.bounding_box([@doc.bounds.width - QRCODE_WIDTH, height - 5], width: QRCODE_WIDTH) do
                @doc.text('Pague com PIX', size: FONT_SIZE[:small], align: :center)
                desenha_qr_code(@boleto.emv, 0, height - 70)
              end
            end
          end

          @doc.move_down(57)
        end

        def desenha_qr_code(emv, pos_x, pos_y)
          # Evita carregar a gem RQRCode desnecessariamente se o boleto
          # não tiver um código QR para ser gerado
          require 'rqrcode' unless defined?(RQRCode)

          qr_code_matrix = RQRCode::QRCode.new(emv).modules
          module_size = QRCODE_WIDTH / qr_code_matrix.length.to_f

          @doc.bounding_box([pos_x, pos_y], width: QRCODE_WIDTH, height: QRCODE_WIDTH) do
            qr_code_matrix.each_with_index do |row, y|
              row.each_with_index do |module_filled, x|
                if module_filled
                  @doc.fill_color(COLORS[:dark])
                  @doc.fill_rectangle([x * module_size, -y * module_size], module_size, module_size)
                end
              end
            end
          end
        end

        def desenha_recibo_cheque_com_autenticacao
          initial_cursor = @doc.cursor.dup
          cell_width = (@doc.bounds.width / 2)
          height = HEIGHT_CELLS * 2

          aviso_text = [
            'Este recibo somente terá validade com a autenticação mecânica ou acompanhado do',
            'recibo de pagamento emitido pelo Banco.',
            'Recebimento através do cheque n°                                   do banco',
            'Esta quitação só terá validade após o pagamento do cheque pelo banco sacado.'
          ].join("\n")

          @doc.bounding_box([0, initial_cursor], width: cell_width) do
            @doc.fill_color(COLORS[:light])
            @doc.fill_rectangle([0, height], cell_width, height)
            @doc.fill_color(COLORS[:dark])

            @doc.bounding_box([5, height - 5], width: cell_width - 10) do
              @doc.text(aviso_text, size: 7, leading: 2)
            end
          end

          @doc.bounding_box([cell_width + 5, initial_cursor + height], width: cell_width, height: height) do
            desenha_autenticacao_mecanica(5, height, cell_width - 5)
          end

          @doc.move_down(5)
        end

        def desenha_autenticacao_mecanica(pos_x, pos_y, pos_x_end)
          corner_size = 25
          line_width = 1

          @doc.fill_rectangle([pos_x, pos_y], corner_size, line_width)
          @doc.fill_rectangle([pos_x, pos_y], line_width, corner_size)

          @doc.float do
            @doc.text_box(
              'Autenticação Mecânica - Recibo do Pagador',
              align: :center,
              size: FONT_SIZE[:small]
            )

            @doc.fill_rectangle([pos_x_end - corner_size, pos_y], corner_size, line_width)
            @doc.fill_rectangle([pos_x_end, pos_y], line_width, corner_size)
          end
        end

        def desenha_rodape # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
          pos_y = @doc.cursor.to_i
          pos_x = 0
          width_big = @doc.bounds.width - WIDTH_CELLS_RIGHT

          # -------------------------
          # Linha 1
          # -------------------------
          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, width_big,
            label: 'Local de Pagamento',
            text: @boleto.local_pagamento
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: 'Vencimento',
            text: @boleto.data_vencimento&.to_s_br,
            padding_start: PADDING_CELLS_RIGHT,
            bg_color: COLORS[:light]
          )

          # -------------------------
          # Linha 2
          # -------------------------
          pos_x, _pos_y = desenha_celula(0, pos_y, HEIGHT_CELLS, width_big, label: 'Beneficiário') do
            if @boleto.cedente_endereco
              @doc.bounding_box([40, HEIGHT_CELLS - 3], width: width_big) do
                @doc.text(@boleto.cedente)
              end
              @doc.bounding_box([5, HEIGHT_CELLS - 13], width: width_big) do
                @doc.text(@boleto.cedente_endereco)
              end
            else
              @doc.bounding_box([5, HEIGHT_CELLS - 10], width: width_big) do
                @doc.text(@boleto.cedente)
              end
            end
          end

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: 'Agência/Código do Beneficiário',
            text: @boleto.agencia_conta_boleto,
            padding_start: PADDING_CELLS_RIGHT
          )

          # -------------------------
          # Linha 3
          # -------------------------
          pos_x, _pos_y = desenha_celula(
            0, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: 'Data do documento',
            text: @boleto.data_documento&.to_s_br
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(30, width_big),
            label: 'Nº documento',
            text: @boleto.documento_numero
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(15, width_big),
            label: 'Espécie doc.',
            text: @boleto.especie_documento
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(10, width_big),
            label: 'Aceite',
            text: @boleto.aceite
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(20, width_big),
            label: 'Data processamento',
            text: @boleto.data_processamento&.to_s_br
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: 'Nosso número',
            text: @boleto.nosso_numero_boleto,
            padding_start: PADDING_CELLS_RIGHT
          )

          # -------------------------
          # Linha 4
          # -------------------------
          pos_x, _pos_y = desenha_celula(
            0, pos_y, HEIGHT_CELLS, percentual(25, width_big),
            label: 'Uso do banco'
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(10, width_big),
            label: 'Carteira',
            text: @boleto.variacao ? "#{@boleto.carteira}-#{@boleto.variacao}" : @boleto.carteira
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(10, width_big),
            label: 'Espécie',
            text: @boleto.especie
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(10, width_big),
            label: 'Quantidade'
          )

          pos_x, _pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, percentual(45, width_big),
            label: 'Valor'
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, HEIGHT_CELLS, WIDTH_CELLS_RIGHT,
            label: '(=) Valor do documento',
            text: @boleto.valor_documento.to_currency,
            padding_start: PADDING_CELLS_RIGHT
          )

          # -------------------------
          # Linha 5
          # -------------------------
          instrucoes_height = 116
          instrucoes_right_cells_height = instrucoes_height / 4
          pos_x, _pos_y = desenha_celula(
            0, pos_y, instrucoes_height, width_big,
            label: 'Instruções (Instruções de responsabilidade do Beneficiário. Qualquer dúvida sobre este boleto, contate o beneficiário)'
          ) do
            instrucoes = (1..6).filter_map { |i| @boleto.public_send("instrucao#{i}") }.join("\n")

            @doc.text_box(
              instrucoes,
              at: [5, instrucoes_height - 10],
              width: width_big - 10,
              size: FONT_SIZE[:body],
              leading: 2,
              inline_format: true
            )
          end

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, instrucoes_right_cells_height, WIDTH_CELLS_RIGHT,
            label: '(-) Descontos/Abatimentos',
            text: @boleto.descontos_e_abatimentos&.to_currency,
            padding_start: PADDING_CELLS_RIGHT
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y, instrucoes_right_cells_height, WIDTH_CELLS_RIGHT,
            label: '(-) Outras deduções',
            padding_start: PADDING_CELLS_RIGHT
          )

          _pos_x, pos_y = desenha_celula(
            pos_x, pos_y,
            instrucoes_right_cells_height,
            WIDTH_CELLS_RIGHT,
            label: '(+) Juros/Multa',
            padding_start: PADDING_CELLS_RIGHT
          )

          desenha_celula(
            pos_x, pos_y,
            instrucoes_right_cells_height,
            WIDTH_CELLS_RIGHT,
            label: '(=) Valor cobrado',
            text: '',
            padding_start: PADDING_CELLS_RIGHT,
            bg_color: COLORS[:light]
          )
        end

        def desenha_ficha_compensacao
          @doc.move_down(2)
          current_cursor = @doc.cursor.dup

          @doc.bounding_box([5, current_cursor], width: @doc.bounds.width) do
            sacado_info = 'Sacador/Avalista'

            if @boleto.sacado && @boleto.sacado_documento && @boleto.avalista && @boleto.avalista_documento
              sacado_info += "#{@boleto.avalista} - #{@boleto.avalista_documento}"
            end

            @doc.text(sacado_info, size: FONT_SIZE[:small])
          end

          @doc.bounding_box([0, current_cursor], width: @doc.bounds.width - 5) do
            @doc.text(
              'Autenticação Mecânica - Ficha de Compensação',
              size: FONT_SIZE[:small],
              align: :right
            )
          end

          @doc.move_down(50)
        end

        def desenha_codigo_barras
          barcode = Barby::Code25Interleaved.new(@boleto.codigo_barras)
          outputter = Barby::PrawnOutputter.new(barcode)

          @doc.bounding_box([10, @doc.cursor], width: @doc.bounds.width - 20) do
            outputter.annotate_pdf(
              @doc,
              height: 38, # altura do código de barras
              xdim: 0.72  # largura das barras
            )
          end
        end

        # Desenha uma divisória vestical no boleto, usada para separar seções.
        #
        # @param pos_x [Numeric] A posição horizontal da divisória
        # @param pos_y [Numeric] A posição vertical da divisória
        # @param height [Numeric] A altura da divisória (padrão: 15)
        # @param width [Numeric] A largura da divisória (padrão: 1)
        def desenha_divisoria(pos_x, pos_y, height = 15, width = 1)
          @doc.fill_color(COLORS[:dark])
          @doc.fill_rectangle([pos_x, pos_y], width, height)
        end

        # Desenha uma celula generica no boleto, com opções para personalização do texto e estilo.
        # Se um bloco for fornecido, ele será usado para renderizar conteúdo personalizado dentro da célula.
        #
        # @param pos_x [Numeric] A posição horizontal da célula
        # @param pos_y [Numeric] A posição vertical da célula
        # @param height [Numeric] A altura da célula
        # @param width [Numeric] A largura da célula
        # @param options [Hash] Opções para personalização da célula, incluindo:
        #   - :label [String] O rótulo a ser exibido na parte superior da célula
        #   - :text [String] O texto a ser exibido na parte inferior da célula
        #   - :padding_start [Numeric] O preenchimento inicial para o texto (padrão: 5)
        #   - :bg_color [String] A cor de fundo da célula (hexadecimal)
        #   - :text_opts [Hash] Opções adicionais para personalização do texto
        def desenha_celula(pos_x, pos_y, height, width, **options)
          @doc.bounding_box([pos_x, pos_y], width: width, height: height) do
            if options[:bg_color]
              @doc.fill_color(options[:bg_color])
              @doc.fill_rectangle([0, height], width, height)
            end

            @doc.fill_color(COLORS[:dark])

            @doc.bounding_box([3, height - 2], width: width - 6) do
              @doc.text(options[:label].to_s, size: FONT_SIZE[:small])
            end

            if block_given?
              yield
            else
              text_opts = options[:text_opts] || {}
              text_options = {
                size: FONT_SIZE[:body],
                at: [options[:padding_start] || 5, (text_opts[:size] || FONT_SIZE[:body]) + 2],
                width: width - 10
              }

              @doc.text_box(options[:text].to_s, text_options.merge(text_opts))
            end

            @doc.stroke_bounds
          end

          [pos_x + width, pos_y - height]
        end

        def percentual(valor, total)
          (total * valor) / 100.0
        end
      end
    end
  end
end
