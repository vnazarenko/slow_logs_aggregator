require 'rubygems'
require 'net/smtp'
require 'date'

puts "Starting to send \n"
if ARGV[0].nil? || ARGV[0].empty?
  puts "Can't get aggregated report to send"
else
  text = File.read(ARGV[0])

  message = <<-END.split("\n").map!(&:strip).join("\n")
  From: Private Person <me@fromdomain.com>
  To: A Test User <test@todomain.com>
  Subject: Slow Queries Aggregated report for #{Date.today}

  #{text}
  END

  Net::SMTP.start('mailtrap.io',
                  2525,
                  'localhost',
                  'login', 'password', :plain) do |smtp|
    smtp.send_message message, 'me@fromdomain.com',
                               'test@todomain.com'
  end
end
puts "Sending complete"
