module RunDelayedJobs

  def run_delayed_jobs
    ResqueSpec.queues.each_key do |queue|
      ResqueSpec.perform_all(queue)
    end
  end

end
  
RSpec.configuration.include(RunDelayedJobs)
