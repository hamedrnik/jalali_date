# encoding: utf-8

# This is Jalali-Gregorian date converter.
#
# If you need this converter for your rails application just copy this file to your /lib/ directory and add below line to end of your environment.rb.
#  require 'jalali_date'
#
# Version::   1.0.1
# Author::    Arash Karimzadeh  (mailto:me@arashkarimzadeh.com)
# License::   Licensed under the MIT (MIT-LICENSE.txt) http://www.opensource.org/licenses/mit-license.php

# This class act as ruby Time class.
#
# You can use it as below
#  Time.now  #=> Sat Nov 07 16:18:16 +0330 2009
#  jalali_date = JalaliDate.to_jalali(Time.now)
#  jalali_date.year  #=> 1388
#  gregorian_date = jalali_date.to_gregorian #=> Sat Nov 07 00:00:00 +0330 2009
class JalaliDate
	MONTHNAMES = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند']

	# Returns the day of the month (1..n) for time.
	attr_accessor :day
	# Returns the month of the year (1..12) for time.
	attr_accessor :month
	# Returns the year for time (including the century).
	attr_accessor :year
	# Returns an integer representing the day of the week, 0..6, with یکشنبه == 0.
	attr_accessor :wday

	# This method will convert Gregorian date to Jalali and return JalaliDate instance
	#
	# ====Examples
	#  JalaliDate.to_jalali(Time.now)
	def self.to_jalali(time)
		g_month_days=[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		j_month_days=[31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29]
		jalali_date = self.new
		gy=(time.year)-1600
		gm=(time.month)-1
		gd=(time.day)-1
		jm = jd = jy=0
		gDayNo=365*gy + (gy+3)/4 - (gy+99)/100 +(gy+399)/400
		i=0
		0.upto(gm-1) do |i|
			gDayNo += g_month_days[i]
		end
		if (gm>1 && (gy%4==0 && gy%100!=0) || (gy%400==0))
			gDayNo=gDayNo+1
		end
		gDayNo += gd
		jDayNo = gDayNo-79
		jNp = jDayNo/12053
		jDayNo=jDayNo % 12053
		jy=979 + 33*jNp + 4*(jDayNo/1461)
		jDayNo %=1461
		if(jDayNo >= 366)
			jy +=(jDayNo-1)/365
			jDayNo =(jDayNo-1)%365
		end
		i=0
		while (i<11 && jDayNo>=j_month_days[i])
			jDayNo -= j_month_days[i]
			i=i+1
		end
		jm=i+1
		jd=jDayNo+1
		jalali_date.year = jy
		jalali_date.month = jm
		jalali_date.day = jd
		jalali_date.wday = time.wday
		jalali_date
	end

	# Return current Jalali date
	def self.now
		JalaliDate.to_jalali(Time.now)
	end

	# Formats date according to the directives in the given format string. Any text not listed as a directive will be passed through to the output string.
	#
	# ====Formats
	# * %a - The abbreviated weekday name 'شن'
	# * %A - The full weekday name 'شنبه'
	# * %b - The abbreviated month name 'آب'
	# * %B - The full month name 'آبان'
	# * %d - Day of the month (01..31)
	# * %m - Month of the year (01..12)
	# * %y - Year without a century (00..99)
	# * %Y - Year with century
	#
	# ====Examples
	#  jalali_date.to_jalali Time.now
	#  jalali_date.strftime("Printed on %d/%m/%Y")  #=> "Printed on 16/8/1388"
	#
	def strftime(ptr)
		days = {0=>'یکشنبه',1=>'دوشنبه',2=>'سه شنبه',3=>'چهارشنبه',4=>'پنجشنبه',5=>'جمعه',6=>'شنبه'}
		months = {1=>'فروردین',2=>'اردیبهشت',3=>'خرداد',4=>'تیر',5=>'مرداد',6=>'شهریور',7=>'مهر',8=>'آبان',9=>'آذر',10=>'دی',11=>'بهمن',12=>'اسفند'}

		str = ptr.gsub /%[^%]/ do |s|
			case s
				when '%a' then days[self.wday][0,2]
				when '%A' then days[self.wday]
				when '%d' then self.day.to_s.rjust(2,'0')
				when '%m' then self.month.to_s.rjust(2,'0')
				when '%b' then months[self.month][0,4]
				when '%B' then months[self.month]
				when '%y' then self.year.to_s[2,2].to_s.rjust(2,'0')
				when '%Y' then self.year
				else s
			end
		end
		str
	end

	# Convert JalaliDate object to Gregorian Date
	#
	#====Examples
	#  jalali_date.to_gregorian #=> Sat Nov 07 00:00:00 +0330 2009
	def to_gregorian
		JalaliDate.to_gregorian(self.year,self.month,self.day)
	end

	# Convert JalaliDate to Gregorian Date
	#
	# ====Examples
	#  JalaliDate.to_gregorian(1388,8,16) #=> Sat Nov 07 00:00:00 +0330 2009
	#  JalaliDate.to_gregorian({:year=>1388,:month=>8,:day=>16}) #=> Sat Nov 07 00:00:00 +0330 2009
	def self.to_gregorian(year,month=nil,day=nil)
		if(!(year.class == String || year.class == Fixnum))
			month = year[:month]
			day = year[:day]
			year = year[:year]
		end
		gDaysInMonth=[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		jDaysInMonth=[31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29]
		jy=(year.to_i)-979
		jm=(month.to_i)-1
		jd=(day.to_i)-1
		gm=0
		gd=0
		gy=0
		jDayNo=365*jy + (jy/33)*8 + ((jy%33)+3)/4
		0.upto(jm-1)do |i|
			jDayNo +=jDaysInMonth[i]
		end
		jDayNo +=jd
		gDayNo=jDayNo + 79
		gy=1600+400*(gDayNo/146097)
		gDayNo = gDayNo%146097
		leap=true
		if(gDayNo >= 36525)
			gDayNo =gDayNo-1
			gy +=100* (gDayNo/36524)
			gDayNo=gDayNo % 36524
			if(gDayNo>=365)
				gDayNo =gDayNo+1
			else
				leap=false
			end
		end
		gy += 4*(gDayNo/1461)
		gDayNo %=1461
		if(gDayNo>=366)
			leap=false
			gDayNo=gDayNo-1
			gy +=gDayNo/365
			gDayNo=gDayNo %365
		end
		i=0
		tmp=0
		while (gDayNo>= (gDaysInMonth[i]+tmp))
			if(i==1 && leap==true)
				tmp=1
			else
				tmp=0
			end
			gDayNo -=gDaysInMonth[i]+tmp
			i=i+1
		end
		gm=i+1
		gd=gDayNo+1
		Time.mktime(gy,gm,gd)
	end
end
