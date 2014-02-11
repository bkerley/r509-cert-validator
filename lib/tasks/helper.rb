require 'r509'

module CaHelper
  def self.csr
    R509::CSR.new(
                  subject: {
                    C: 'US',
                    ST: 'Florida',
                    L: 'Miami',
                    O: 'r509-cert-validator',
                    CN: 'localhost'
                  },
                  bit_length: 512,
                  type: 'RSA',
                  message_digest: 'sha1'
                  )
  end

  def self.ca
    @ca ||= R509::CertificateAuthority::Signer.new pool['rcv_spec_ca']
  end

  def self.options_builder
    @builder ||= R509::CertificateAuthority::OptionsBuilder.new pool['rcv_spec_ca']
  end

  def self.pool
    @pool ||= R509::Config::CAConfigPool.from_yaml(
                                                   'certificate_authorities', 
                                                   File.read('spec/support/ca/config.yaml')
                                                   )
  end
end
