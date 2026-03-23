require 'swagger_helper'

RSpec.describe 'Test API', type: :request do
  path '/test' do
    get 'Test endpoint' do
      response '200', 'success' do
        run_test!
      end
    end
  end
end
