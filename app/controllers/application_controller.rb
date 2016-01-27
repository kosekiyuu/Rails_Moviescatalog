class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  #protect_from_forgery with: :null_session


  #2013/01/31 02:33
  #qiita.com/Nunocky/items/573237af88ffae264f8d
  def after_sign_in_path_for(movies)
      contributor_path
  end


  #devise authetification
  before_action :authenticate_user!, :except => [:show, :index]


#2014/01/20 22:13
#http://stackoverflow.com/questions/16297797/add-custom-field-column-to-devise-with-rails-4
#http://stackoverflow.com/questions/16852377/custom-user-fields-in-devise-3-under-rails-4
    before_filter :configure_permitted_parameters, if: :devise_controller?

    protected

     def configure_permitted_parameters
         devise_parameter_sanitizer.for(:sign_in) << :contributor
         devise_parameter_sanitizer.for(:sign_up) << :contributor
         devise_parameter_sanitizer.for(:account_update) << :contributor
     end

end
