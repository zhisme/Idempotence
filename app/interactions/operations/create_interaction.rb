class Operations::CreateInteraction < ActiveInteraction::Base
  integer :number, default: 0
  string :idempotency_key, default: nil

  LOCK_KEY = 'lock_sum_update'.freeze
  IDEMPOTENCY_EXPIRE = 300
  LOCK_EXPIRE = 10

  attr_reader :operation
  
  def execute
    if REDIS.set(LOCK_KEY, "locked", nx: true, ex: LOCK_EXPIRE)
      begin
        new_total = operation.total + number
        operation.update!(total: new_total)
        REDIS.set(idempotency_key, new_total, ex: IDEMPOTENCY_EXPIRE) if idempotency_key.present?

        new_total
      ensure
        REDIS.del(LOCK_KEY)
      end
    else
      errors.add(:resource, 'is locked. Try again later.')
    end
  end

  private

  def operation
    @operation ||= Operation.first || Operation.create
  end
end
