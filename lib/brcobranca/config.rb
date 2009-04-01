module Brcobranca
  module Config
    OPCOES = {
      :render           => 'pdf', #pode ser (pdf, html)
      :gerador_pdf            => 'rghost', #pode ser (rghost, prawn)
      :gerador_codio_barra    => 'rghost_barcode' #pode ser (rghost_barcode, barby)
    }

    case Brcobranca::Config::OPCOES[:gerador_pdf]
    when 'rghost'
      require 'rghost'
    when 'prawn'
      require 'prawn'
    else
      require 'rghost'
    end

    case Brcobranca::Config::OPCOES[:gerador_codio_barra]
    when 'rghost_barcode'
      require 'rghost_barcode'
    when 'prawn'
      require 'prawn'
    else
      require 'rghost_barcode'
    end
  end
end