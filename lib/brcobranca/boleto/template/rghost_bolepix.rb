# frozen_string_literal: true

begin
  require 'rghost'
rescue LoadError
  require 'rubygems'
  require 'rghost'
end

begin
  require 'rghost_barcode'
rescue LoadError
  require 'rubygems'
  require 'rghost_barcode'
end

module Brcobranca
  module Boleto
    module Template
      # Templantes para gerar boleto bancário com QRCode do PIX (bolepix).
      #
      # Reaproveita todo o desenho do template Rghost e sobrescreve apenas os
      # ganchos que diferenciam o bolepix: o QRCode do PIX, gerado a partir do
      # EMV do boleto, e os descontos/abatimentos.
      module RghostBolepix
        include Brcobranca::Boleto::Template::Rghost

        private

        # Desenha o QRCode do PIX quando o boleto tem EMV.
        def desenha_qrcode_pix(doc, boleto)
          return unless boleto.emv

          doc.barcode_qrcode(boleto.emv, width: '2.5 cm',
                                         height: '2.5 cm',
                                         eclevel: 'H',
                                         x: "#{@x + 12.9} cm",
                                         y: "#{@y - 2.50} cm")
          move_more(doc, @x + 12.9, @y - 3.70)
          doc.show 'Pague com PIX'
        end

        # Descontos e abatimentos no rodape. O deslocamento e simetrico, para
        # nao mover o cursor de quem vem depois.
        def desenha_descontos_e_abatimentos(doc, boleto)
          move_more(doc, 0, -0.8)
          doc.show boleto.descontos_e_abatimentos&.to_currency

          move_more(doc, 0, 0.8)
        end

        # Mesmo deslocamento total do Rghost (-15, -1.3), quebrado em dois
        # passos para mostrar os descontos e abatimentos no meio do caminho.
        def move_para_linha_do_sacado(doc, boleto)
          move_more(doc, -15.8, -0.75)
          doc.show boleto.descontos_e_abatimentos&.to_currency

          move_more(doc, 0.8, -0.55)
        end
      end
    end
  end
end
