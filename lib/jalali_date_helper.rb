# encoding: utf-8

# This is Jalali Date tag creator by extending rails FormBuilder.
#
# If you need this helper for your rails application just copy this file + 'jalali_date.rb' to your /lib/ directory and add below line to end of your environment.rb.
#  require 'jalali_date_helper'
#
# Version::   1.0.1
# Author::    Arash Karimzadeh  (mailto:me@arashkarimzadeh.com)
# License::   Licensed under the MIT (MIT-LICENSE.txt) http://www.opensource.org/licenses/mit-license.php

# You can use it as below
#  <%= jalali_date :start_date, Time.mktime(1983,3,26) %>
# Or
#  <% form_for(@post) do |f| %>
#   <%= f.jalali_date :created_at, :prefix=>'start_date'  %>
#  <% end %>

require 'jalali_date'

module ActionView
  module Helpers
    module FormHelper

			# Create a select tag for jalali date (needs utf-8 support)
			#
			# ====Options
			# * <tt>:start_year</tt>      - Set the start year for the year select. Default is <tt>passed_date.year - 5</tt>.
      # * <tt>:end_year</tt>        - Set the end year for the year select. Default is <tt>passed_date.year + 5</tt>.
			# * <tt>:include_blank</tt>   - Include a blank option in every select field so it‘s possible to set empty dates.
			# ====Html Options
			# Same as rails select tag html_options.
			#
			# ====Examples
  		#  <%= jalali_date :post, :submit_date, Time.mktime(1983,3,26) %>
			#  <%= jalali_date :post, :submit_date, Time.now, {:start_year=>1360, :end_year=>1400}, :class=>'date' %>
			def jalali_date(object, method, date, options={}, html_options={})
				jdate = JalaliDate.to_jalali(date)
				options[:prefix] = method if options[:prefix].nil?
				id_prefix = "#{object}_#{options[:prefix]}"
				name_prefix = "#{object}[#{options[:prefix]}]"
				start_year = options[:start_year].nil? ? jdate.year-5 : options[:start_year]
				end_year = options[:end_year].nil? ? jdate.year+5 : options[:end_year]
				years = []
				start_year.upto(end_year){ |y| years<<[y.to_farsi, y] }

				months = [['فروردین',1],['اردیبهشت',2],['خرداد',3],['تیر',4],['مرداد',5],['شهریور',6],['مهر',7],['آبان',8],['آذر',9],['دی',10],['بهمن',11],['اسفند',12]]
				month_days=[nil,31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30]
				days = []
				1.upto(month_days[jdate.month]) { |d| days<<[d.to_farsi, d] }

				year = select_tag "#{name_prefix}[year]", options_for_select( years, jdate.year ), html_options.merge!({:id => "#{id_prefix}_year"})
				month = select_tag "#{name_prefix}[month]", options_for_select( months, jdate.month ), html_options.merge!({:id => "#{id_prefix}_month"})
				day = select_tag "#{name_prefix}[day]", options_for_select( days, jdate.day ), html_options.merge!({:id => "#{id_prefix}_day"})
				year+"\n"+month+"\n"+day
			end
		end

		class FormBuilder
			# Create a select tag for jalali date (needs utf-8 support).
			#
			# method: object atribute name which must be in Gregorian Format
			# ====Options
			# Same as FormHelper::jalali_date
			#
			# ====Html Options
			# Same as rails select tag html_options
			#
			# ====Examples
			#  <% form_for(@post) do |f| %>
  		#   <%= f.jalali_date :created_at, :prefix=>'start_date'  %>
			#  <% end %>
			#
			#  <% form_for(@user) do |f| %>
			#   <%= f.jalali_date :birth, {:start_year=>1385, :end_year=>1390}, :class=>'date' %>
			#  <% end %>
			def jalali_date(method, options={}, html_options={})
				@template.jalali_date(@object_name, method, @object[method]||Time.now, options, html_options)
			end
		end
	end
end
