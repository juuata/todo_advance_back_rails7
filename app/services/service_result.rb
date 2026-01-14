# frozen_string_literal: true

class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data: nil, errors: nil)
    @success = success
    @data = data
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  class << self
    def success(data = nil)
      new(success: true, data: data)
    end

    def failure(errors = nil)
      new(success: false, errors: errors)
    end
  end
end
