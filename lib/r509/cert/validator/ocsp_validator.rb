require 'base64'

module R509
  class Cert
    class Validator
      class OcspValidator < BasicValidator
        def available?
          return false unless @issuer
          return false unless aia && aia.ocsp
          return false if ocsp_uris.empty?
          return true
        end

        def validate!
          unless available?
            raise Error.new "Tried to validate OCSP but cert has no OCSP data"
          end
          
          uri = build_request_uri
          body = R509::OCSP::Response.parse(get(uri))
          
          check_ocsp_response body
          check_ocsp_payload body.basic.status.first
          return true
        end

        private
        def build_request_uri
          @req = OpenSSL::OCSP::Request.new
          @req.add_nonce
          @req.add_certid cert_id
          pem = Base64.encode64(@req.to_der).strip
          URI(ocsp_uris.first + '/' + URI.encode_www_form_component(pem))
        end
        
        def check_ocsp_response(body)
          unless body.status == 0
            raise OcspError.new "OCSP status was #{body.status}, expected 0"
          end

          unless body.verify(@issuer.cert)
            raise OcspError.new "OCSP response did not match issuer"
          end

          unless body.basic.status.first
            raise OcspError.new "OCSP response was missing payload"
          end

          if body.check_nonce(@req) != R509::OCSP::Request::Nonce::PRESENT_AND_EQUAL
            raise OcspError.new "OCSP Nonce was not present and equal to request"
          end
        end

        def check_ocsp_payload(basic)
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
          unless validity_range.cover? Time.now
            raise OcspError.new "OCSP response outside validity window"
          end
        end

        def aia
          @aia ||= @cert.authority_info_access
        end

        def ocsp_uris
          aia.ocsp.uris
        end

        def cert_id
          @cert_id ||= OpenSSL::OCSP::CertificateId.new @cert.cert, @issuer.cert
        end
      end
    end
  end
end
