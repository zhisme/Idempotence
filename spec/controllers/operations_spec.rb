require 'rails_helper'

RSpec.describe OperationsController, type: :controller do
  after { REDIS.flushdb } 

  describe 'POST #create' do
    subject { post :create, params: }

    context 'when number is valid' do
      let(:params) { { number: 10 } }

      it 'updates sum without idempotency key' do
        Operation.create(total: 10)
        subject
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['total']).to eq(20)
      end

    end

    context 'with idempotency key' do
      let(:params) { { number: 20, idempotency_key: 'test_key' } }

      it 'updates sum with idempotency key' do
        subject
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['total']).to eq(20)

        subject
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['total']).to eq(20)
      end
    end

    context 'when number is invalid' do
      let(:params) { { number: -5 } }

      it 'returns error for negative number' do
        subject
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['errors']).to eq(['Number must be a positive integer'])
      end
    end

    context 'when resource is locked' do
      let(:params) { { number: 10 } }

      it 'returns conflict if resource is locked' do
        REDIS.set('lock_sum_update', 'locked', ex: 10) 

        subject
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)['errors']).to eq(['Resource is locked. Try again later.'])
      end
    end
  end
end
