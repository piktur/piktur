# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Object do
  before(:all) do
    require 'piktur/support/object'
    Piktur::Support::Object.send(:install)
  end

  before do
    Object.safe_const_reset(constant, value)
  end

  let(:constant) { :A }
  let(:value)    { 1 }

  describe 'safe_const_get(constant)' do
    context 'when constant defined' do
      it 'should return the constant' do
        expect(Object.safe_const_get(constant)).to be(value)
      end
    end

    context 'when constant undefined' do
      before { Object.send(:remove_const, constant) }

      it 'should return nil' do
        expect(Object.safe_const_get(constant)).to be(nil)
      end
    end
  end

  describe 'safe_const_set(constant, value)' do
    context 'when constant defined' do
      before { Object.safe_const_set(constant, value) }

      it 'should not override the original' do
        expect(Object.const_get(constant)).to be(value)
      end
    end

    context 'when constant undefined' do
      before { Object.send(:remove_const, constant) }

      it 'should return nil' do
        expect(Object.safe_const_set(constant, 2)).to be(2)
      end
    end
  end

  describe 'safe_const_get_or_set(constant, value = nil)' do
    context 'when constant defined' do
      it 'should not override the original' do
        expect(Object.safe_const_get_or_set(constant)).to eq value
      end
    end

    context 'when constant undefined' do
      before { Object.send(:remove_const, constant) }

      it 'should return nil' do
        expect(Object.safe_const_get_or_set(constant, 2)).to eq 2
      end
    end
  end

  describe 'safe_remove_const(constant)' do
    context 'when constant defined' do
      it 'should return the original' do
        expect(Object.safe_remove_const(constant)).to be(value)
      end
    end

    context 'when constant undefined' do
      before do
        Object.send(:remove_const, :A)
      end

      it 'should return nil' do
        expect(Object.safe_remove_const(constant)).to be_nil

        expect { Object.safe_remove_const(constant) }.not_to raise_error(NameError)
      end
    end
  end

  describe 'safe_const_reset(constant, value = nil)' do
    context 'when constant defined' do
      it 'should override the value' do
        expect(Object.safe_const_reset(constant, self)).to be(self)
      end
    end

    context 'when constant undefined' do
      before do
        Object.send(:remove_const, :A)
      end

      it 'should set the value' do
        expect(Object.safe_const_reset(constant, self)).to be(self)
      end
    end
  end
end
