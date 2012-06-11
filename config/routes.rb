ActionController::Routing::Routes.draw do |map|
  map.connect "milestones/show/:id", :controller => :milestones, :action => :show, :conditions => {:method => :get}
  map.connect "projects/:project_id/milestones/add", :controller => :milestones, :action => :add
  map.connect "milestones/edit/:id", :controller => :milestones, :action => :edit
  map.connect "milestones/destroy/:id", :controller => :milestones, :action => :destroy, :conditions => {:method => :delete}
  map.connect "milestones/total_graph/:id", :controller => :milestones, :action => :total_graph, :conditions => {:method => :get}
end
