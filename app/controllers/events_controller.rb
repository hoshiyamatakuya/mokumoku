# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @q = Event.future.ransack(params[:q])
    @events = @q.result(distinct: true).includes(:bookmarks, :prefecture, user: { avatar_attachment: :blob })
                .order(created_at: :desc).page(params[:page])
  end

  def future
    @q = Event.future.ransack(params[:q])
    @events = @q.result(distinct: true).includes(:bookmarks, :prefecture, user: { avatar_attachment: :blob })
                .order(held_at: :asc).page(params[:page])
    @search_path = future_events_path
    render :index
  end

  def past
    @q = Event.past.ransack(params[:q])
    @events = @q.result(distinct: true).includes(:bookmarks, :prefecture, user: { avatar_attachment: :blob })
                .order(held_at: :desc).page(params[:page])
    @search_path = past_events_path
    render :index
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)
    tag_list=params[:event][:name].split(',')
    if @event.save
      @event.save_tag(tag_list)
      User.all.find_each do |user|
        NotificationFacade.created_event(@event, user)
      end

      redirect_to event_path(@event)
    else
      render :new
    end
  end

  def show
    @event = Event.find(params[:id])
    @event_tags = @event.tags
  end

  def edit
    @event = current_user.events.find(params[:id])
    @tag_list=@event.tags.pluck(:name).join(',')
  end

  def update
    @event = current_user.events.find(params[:id])
    tag_list=params[:event][:name].split(',')
    if @event.update(event_params)
      @event.save_tag(tag_list)
      redirect_to event_path(@event)
    else
      render :edit
    end
  end
  def search_tag
    @tag_list=Tag.all

    @tag=Tag.find(params[:tag_id])

    @events=@tag.events.page(params[:page]).per(10)
  end

  private

  def event_params
    params.require(:event).permit(:title, :content, :held_at, :prefecture_id, :thumbnail)
  end
end
