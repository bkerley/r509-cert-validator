module R509
  class Cert
    class Validator
      class Error < ::StandardError
      end

      class OcspError < Error
      end

      class CrlError < Error
      end
    end
  end
end
