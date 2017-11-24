
require 'openssl'
require 'base64'
require 'socket'

class Security

    # @!visibility private
    def self.encrypt(val)
        cipher=OpenSSL::Cipher.new('DES-EDE3-CBC')
        cipher.encrypt
        cipher.pkcs5_keyivgen("Thequickbrownfoxjumpedoverthelazy#{Socket.gethostname}on#{RUBY_PLATFORM}")
        enc_p = cipher.update(val)
        enc_p << cipher.final
        Base64.encode64(enc_p)
    end

    # @!visibility private
    def self.decrypt(val)
        decipher=OpenSSL::Cipher.new('DES-EDE3-CBC')
        decipher.decrypt
        decipher.pkcs5_keyivgen("Thequickbrownfoxjumpedoverthelazy#{Socket.gethostname}on#{RUBY_PLATFORM}")
        b64_dec_p = Base64.decode64(val)
        plain = decipher.update(b64_dec_p)
        plain << decipher.final
        plain
    end
end     