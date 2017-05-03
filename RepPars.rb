require 'csv'
repdir = ""
env =""
repn = ""
comm = ""
min = ""
hour = ""
wday = ""
day = ""
br = ""
dest = ""
env2 =""
CSV.open('C:/Users/poar/Desktop/Res.csv', "wb") do |csv|
csv << ["Environment","ReportName","Command","Time","WeekDay","DayOfMonth","Brand","Destination"]
Dir.glob('C:/Users/poar/Documents/GitHub/System/chef/cookbooks/reports/recipes/*.rb') do |rb_file|
f = File.open(rb_file, "r")
     env2 = rb_file.sub('C:/Users/poar/Documents/GitHub/System/chef/cookbooks/reports/recipes/','')
f.each_line { |line|
  if line =~ /reports_cron/ || line =~ /^cron /
    if (comm !~ /#+/ || comm =~ /\#{/) && (hour !~ /#+/ || min !~ /#+/) && repdir !~ /#+/ && !repdir.to_s.empty?
      csv << [env.gsub('  ','').gsub("\n",'').gsub("  ",'').gsub("_",'-').gsub("-additional-cronjobs.rb",'').gsub(".rb",''),
	          repdir.gsub("'",'').gsub("\n",'').gsub("  ",''),
			  comm.gsub("'",'').gsub("\n",'').gsub("  ",''),
			  "At " << hour.gsub("'",'').gsub("\n",'').gsub("  ",'').gsub("*/",'every ') << " hour " << min.gsub("'",'').gsub("\n",'').gsub("  ",'').gsub("*/",'every ') << " min",
			  wday.gsub("'",'').gsub("\n",'').gsub(" ",'').gsub("0",'Sunday').gsub("1",'Monday').gsub("2",'Tuesday').gsub("3",'Wednesday').gsub("4",'Thursday').gsub("5",'Friday').gsub("6",'Saturday'),
			  day.gsub("'",'').gsub("\n",'').gsub("  ",''),
			  br.gsub("'",'').gsub("\n",'').gsub("  ",''),
			  dest.gsub("  ",'').gsub("\n",'').gsub("'",'').gsub('"','')]
	end
	  env = env2
	  dest = ""
	  comm = ""
	  wday="Daily"
	  day=""
	  br = ""
	  min = ""
	  hour = ""
	 if line =~ /^cron /
        repdir = line.sub(/^cron '/, '').sub(/' do/,'')
     end
  elsif line =~ /command/
     comm = line.gsub("command",'').gsub("\n",'')
	  if line =~ /[[:blank:]]+[0-9]{1,3}+[[:space:]]/
	     br = line.match(/[[:blank:]]+[0-9]{1,3}+[[:space:]]/).to_s.gsub(" ",'')
	  end
	  if line =~ /[[:blank:]]+[0-9]{1,3}\'/
	     br = line.match(/[[:blank:]]+[0-9]{1,3}\'/).to_s.gsub(" ",'')
	  end
	  if line =~ /\@/
         dest = line.scan(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/).to_s.gsub("[",'').gsub("]",'')
	  end
  elsif line =~ /minute/
      min = line.gsub("minute",'')
  elsif line =~ /hour/
      hour = line.gsub("hour",'')
  elsif line =~ /weekday/
      wday = line.gsub("weekday",'')
  elsif line =~ /day/
      day = line.sub("day",'').gsub("day",'')
  elsif line =~ /  directory '/
      repdir = line.sub(/  directory '/, '').sub(/'/,'').sub("\n",'')
  elsif line =~ /script_files/
     line.scan(/\d+.sh/).each do |b| 
	  begin
	   brand = File.open("C:/Users/poar/Documents/GitHub/System/chef/cookbooks/reports/files/default/" << repdir << "/" << "brands/" << b, "r")
	   brand.each_line { |to|
	                       if to =~ /TO=|FTP_URL=|FTP_ADDRESS=/ && to !~ /#+/
						      if dest.to_s.empty?
						         dest = to.gsub('export ','').gsub('TO=','').gsub('FTP_URL=','').gsub('FTP_ADDRESS=','').gsub('"','') 
						      elsif
		                         dest << "; " << to.gsub('export ','').gsub('TO=','').gsub('FTP_URL=','').gsub('FTP_ADDRESS=','').gsub('"','') 
						      end
						   elsif  to =~ /BRAND_NAME=/
						          if br.to_s.empty?
							         br = to.sub('export ','').sub('BRAND_NAME=','').sub('"','')
							      elsif
						             br << "; "<< to.sub('export ','').sub('BRAND_NAME=','').sub('"','')
		                          end
						   end
                       }
	  rescue
        dest << repdir.gsub("\n",'') << "/" << "brands/" << b << "- CHECK MANUAL" <<"; "
      end
  end
 end
}
f.close
end
end