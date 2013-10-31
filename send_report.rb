require 'rubygems'
require 'net/smtp'
require 'date'

puts "Starting to send \n"
if ARGV[0].nil? || ARGV[0].empty?
  puts "Can't get aggregated report to send"
else
  text = File.read(ARGV[0])

  message = <<-END
From: Slow Query log analyzer <analyzer@fromdomain.com>
To: Database optimizator <optimizer@todomain.com>
Subject: Slow Queries Aggregated report for #{Date.today}

#{text}
  END

  Net::SMTP.start('mailtrap.io',
                  2525,
                  'localhost',
                  'login', 'password', :plain) do |smtp|
    smtp.send_message message, 'analyzer@fromdomain.com',
                               'optimizer@todomain.com'
  end
end
puts "Sending complete"
