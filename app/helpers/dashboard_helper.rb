module DashboardHelper
  def check_remainder_on(task, day_task, active)
    if (day_task.to_s == Time.now().strftime('%Y-%m-%d').to_s && active)
      system("mumbles-send #{task}")
    end
  end
end
