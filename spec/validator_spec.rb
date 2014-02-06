require 'spec_helper'

describe R509::Cert::Validator do

  describe 'with a cert without CRL or OCSP data' do
    let(:no_validator_cert){ R509::Cert.new cert: load_cert('no_validator.crt') }
    subject{ described_class.new no_validator_cert }

    it 'should validate' do
      expect{ subject.validate }.to_not raise_error
    end

    it 'should refuse to validate with CRL or OCSP' do
      expect{ subject.validate crl: true }.to raise_error
      expect{ subject.validate ocsp: true }.to raise_error
    end
  end

  describe 'with a cert with CRL and OCSP data' do
    let(:github_cert){ R509::Cert.new cert: load_cert('github.crt') }
    subject{ described_class.new github_cert }

    it 'should validate a cert against a CRL' do
      expect{ subject.validate crl: true, ocsp: false }.to_not raise_error
    end
    
    it 'should validate a cert against OCSP' do
      expect{ subject.validate crl: false, ocsp: true }.to_not raise_error
    end
  end
end
