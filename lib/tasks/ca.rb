require 'r509'
require 'erb'

namespace :ca do
  file 'spec/support/ca/root.key' => :root
  file 'spec/support/ca/root.crt' => :root

  file 'spec/support/ca/config.yaml' => 'spec/support/ca/config.yaml.erb' do |s|
    erb = ERB.new File.read s.prerequisites.first
    b = binding
    cert_path = File.expand_path File.dirname 'spec/support/ca/'
    File.open s.name, 'w' do |f|
      f.write erb.result b
    end
  end

  task :root do |t|
    subject = OpenSSL::X509::Name.new
    'C=US/ST=Illinois/L=Chicago/O=r509 LLC/CN='.split('/').each do |s|
      key, value = s.split '=', 2
      subject.add_entry key, value
    end
    csr = R509::CSR.new(
                        subject: subject,
                        bit_length: 512,
                        type: 'RSA',
                        message_digest: 'sha1'
                        )
    cert = R509::CertificateAuthority::Signer.selfsign(
                                                       csr: csr,
                                                       not_after: (Time.now.to_i + (86400 * 3650)),
                                                       message_digest: 'sha1'
                                                       )
    
    csr.key.write_pem 'spec/support/ca/root.key'
    cert.write_pem 'spec/support/ca/root.crt'
  end
end
