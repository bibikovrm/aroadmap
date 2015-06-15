# encoding: UTF-8

# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/advanced-roadmap
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

module AdvancedRoadmap
  class ViewHooks < Redmine::Hook::ViewListener

    render_on(:view_projects_show_sidebar_bottom, :partial => "hooks/milestones")
    render_on(:view_issues_sidebar_planning_bottom, :partial => "hooks/milestones")
    render_on(:view_issues_show_details_bottom, :partial => "hooks/issues/show")
    render_on(:view_layouts_base_html_head, :partial => "hooks/stylesheet")

  end
end
