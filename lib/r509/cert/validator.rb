require 'r509'
%w{version errors basic_validator ocsp_validator crl_validator}.each do |f|
  require "r509/cert/validator/#{f}"
end

module R509
  class Cert
    class Validator
      # The certificate this Validator will validate
      attr_reader :cert

      def initialize(cert, issuer = nil, options = {})
        if cert.is_a? OpenSSL::X509::Certificate
          cert = R509::Cert.new cert: cert
        end
        
        if issuer.is_a? OpenSSL::X509::Certificate
          issuer = R509::Cert.new cert: issuer
        end

        @cert = cert
        @issuer = issuer

        initialize_validators
      end

      def validate!(options={})
        opts = { ocsp: @ocsp.available?, crl: @crl.available? }.merge options

        if opts[:ocsp] && !@ocsp.available?
          raise Error.new "Tried to validate OCSP but cert has no OCSP data" 
        end

        crl_file = opts[:crl_file]

        crl_available = @crl.available? || (crl_file && File.exist?(crl_file))

        if opts[:crl] && !crl_available
          raise Error.new "Tried to validate CRL but cert has no CRL data"
        end

        @ocsp.validate! if opts[:ocsp]
        @crl.validate!(crl_file) if opts[:crl]
        true
      end

      def validate(options={})
        begin
          validate! options
        rescue OcspError
          return false
        rescue CrlError
          return false
        end

        return true
      end

      private
      def initialize_validators
        @ocsp = OcspValidator.new @cert, @issuer
        @crl = CrlValidator.new @cert, @issuer
      end
    end
  end
end
