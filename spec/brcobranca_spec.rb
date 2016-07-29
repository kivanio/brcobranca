# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe 'Brcobranca' do

  describe 'gerador' do
    context 'rghost' do
      before { Brcobranca.configuration.gerador = :rghost }

      it { expect(Brcobranca.configuration.gerador).to eql(:rghost) }
    end

    context 'prawn' do
      before { Brcobranca.configuration.gerador = :prawn }

      it { expect(Brcobranca.configuration.gerador).to eql(:prawn) }
    end
  end

  describe 'formato' do
    context 'pdf' do
      before { Brcobranca.configuration.formato = :pdf }

      it { expect(Brcobranca.configuration.formato).to eql(:pdf) }
    end

    context 'gif' do
      before { Brcobranca.configuration.formato = :gif }

      it { expect(Brcobranca.configuration.formato).to eql(:gif) }
    end
  end
end
