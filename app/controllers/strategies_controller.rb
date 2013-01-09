class StrategiesController < ApplicationController
  def show
    @strategy = Strategy.find(params[:id])
  end
end
