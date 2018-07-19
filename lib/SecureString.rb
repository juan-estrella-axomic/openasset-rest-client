require 'openssl'

class SecureString

    attr_reader :value

    def initialize(str='')
        @cipher
        @decipher
        @key
        @iv
        @encrypt = true

        @value = str.to_s
    end

    def to_s
        @value
    end

    def empty?
        @value.empty?
    end

    def length
        @value.length
    end
    alias :size :length

    def encrypted?
        @encrypted ? true : false
    end

    def encrypt
        return @value if @encrypted
        @cipher = OpenSSL::Cipher.new('DES-EDE3-CBC')
        @cipher.encrypt
        @key = @cipher.random_key
        @iv = @cipher.random_iv
        @cipher.key = @key
        @value = @cipher.update(@value) + @cipher.final
        @value = @value.unpack('H*')[0].upcase
        @encrypted = true
        @value
    end

    def decrypt
        return @value if !@encrypted
        @decipher = OpenSSL::Cipher.new('DES-EDE3-CBC')
        @decipher.decrypt
        @decipher.key = @key
        @decipher.iv = @iv
        @value = [@value].pack("H*")
        @value = @decipher.update(@value) + @decipher.final
        @encrypted = nil
        @value
    end

end