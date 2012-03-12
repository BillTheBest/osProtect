class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  load_and_authorize_resource

  def index
    @title = "Groups"
    @groups = Group.order("updated_at desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    redirect_to groups_url
    # @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def create
    # note: activerecord will ignore the empty values for user_ids/sensor_ids, so while 
    #       the following code isn't necessary it does make the situation clearer:
    params[:group][:user_ids].reject!(&:empty?) unless params[:group][:user_ids].blank?
    params[:group][:sensor_ids].reject!(&:empty?) unless params[:group][:sensor_ids].blank?
    @group = Group.new(params[:group])
    if @group.save
      redirect_to groups_url, notice: 'Group was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    # note: activerecord will ignore the empty values for user_ids/sensor_ids, so while 
    #       the following code isn't necessary it does make the situation clearer:
    params[:group][:user_ids].reject!(&:empty?) unless params[:group][:user_ids].blank?
    params[:group][:sensor_ids].reject!(&:empty?) unless params[:group][:sensor_ids].blank?
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      redirect_to groups_url, notice: 'Group was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @group = Group.find(params[:id])
    if @group.group_is_admins?
      flash[:error] = "Deleting the admins group is not allowed."
      redirect_to groups_url
      return 
    end
    @group.destroy
    redirect_to groups_url
  end
end
