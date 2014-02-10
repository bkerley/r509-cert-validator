require 'r509'
require 'erb'
require_relative 'helper'

namespace :ca do
  desc 'Generate all the certificates for testing'
  task :all => %i{ good ocsp_only crl_only empty revoked }

  file 'spec/support/ca/root.key' => :root
  file 'spec/support/ca/root.crt' => :root

  file 'spec/support/ca/config.yaml' => 'spec/support/ca/config.yaml.erb' do |s|
    erb = ERB.new File.read s.prerequisites.first
    b = binding
    cert_path = File.expand_path 'spec/support/ca/'
    File.open s.name, 'w' do |f|
      f.write erb.result b
    end
  end
  
  desc 'Generate a signing CA for testing certificates'
  task :root do |t|
    subject = OpenSSL::X509::Name.new
    'C=US/ST=Florida/L=Miami/O=r509-cert-validator/CN='.split('/').each do |s|
      key, value = s.split '=', 2
      subject.add_entry key, value
    end
    csr = CaHelper.csr
    cert = R509::CertificateAuthority::Signer.selfsign(
                                                       csr: csr,
                                                       not_after: (Time.now.to_i + (86400 * 3650)),
                                                       message_digest: 'sha1'
                                                       )
    
    csr.key.write_pem 'spec/support/ca/root.key'
    cert.write_pem 'spec/support/ca/root.crt'

    sh "touch spec/support/ca/rcv_spec_list.txt"
    sh "touch spec/support/ca/rcv_spec_crlnumber.txt"
  end

  desc 'Generate a valid certificate with CRL and OCSP data'
  task :good => [:root, 'spec/support/ca/config.yaml'] do
    ca = CaHelper.ca
    csr = CaHelper.options_builder.build_and_enforce(
                                                     csr: CaHelper.csr,
                                                     profile_name: 'good'
                                                     )

    cert = ca.sign csr
    cert.write_pem 'spec/support/ca/good.crt'
  end
  file 'spec/support/ca/good.crt' => :good

  desc 'Generate a valid certificate with only CRL data'
  task :crl_only => [:root, 'spec/support/ca/config.yaml']
  file 'spec/support/ca/crl_only.crt' => :crl_only

  desc 'Generate a valid certificate with only OCSP data'
  task :ocsp_only => [:root, 'spec/support/ca/config.yaml']
  file 'spec/support/ca/ocsp_only.crt' => :ocsp_only

  desc 'Generate a certificate and revoke it in both CRL and OCSP'
  task :revoked => [:root, 'spec/support/ca/config.yaml']
  file 'spec/support/ca/revoked.crt' => :revoked

  desc 'Generate a valid certificate with no CRL or OCSP data'
  task :empty => [:root, 'spec/support/ca/config.yaml']
  file 'spec/support/ca/empty.crt' => :empty
end
