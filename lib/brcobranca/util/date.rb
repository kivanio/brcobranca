# -*- encoding: utf-8 -*-
#
# @author Eduardo Reboucas
# 
# Para manter compatibilidade com ActiveModel

require 'date'

class Date  
  def self.current
    Date.today
  end
end