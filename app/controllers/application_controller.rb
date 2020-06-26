class ApplicationController < ActionController::Base
  def compile_css
    begin
      @result = Sass.compile(params[:scss])
      render :json => {
        :message => @result.to_s,
        :status => :ok
      }
    rescue Exception => e
      render :json => {
        :message => e,
        :status => 400
      }
    end

  end
end