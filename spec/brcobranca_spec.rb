# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe 'Brcobranca' do
  describe 'gerador' do
    context 'rghost' do
      before { Brcobranca.configuration.gerador = :rghost }

      it { expect(Brcobranca.configuration.gerador).to be(:rghost) }
    end

    context 'prawn' do
      before { Brcobranca.configuration.gerador = :prawn }

      it { expect(Brcobranca.configuration.gerador).to be(:prawn) }
    end
  end

  describe 'formato' do
    context 'pdf' do
      before { Brcobranca.configuration.formato = :pdf }

      it { expect(Brcobranca.configuration.formato).to be(:pdf) }
    end

    context 'gif' do
      before { Brcobranca.configuration.formato = :gif }

      it { expect(Brcobranca.configuration.formato).to be(:gif) }
    end
  end
end
