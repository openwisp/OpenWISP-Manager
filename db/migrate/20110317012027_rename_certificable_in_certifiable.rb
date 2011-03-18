class RenameCertificableInCertifiable < ActiveRecord::Migration
  def self.up
    rename_column :x509_certificates, :certificable_id, :certifiable_id
    rename_column :x509_certificates, :certificable_type, :certifiable_type
  end

  def self.down
    rename_column :x509_certificates, :certifiable_type, :certificable_type
    rename_column :x509_certificates, :certifiable_id, :certificable_id
  end
end
