require 'r509/ocsp/responder/server'
require 'r509/validity/crl'
require 'dependo'
require 'logger'
require 'rack'

crl_paths = [File.join(File.dirname(__FILE__), 'ca/rcv_spec.crl')]

reload_interval = '5s' #yolo
Dependo::Registry[:validity_checker] = R509::Validity::CRL::Checker.new(
                                                                        crl_paths, 
                                                                        reload_interval
                                                                        )
Dependo::Registry[:log] = Logger.new STDERR

Dir.chdir File.join(File.dirname(__FILE__), 'ca') do
  R509::OCSP::Responder::OCSPConfig.load_config
end
R509::OCSP::Responder::OCSPConfig.print_config

responder = R509::OCSP::Responder::Server

Rack::Server.start(
                   app: Rack::URLMap.new(
                                         '/ocsp' => R509::OCSP::Responder::Server,
                                         '/crl' => Rack::File.new(File.join(File.dirname(__FILE__), 'ca', 'rcv_spec.crl'))
                                         ),
                   Port: 22022
                   )
