# frozen_string_literal: true

# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'sslcert::set' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
