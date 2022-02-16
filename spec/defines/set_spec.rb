# frozen_string_literal: true

require 'spec_helper'

describe 'sslcert::set' do
  let(:title) { 'example.org' }

  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "adds certs on #{os}" do
      let(:params) { { 'ensure' => 'present', 'bundlefile' => nil } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('sslcert-example.org.key').with('source' => 'puppet:///files/sslcert-example.org.key') }

      it { is_expected.to contain_file('sslcert-example.org.crt').with('source' => 'puppet:///files/sslcert-example.org.crt') }
    end

    context "adds certs and bundle on #{os}" do
      let(:params) { { 'ensure' => 'present', 'bundlefile' => 'ca.pem', 'embed_bundle' => false } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('sslcert-example.org.key').with('source' => 'puppet:///files/sslcert-example.org.key') }

      it { is_expected.to contain_file('sslcert-example.org.crt').with('source' => 'puppet:///files/sslcert-example.org.crt') }

      it { is_expected.to contain_file('sslcert-ca.pem').with('source' => 'puppet:///files/ca.pem') }
    end

    context "adds certs with embedded bundle on #{os}" do
      let(:params) { { 'ensure' => 'present', 'bundlefile' => 'ca.pem', 'embed_bundle' => true } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('sslcert-example.org.key').with('source' => 'puppet:///files/sslcert-example.org.key') }

      it { is_expected.to contain_concat('sslcert-example.org-cert-and-bundle') }

      it { is_expected.to contain_concat__fragment('sslcert-example.org-cert').with('source' => 'puppet:///files/sslcert-example.org.crt') }

      it { is_expected.to contain_concat__fragment('sslcert-example.org-bundle').with('source' => 'puppet:///files/ca.pem') }
    end
  end
end
