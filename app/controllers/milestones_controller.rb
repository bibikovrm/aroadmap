# encoding: UTF-8

# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/advanced-roadmap
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

require "advanced_roadmap/gruff/pie"

class MilestonesController < ApplicationController
  
  menu_item :roadmap
  model_object Milestone

  before_filter :find_model_object,
                :only => [:show, :edit, :update, :destroy]
  before_filter :find_project_from_association,
                :only => [:show, :edit, :update, :destroy]
  before_filter :find_project_by_project_id,
                :only => [:new, :create]
  before_filter :authorize, :except => [:show, :total_graph]

  helper :custom_fields
  helper :projects
  helper :versions
  include CustomFieldsHelper
  include ProjectsHelper
  include VersionsHelper
   
  def show
    projects = {}
    @milestone.versions.each do |version|
      version.fixed_issues.each do |issue|
        if !(projects.include?(issue.project.id))
          projects[issue.project.id] = issue.project.id
        end
      end
    end
    Version.sort_versions(@milestone.versions)
    @more_than_one_project = (projects.length > 1)
    @totals = Version.calculate_totals(@milestone.versions)
  end
  
  def new
    @projects = Project.all.sort { |a, b| a.name.downcase <=> b.name.downcase }
    @versions = @project.versions
    @milestone = Milestone.new
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def create
    @milestone = @project.milestones.build(params[:milestone])
    @milestone.user_id = User.current.id
    if request.post? and @milestone.save
      if params[:versions]
        params[:versions].each do |version|
          milestone_version = MilestoneVersion.new
          milestone_version.milestone_id = @milestone.id
          milestone_version.version_id = version
          milestone_version.save
        end
       end
      flash[:notice] = l(:notice_successful_create)
      redirect_to :controller => :projects, :action => :settings, :tab => "milestones", :id => @project
    end
  rescue ActiveRecord::RecordNotFound => e
    puts("%%% excepcion: #{e.inspect}")
    render_404
  end
  
  def edit
    @projects = Project.all.sort { |a, b| a.name.downcase <=> b.name.downcase }
    @versions = @project.versions
  end

  def update
    @projects = Project.all.sort { |a, b| a.name.downcase <=> b.name.downcase }
    @versions = @project.versions
    versions_to_delete = @milestone.versions
    versions_to_add = []
    if params[:versions]
      params[:versions].each do |version|
        index = @milestone.versions.index(version)
        if index != nil
          versions_to_delete.remove(index)
        else
          versions_to_add << version
        end
      end
    end
    if @milestone.update_attributes(params[:milestone])
      versions_to_delete.each do |version|
        milestone_version = MilestoneVersion.where(:milestone_id => @milestone.id, :version_id => version.id).first
        milestone_version.destroy
      end
      versions_to_add.each do |version|
        milestone_version = MilestoneVersion.new
        milestone_version.milestone_id = @milestone.id
        milestone_version.version_id = version
        milestone_version.save
      end
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => :projects, :action => :settings, :tab => "milestones", :id => @project
    end
  end

  def destroy
    @milestone.destroy
    redirect_to :controller => :projects, :action => :settings, :tab => "milestones", :id => @project
  rescue
    flash[:error] = l(:notice_unable_delete_milestone)
    redirect_to :controller => :projects, :action => :settings, :tab => "milestones", :id => @project
  end

  def total_graph
    g = AdvancedRoadmap::Gruff::Pie.new(params[:size] || "500x400")
    g.hide_title = true
    g.theme = graph_theme
    g.margins = 0

    versions = params[:versions] || []
    percentajes = params[:percentajes] || []
    i = 0
    while i < versions.size and i < percentajes.size
      percentajes[i] = percentajes[i].to_f
      g.data(versions[i], percentajes[i])
      i += 1
    end

    headers["Content-Type"] = "image/png"
    send_data(g.to_blob, :type => "image/png", :disposition => "inline")
  end

private

  def graph_theme
    {
      :colors => ["#DB2626", "#6A6ADB", "#64D564", "#F727F7", "#EBEB20", "#303030", "#12ABAD", "#808080", "#B7580B", "#316211"],
      :marker_color => "#AAAAAA",
      :background_colors => ["#FFFFFF", "#FFFFFF"]
    }
  end

end
