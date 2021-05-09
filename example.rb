require 'openssl'
require 'base64'

def loop_error
  for i in 0..10
    puts i
    STDOUT.flush # Depending on if this is included changes how the program runs in msys.
    gets if i == 5
  end
end

def encryption_phase
  public_key_file = 'public.pem';
  string = 'test_string_example_I_do_not_know';

  public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
  encrypted_string = Base64.encode64(public_key.public_encrypt(string))

  print encrypted_string, "\n"
  return encrypted_string
end

def decryption_phase
  private_key_file = 'private.pem';

  encrypted_string = "EUqnAtkWdSK8+CIa5QdyDIFSRAOyESw5Er9IZOrG0l4Jv3eCOMk359KewCbI
B7HOsmp2sU4fHRCwUOtdZ92/duF5wY+5mdmrChgTyzSXBBZOOjCDBrNWpMBj
cz/+xCjK++NDrnaLcH3iIop3p7iDws49oGm6OgR/XZm7urCBTs/77NRyHBpP
iEN18w2XlowXUsJL5AN9+6BjBP1d7co6TQulGiIc4QS6cxpSK4gIOr0rCIeV
dcICwHcUlt24TOK8slN8TjY7FvdDuSJHrdq6LnpMiFQ+ny3Pd9kZInx7b3fM
xQHUU7lW8mOnrDsRB0oDFeL1a+JIsL1tCHjUilu0ng=="

  private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file))

  string = private_key.private_decrypt(Base64.decode64(encrypted_string))

  puts string
end

def main
  loop_error
  encrypted = encryption_phase
  decryption_phase
end

main()
