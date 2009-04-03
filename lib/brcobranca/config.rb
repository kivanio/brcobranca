module Brcobranca
  # Módulo de configuração. 
  module Config
    # Opções disponíveis: 
    #  Brcobranca::Config::OPCOES[:tipo] - Pode ser pdf, jpg e ps.
    #  Brcobranca::Config::OPCOES[:gerador] - Somente rghost até o momento
    OPCOES = {:tipo => 'pdf', :gerador => 'rghost'}
  end
end