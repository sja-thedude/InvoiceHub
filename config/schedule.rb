# Cron schedule for the `whenever` gem. Generate the crontab with:
#   bundle exec whenever --update-crontab
# On Render, configure these as Cron Jobs instead (see render.yaml).

set :output, "log/cron.log"

every 1.day, at: "6:00 am" do
  rake "invoices:daily"
end
