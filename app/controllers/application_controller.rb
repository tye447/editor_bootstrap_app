class ApplicationController < ActionController::Base
  def compile_css
    begin
      @result = Sass.compile(params[:scss])
    rescue Exception => e
    end
    render :json => {
      :result => @result.to_s,
      :status => :ok
    }
  end
end