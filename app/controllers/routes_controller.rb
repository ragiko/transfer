require 'json'
require 'time'
require 'uri'


class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]

  # GET /routes
  # GET /routes.json
  def index
    if (params.keys.size >= 8)
      # get param
      p = params
      from = p["from"]
      to = p["to"]
      y = p["y"]
      m = p["m"]
      d = p["d"]
      hour = p["hh"]
      min = p["mm"]
      leave_reach = p["lr"] == "l" ? "出発" : "到着"

    end

    @routes = Route.all

    jr_routes = Transfer::Jr::search(from="岐阜", to="名古屋", 2015, 6, 14, hour=10, min=00, "出発")
    @jr_route = jr_routes.size > 0 ? jr_routes.first : nil
  end

  def sub

    @origin_bus="岐阜大学"
    @dest_bus="JR岐阜"
    @origin_station="岐阜"
    @dest_station="名古屋"

    uri=URI.escape('http://api-gifubus.herokuapp.com/v1?date=2015/01/14&time=1605&start_arrive=0&start_name=繰舟橋&arrive_name=下佐波')

    # uri=URI.escape('http://api-gifubus.herokuapp.com/v1?date=2015/01/14&time=1605&start_arrive=0&start_name=岐阜大学&arrive_name=JR岐阜')
    uri = URI.parse(uri)
    json = Net::HTTP.get(uri)
    result = JSON.parse(json)


    @bus_first=result["data"].first
    @bus_last=result["data"].first["info"].last

    bus_arrive=result["data"].first["info"].last["arrive_time"]

    bus_arrivetime=Time.parse(bus_arrive)
    bus_arrivetime=bus_arrivetime+300

    jrstart_hour=bus_arrivetime.hour
    jrstart_min=bus_arrivetime.min

    @result2=Transfer::Jr::search("岐阜","名古屋",2015,1,14,jrstart_hour,jrstart_min,"出発")
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
  end

  # GET /routes/new
  def new
    @route = Route.new
  end

  # GET /routes/1/edit
  def edit
  end

  # POST /routes
  # POST /routes.json
  def create
    @route = Route.new(route_params)

    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: 'Route was successfully created.' }
        format.json { render :show, status: :created, location: @route }
      else
        format.html { render :new }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /routes/1
  # PATCH/PUT /routes/1.json
  def update
    respond_to do |format|
      if @route.update(route_params)
        format.html { redirect_to @route, notice: 'Route was successfully updated.' }
        format.json { render :show, status: :ok, location: @route }
      else
        format.html { render :edit }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route.destroy
    respond_to do |format|
      format.html { redirect_to routes_url, notice: 'Route was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = Route.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
      params.require(:route).permit(:content)
    end
end
