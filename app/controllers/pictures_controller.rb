class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  MASHAPE_KEY = ENV['MASHAPE_KEY']

  # GET /pictures
  # GET /pictures.json
  def index
    userid = current_user
    @pictures = Picture.where("user_id = ?", userid)
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
  end

  # GET /pictures/new
  def new
    # @picture = Picture.new
    @picture = current_user.pictures.build(params[:picture])
    if params[:image_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:image_id])
      raise "Invalid upload signature" if !preloaded.valid?
      @picture.url = preloaded.identifier
    end
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = current_user.pictures.build(picture_params)

    respond_to do |format|
      if @picture.save
        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        format.json { render :show, status: :created, location: @picture }
      else
        format.html { render :new }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload
    Picture.create(url: "#{params[:address]}.#{params[:format]}", user_id: current_user.id)
    if(params[:redirtag]=="1")
      redirect_to "/"
    end
  end

  # PATCH/PUT /pictures/1
  # PATCH/PUT /pictures/1.json
  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.html { redirect_to @picture, notice: 'Picture was successfully updated.' }
        format.json { render :show, status: :ok, location: @picture }
      else
        format.html { render :edit }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture.destroy
    respond_to do |format|
      format.html { redirect_to pictures_url, notice: 'The picture has been unricked!' }
      format.json { head :no_content }
    end
  end

  def frs
    require "httparty"
    db_url = params[:address]
    response = HTTParty.get "https://apicloud-facerect.p.mashape.com/process-url.json?features=true&url=#{db_url}",
    headers:{
      "X-Mashape-Key" => MASHAPE_KEY,
      "Accept" => "text/plain"
    }
    @coords = response.parsed_response
    render :json => @coords
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      params.require(:picture).permit(:url)
    end
end
