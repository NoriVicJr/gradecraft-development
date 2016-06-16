class EventsController < ApplicationController

  respond_to :html, :json

  def index
    @events = current_course.events.order("due_at ASC")
    @title = "Calendar Events"
  end

  def show
    @event = current_course.events.find(params[:id])
    @title = @event.name
  end

  def new
    @event = current_course.events.new
    @title = "Create a New Calendar Event"
  end

  def edit
    @event = current_course.events.find(params[:id])
    @title = "Editing #{@event.name}"
  end

  def create
    @event = current_course.events.new(params[:event])
    if @event.save
      flash[:notice] = "Event #{@event.name} was successfully created"
      respond_with(@event)
    else
      @title = "Create a New Calendar Event"
      render :new
    end
  end

  def update
    @event = current_course.events.find(params[:id])
    flash[:notice] = "Event #{@event.name} was successfully updated" if @event.update(params[:event])
    respond_with(@event)
  end

  def destroy
    @event = current_course.events.find(params[:id])
    @name = @event.name
    @event.destroy
    redirect_to events_url, notice: "#{@name} successfully deleted"
  end

end
