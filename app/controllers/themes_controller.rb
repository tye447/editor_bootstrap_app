class ThemesController < ApplicationController
  def index
    @themes = Theme.all
    render :json => {
      :result => @themes
    }
  end

  def show
    @theme = Theme.find(params[:id])
    render :json => {
      :result => @theme
    }
  end

  def new
    @theme = Theme.new
    render :json => {
      :result => @theme
    }
  end

  def edit
    @theme = Theme.find(params[:id])
    render :json => {
      :result => @theme
    }
  end

  def create
    @theme = Theme.new
    @theme.save
    render :json => {
      :result => @theme
    }
  end

  def update
    @theme = Theme.find(params[:id])
    @theme.title = params[:title]
    @theme.url = params[:url]
    @theme.save
    render :json => {
      :result => @theme
    }
  end

  def destroy
    # Destroy returns the object (i.e. self); though I believe Mongoid returns a boolean - need to double check this
    @theme = Theme.find(params[:id])
    @theme.destroy
    render :json => {
      :result => @theme
    }
  end
end
