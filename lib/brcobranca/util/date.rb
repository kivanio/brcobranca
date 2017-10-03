# -*- encoding: utf-8 -*-
#
# @author Eduardo Reboucas
#
# Para manter compatibilidade com ActiveModel

require 'date'
require 'time'

class Date
  def self.current
    Time.respond_to?(:zone) && Time.zone ? Time.zone.today : Date.today
  end
end

class Time
  def self.current
    Time.respond_to?(:zone) && Time.zone ? Time.zone.now : Time.now
  end
end
