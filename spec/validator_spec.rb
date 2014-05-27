require 'spec_helper'

describe R509::Cert::Validator do
  let(:issuer_cert){ cert('root.crt') }
  let(:crl_path) do
    __dir__ ||= File.dirname(File.expand_path(__FILE__))
    File.expand_path(File.join(__dir__, 'support/ca/rcv_spec.crl')) 
  end

  describe 'with a cert without CRL or OCSP data' do
    let(:no_validator_cert){ cert('empty.crt') }
    subject{ described_class.new no_validator_cert }

    it 'should validate' do
      expect{ subject.validate }.to_not raise_error
    end

    it 'should refuse to validate with CRL or OCSP' do
      expect{ subject.validate crl: true }.to raise_error
      expect{ subject.validate ocsp: true }.to raise_error
    end

    it 'should validate against a CRL file' do
      expect do
        subject.validate crl: true, ocsp: false, crl_file: crl_path 
      end.to_not raise_error
    end
  end

  describe 'with a cert with CRL and OCSP data' do
    let(:good_cert){ cert('good.crt') }
    subject{ described_class.new good_cert, issuer_cert }

    it 'should validate against a CRL' do
      expect{ subject.validate crl: true, ocsp: false }.to_not raise_error
    end
    
    it 'should validate a cert against OCSP' do
      expect{ subject.validate crl: false, ocsp: true }.to_not raise_error
    end
  end

  describe 'with a cert with CRL and no OCSP' do
    let(:crl_only_cert){ cert('crl_only.crt') }
    subject{ described_class.new crl_only_cert, issuer_cert }

    it 'should validate against a CRL' do
      expect{ subject.validate crl: true, ocsp: false }.to_not raise_error
    end

    it 'should fail to validate against OCSP' do
      expect{ subject.validate crl: false, ocsp: true }.to raise_error
    end
  end

  describe 'with a cert with OCSP and no CRL' do
    let(:ocsp_only_cert){ cert('ocsp_only.crt') }
    subject{ described_class.new ocsp_only_cert, issuer_cert }

    it 'should fail to validate against a CRL' do
      expect{ subject.validate crl: true, ocsp: false }.to raise_error
    end

    it 'should validate against OCSP' do
      expect{ subject.validate crl: false, ocsp: true }.to_not raise_error
    end
  end

  describe 'with a revoked cert' do
    let(:revoked_cert){ cert('revoked.crt') }
    subject{ described_class.new revoked_cert, issuer_cert }

    it 'should validate false against a CRL' do
      expect(subject.validate crl: true, ocsp: false).to_not be
      expect{ subject.validate! crl: true, ocsp: false }.to raise_error /revoked/
    end

    it 'should validate false against OCSP' do
      expect(subject.validate crl: false, ocsp: true).to_not be
      expect{ subject.validate! crl: false, ocsp: true }.to raise_error /revoked/
    end

    it 'should validate false against a CRL file' do
      expect(subject.validate crl: true, ocsp: false, crl_file: crl_path).
        to_not be
      expect{ subject.validate! crl: true, ocsp: false, crl_file: crl_path}.
        to raise_error /revoked/
    end
  end
end
