require 'r509/cert/validator'

def load_cert(name)
  path = File.join(File.dirname(__FILE__), 'support', 'certs', name)
  data = File.read path
  return OpenSSL::X509::Certificate.new data
end
