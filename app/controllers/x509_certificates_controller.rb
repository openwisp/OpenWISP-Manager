class X509CertificatesController < ApplicationController
  before_filter :load_wisp

  access_control do
    default :deny

    actions :show do
      allow :wisps_viewer
      allow :wisp_viewer, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :wisp_viewer, :of => :wisp
    end
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  
  # GET /wisps/:wisp_id/ca/x509_certificates/1
  def show
    @ca = @wisp.ca
    @x509_certificate = @ca.x509_certificates.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # DELETE /wisps/:wisp_id/ca/x509_certificates/1
  def destroy
    @ca = @wisp.ca
    @x509_certificate = @ca.x509_certificates.find(params[:id])
    @x509_certificate.revoke
    
    respond_to do |format|
      format.html { redirect_to(wisp_ca_url(@wisp)) }
    end
  end

end
