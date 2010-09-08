# -*- encoding: utf-8 -*-
module Brcobranca
  # Módulo de configuração.
  module Config
    # Opções disponíveis:
    #  Brcobranca::Config.formato - Pode ser pdf, jpg e ps.
    #  Brcobranca::Config.gerador - Somente rghost até o momento

    def self.gerador
      @@gerador
    end

    def self.gerador=(gerador)
      @@gerador = gerador
    end

    def self.formato
      @@formato
    end

    def self.formato=(formato)
      @@formato
    end

    @@formato = :pdf
    @@gerador = :rghost

    def self.setup
      yield self
    end
  end

end