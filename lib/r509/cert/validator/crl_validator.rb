module R509
  class Cert
    class Validator
      class CrlValidator < BasicValidator
        def available?
          return false unless cdp
          return false if uris.empty?
          return true
        end

        def validate!(crl_file = nil)
          if !available? && crl_file.nil?
            raise Error.new "Tried to validate CRL but cert has no CRL data"
          end

          crl = unless crl_file.nil?
                  File.read crl_file
                else
                  get(uris.first)
                end

          body = R509::CRL::SignedList.new(crl)

          if @issuer
            unless body.verify @issuer.public_key
              raise CrlError.new "CRL did not match certificate"
            end
          end

          if body.revoked? @cert.serial
            raise CrlError.new "CRL listed certificate as revoked"
          end

          return true
        end

        private
        def cdp
          @cert.crl_distribution_points
        end

        def uris
          cdp.uris
        end
      end
    end
  end
end
