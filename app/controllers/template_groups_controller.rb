class TemplateGroupsController < ApplicationController
  before_filter :load_wisp
  before_filter :load_template_group, :except => [ :index, :new, :create ]

  access_control do
    default :deny
  end

  # GET /wisps/:wisp_id/template_groups
  def index
    @template_groups = @wisp.template_groups

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/template_groups/1
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/template_groups/new
  def new
    @template_group = @wisp.template_groups.new
    @selected_access_point_templates = []

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/template_groups/1/edit
  def edit
    @selected_access_point_templates = @template_group.access_point_templates.collect { |h| h.id }
  end

  # POST /wisps/:wisp_id/template_groups
  def create
    @template_group = @wisp.template_groups.new(params[:template_group])

    @selected_access_point_templates = params[:access_point_templates].nil? ? nil : params[:access_point_templates].collect { |h| h.to_i }

    @template_group.access_point_templates = []
    unless params[:access_point_templates].nil?
      params[:access_point_templates].each { |hid|
        @template_group.access_point_templates << @wisp.access_point_templates.find(hid)
      }
    end

    respond_to do |format|
      if @template_group.save
        flash[:notice] = t(:TemplateGroup_was_successfully_created)
        format.html { redirect_to(wisp_template_groups_url(@wisp)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/template_groups/1
  def update
    @selected_access_point_templates = params[:access_point_templates].nil? ? nil : params[:access_point_templates].collect { |h| h.to_i }

    @template_group.access_point_templates = []
    unless params[:access_point_templates].nil?
      params[:access_point_templates].each { |hid|
        @template_group.access_point_templates << @wisp.access_point_templates.find(hid)
      }
    end

    respond_to do |format|
      if @template_group.update_attributes(params[:template_group])
        flash[:notice] = t(:TemplateGroup_was_successfully_updated)
        format.html { redirect_to(wisp_template_groups_url(@wisp)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/template_groups/1
  def destroy
    @template_group.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_template_groups_url(@wisp)) }
    end
  end

  private

  def load_template_group
    @template_group = @wisp.template_groups.find(params[:id])
  end
end
