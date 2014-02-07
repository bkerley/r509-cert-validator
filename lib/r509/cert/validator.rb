require 'r509'
require "r509/cert/validator/version"
require 'r509/cert/validator/errors'
require 'net/http'
require 'base64'

module R509
  class Cert
    class Validator
      # The certificate this Validator will validate
      attr_reader :cert

      def initialize(cert, issuer = nil)
        if cert.is_a? OpenSSL::X509::Certificate
          cert = R509::Cert.new cert: cert
        end
        
        if issuer.is_a? OpenSSL::X509::Certificate
          cert = R509::Cert.new cert: cert
        end

        @cert = cert
        @issuer = issuer
      end

      def validate!(options={})
        opts = { ocsp: ocsp_available?, crl: crl_available? }.merge options

        if opts[:ocsp] && !ocsp_available?
          raise Error.new "Tried to validate OCSP but cert has no OCSP data" 
        end

        if opts[:crl] && !crl_available?
          raise Error.new "Tried to validate CRL but cert has no CRL data"
        end

        validate_ocsp if opts[:ocsp]
        validate_crl if opts[:crl]
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
      def validate_ocsp
        ocsp_uri = @cert.authority_info_access.ocsp.uris.first
        cert_id = OpenSSL::OCSP::CertificateId.new @cert.cert, @issuer.cert
        req = OpenSSL::OCSP::Request.new
        req.add_nonce
        req.add_certid cert_id
        req_pem = Base64.urlsafe_encode64(req.to_der).strip
        req_uri = URI(ocsp_uri+'/'+URI.encode_www_form_component(req_pem))

        resp = Net::HTTP.get_response(req_uri)
        if resp.code != '200'
          raise Error.new("Unexpected HTTP #{resp.code} from OCSP endpoint")
        end

        body = R509::OCSP::Response.parse resp.body

        if body.status != 0
          raise OcspError.new "OCSP status was #{body.status}, expected 0"
        end

        basic = body.basic[0]

        if basic[0].serial != @cert.serial
          raise OcspError.new "OCSP cert serial was #{basic[0].serial}, expected #{@cert.serial}"
        end

        if basic[1] == 1
          raise OcspError.new "OCSP response indicates cert was revoked"
        end

        if basic[1] != 0
          raise OcspError.new "OCSP response was #{basic[1]}, expected 0"
        end

        validity_range = (basic[4]..basic[5])
        unless validity_range.include? current
          raise OcspError.new "OCSP response outside validity window"
        end

        if body.check_nonce req != R509::OCSP::Request::Nonce::PRESENT_AND_EQUAL
          raise OcspError.new "OCSP Nonce was not present and equal to request"
        end

        return true
      end

      def validate_crl
        
      end

      def ocsp_available?
        return false unless @issuer
        return false unless aia = @cert.authority_info_access
        return false unless aia.ocsp
        return false if aia.ocsp.uris.empty?
        return true
      end

      def crl_available?
        return false unless cdp = @cert.crl_distribution_points
        return false if cdp.uris.empty?
        return true
      end
    end
  end
end
