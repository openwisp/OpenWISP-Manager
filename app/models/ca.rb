require 'openssl'

class Ca < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :c, :st, :l, :o, :cn
  validates_format_of :c,  :with => /\A[\s\w\d\._']+\Z/i
  validates_length_of :c,  :maximum => 32
  validates_format_of :st, :with => /\A[\s\w\d\._']+\Z/i
  validates_length_of :st, :maximum => 32
  validates_format_of :l,  :with => /\A[\s\w\d\._']+\Z/i
  validates_length_of :l,  :maximum => 32
  validates_format_of :o,  :with => /\A[\s\w\d\._']+\Z/i
  validates_length_of :o,  :maximum => 128
  validates_format_of :cn, :with => /\A[\s\w\d\._']+\Z/i
  validates_length_of :cn, :maximum => 128

  has_many :x509_certificates, :dependent => :destroy
  has_one :x509_certificate, :as => :certificable, :dependent => :destroy

  belongs_to :wisp

  CA_CERT_EXTENSIONS = [
      "basicConstraints = CA:TRUE",
      "nsComment = CA - autogenerated Certificate",
      "keyUsage = cRLSign, keyCertSign"
  ]

  CLIENT_CERT_EXTENSIONS = [
      "basicConstraints = CA:FALSE",
      "nsCertType = client",
      "nsComment = OpenVPN client - autogenerated Certificate",
      "extendedKeyUsage = clientAuth",
      "keyUsage = digitalSignature, keyEncipherment"
  ]

  SERVER_CERT_EXTENSIONS = [
      "basicConstraints = CA:FALSE",
      "nsCertType = server",
      "nsComment = OpenVPN server - autogenerated Certificate",
      "extendedKeyUsage = serverAuth",
      "keyUsage = digitalSignature, keyEncipherment"
  ]

  CA_KEY_LEN = 1024
  CA_CRT_EXPIRE = (3600 * 24 * 365) * 10 # 10 year

  CLIENT_KEY_LEN = 1024
  CLIENT_CRT_EXPIRE = (3600 * 24 * 365)

  after_create { |record|
    _key = OpenSSL::PKey::RSA.generate(Ca::CA_KEY_LEN)

    subject = OpenSSL::X509::Name.parse(record.dn)

    ef = OpenSSL::X509::ExtensionFactory.new

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = subject
    cert.issuer = subject
    cert.public_key = _key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + Ca::CA_CRT_EXPIRE

    ef.subject_certificate = cert
    ef.issuer_certificate = cert

    Ca::CA_CERT_EXTENSIONS.each do |e|
      cert.add_extension(ef.create_ext_from_string(e))
    end

    cert.add_extension( ef.create_extension("subjectKeyIdentifier", "hash") )
    cert.add_extension( ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always") )

    cert.sign(_key, OpenSSL::Digest::SHA1.new)

    record.x509_certificate = X509Certificate.create(
        :dn => record.dn,
        :ca => record,
        :certificable => record,
        :certificate => cert.to_pem,
        :key => _key.to_pem
    )
  }

  def initialize(params = nil)
    super(params)

    self.serial = 1
  end

  # Certificable interface
  def identifier
    "ca_#{self.id}_" + self.cn.gsub(/ /,'_')
  end


  def create_openvpn_client_certificate(c)

    self.lock!
    self.serial += 1
    self.save

    _key = OpenSSL::PKey::RSA.generate(Ca::CLIENT_KEY_LEN)

    issuer = OpenSSL::X509::Name.parse(self.dn)

    _dn = "#{self.dn_prefix}/CN=#{c.identifier}"

    ef = OpenSSL::X509::ExtensionFactory.new

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = self.serial
    cert.subject = OpenSSL::X509::Name.parse(_dn)
    cert.issuer = issuer
    cert.public_key = _key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + Ca::CLIENT_CRT_EXPIRE

    ef.subject_certificate = cert
    ef.issuer_certificate = OpenSSL::X509::Certificate.new(self.x509_certificate.certificate)

    Ca::CLIENT_CERT_EXTENSIONS.each do |e|
      cert.add_extension(ef.create_ext_from_string(e))
    end

    cert.add_extension( ef.create_extension("subjectKeyIdentifier", "hash") )
    cert.add_extension( ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always") )

    cert.sign(OpenSSL::PKey::RSA.new(self.x509_certificate.key), OpenSSL::Digest::SHA1.new)

    self.x509_certificates.create(
        :dn => _dn,
        :ca => self,
        :certificable => c,
        :certificate => cert.to_pem,
        :key => _key.to_pem
    )
  end

  def create_openvpn_server_certificate(c)

    self.lock!
    self.serial += 1
    self.save

    _key = OpenSSL::PKey::RSA.generate(Ca::CLIENT_KEY_LEN)

    issuer = OpenSSL::X509::Name.parse(self.dn)

    _dn = "#{self.dn_prefix}/CN=#{c.identifier}"

    ef = OpenSSL::X509::ExtensionFactory.new

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = self.serial
    cert.subject = OpenSSL::X509::Name.parse(_dn)
    cert.issuer = issuer
    cert.public_key = _key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + Ca::CLIENT_CRT_EXPIRE

    ef.subject_certificate = cert
    ef.issuer_certificate = OpenSSL::X509::Certificate.new(self.x509_certificate.certificate)

    Ca::SERVER_CERT_EXTENSIONS.each do |e|
      cert.add_extension(ef.create_ext_from_string(e))
    end

    cert.add_extension( ef.create_extension("subjectKeyIdentifier", "hash") )
    cert.add_extension( ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always") )

    cert.sign(OpenSSL::PKey::RSA.new(self.x509_certificate.key), OpenSSL::Digest::SHA1.new)

    self.x509_certificates.create(
        :dn => _dn,
        :ca => self,
        :certificable => c,
        :certificate => cert.to_pem,
        :key => _key.to_pem
    )
  end

  def self.create_DH
    OpenSSL::PKey::DH.new(1024)
  end

#2048 bit OpenVPN static Key
  def self.create_tls_auth
    byte = 2048/8
    size = 32
    s = ""
    t = ""
    OpenSSL::Random::random_bytes(byte).each_byte{ |b| s+= "%02x" % b  }
    (0..(s.length-1)/size).each do |i|
      t += s[i*size,size]+"\n"
    end
    return ("-----BEGIN OpenVPN Static key V1-----\n" + t + "-----END OpenVPN Static key V1-----")
  end

  def dn
    "/C=#{self.c}/ST=#{self.st}/L=#{self.l}/O=#{self.o}/CN=#{self.cn}"
  end

  def dn_prefix
    "/C=#{self.c}/ST=#{self.st}/L=#{self.l}/O=#{self.o}"
  end

  def key
    return read_attribute(:key)
  end

end
