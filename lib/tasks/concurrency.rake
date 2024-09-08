require 'net/http'
require 'json'

namespace :concurrency do
  desc 'Test concurrency for operations controller'
  task execute_test: :environment do
    uri = URI.parse("http://localhost:3000/operations")
    
    num_threads = 20
    threads = []
    request_params = { number: 5 }

    puts "Starting #{num_threads} concurrent requests..."

    num_threads.times do |i|

      threads << Thread.new do
        req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
        if rand(10) % 2 == 0
          request_params[:idempotency_key] = 'concurrency_test' 
        end
        req.body = request_params.to_json


        begin
          res = Net::HTTP.start(uri.host, uri.port) do |http|
            http.request(req)
          end

          result = JSON.parse(res.body)
          puts "Thread %02d: Params: %50s, Status: #{res.code}, Total: #{result['total']}" % [i, req.body]
        rescue => e
          puts "Thread %02d failed: #{e.message}" % [i]
        end
      end
    end

    threads.each(&:join)

    puts "All threads finished."
  end
end
