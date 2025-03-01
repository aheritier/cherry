# frozen_string_literal: true

class Api::PushesController < Api::ApplicationController
  include Api::ProjectScoped

  def create
    ActiveRecord::Base.transaction do
      params
        .require(:metrics)
        .each do |metric_params|
          metric = Metric.find_or_create_by!(name: metric_params.require('name'), project: current_project)
          occurrences = metric_params[:occurrences]
          report =
            metric.reports.create!(
              date: params[:date] || Time.current,
              value: metric_params[:value] || get_value(occurrences),
              value_by_owner: metric_params[:value_by_owner] || get_value_by_owner(occurrences),
            )

          next if occurrences.blank?
          Occurrence.upsert_all(
            occurrences.map do |occurrence|
              text = occurrence['text'] || occurrence['name'] # TODO: remove name once migrated all its usage
              occurrence.slice(:url, :value, :owners).merge(text:, report_id: report.id)
            end,
          )
        end
    end

    render json: { status: :ok }, status: :ok
  end

  private

  def get_value(occurrences)
    occurrences.sum { |occurrence| occurrence['value'] || 1 }
  end

  def get_value_by_owner(occurrences)
    return {} if occurrences.empty?

    occurrences.each_with_object({}) do |occurrence, owners|
      Array
        .wrap(occurrence['owners'])
        .each do |owner|
          owners[owner] ||= 0
          owners[owner] += (occurrence['value'] || 1).to_f
        end
    end
  end
end
