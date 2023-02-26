# frozen_string_literal: true

class User::ProjectsController < User::ApplicationController
  def index
    @projects = current_user.projects.includes(:user)
    render json: @projects.includes(metrics: :reports).order(:name).as_json(include: :user)
  end

  def destroy
    @project = authorize(Project.find(params[:id]), :destroy?)
    @project.destroy!
    redirect_to user_projects_path, notice: 'Project was successfully deleted.'
  end
end
