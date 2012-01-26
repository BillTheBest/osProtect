class TestWorker
  @queue = :test_worker_queue
  def self.perform(id, name)
    SensorName.create!(name: name, sensor_id: id)
  end
end