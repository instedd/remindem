class AddDefaultToSchedulesPaused < ActiveRecord::Migration
  def up
    change_column :schedules, :paused, :boolean, default: false
    connection.execute("UPDATE schedules SET paused = 0 WHERE paused IS NULL")
  end

  def down
    change_column :schedules, :paused, :boolean, default: nil
  end
end
