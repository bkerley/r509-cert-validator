require 'r509/cert/validator'

def load_cert(name)
  path = File.join(File.dirname(__FILE__), 'support', 'ca', name)
  data = File.read path
  return OpenSSL::X509::Certificate.new data
end

def cert(name)
  R509::Cert.new cert: load_cert(name)
end
