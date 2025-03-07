# frozen_string_literal: true

class Api::ContributionsController < Api::ApplicationController
  include Api::ProjectScoped

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    ActiveRecord::Base.transaction do
      params
        .require(:contributions)
        .each do |contribution_params|
          metric = Metric.find_or_create_by!(name: contribution_params.require('metric_name'), project: current_project)

          contribution = metric.contributions.find_or_initialize_by(commit_sha: params[:commit_sha])

          contribution.update!(
            author_name: params[:author_name],
            author_email: params[:author_email],
            commit_date: params[:commit_date],
            diff: contribution_params.require('diff'),
          )

          contribution.notify_watchers!
        end
    end

    render json: { status: :ok }, status: :ok
  end
end
