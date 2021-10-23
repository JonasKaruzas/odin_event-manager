require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone(phone)
  phone = phone.gsub(/[^0-9]/, '')
  pl = phone.length

  if pl == 10
    phone
  elsif pl < 10
    ''
  elsif pl == 11 && phone[0] == '1'
    phone[1, 10]
  else
    ''
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin  
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'Google for the info'
  end
  
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  
  filename = "output/thanks_#{id}.html"                                  
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end

end

def number_to_weekday(num)
  case num.wday
  when 0
    "Sunday"
  when 1
    "Monay"
  when 2
    "Tuesday"
  when 3
    "Wednesday"
  when 4
    "Thursday"
  when 5
    "Friday"
  when 6
    "Saturday"
  else
    "Something is verry bad"
  end
end

puts 'Event Manager Initialized!'
puts ''

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol)
  
  template_letter = File.read('form_letter.erb')
  erb_template = ERB.new template_letter

best_hours = []
best_day = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = clean_phone(row[:homephone])
  regdate = row[:regdate]
  # zipcode = clean_zipcode(row[:zipcode])
  # legislators = legislators_by_zipcode(zipcode)
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id, form_letter)
  
  hour = Time.strptime(regdate, "%m/%d/%y %k:%M").strftime("%k")
  best_hours.push(hour)

  day = Date.strptime(regdate, "%m/%d/%y %k:%M")
  best_day.push(number_to_weekday(day))

end


puts 'Registration hours'
pp best_hours.tally
puts ''
puts 'Registration day of the week'
pp best_day.tally