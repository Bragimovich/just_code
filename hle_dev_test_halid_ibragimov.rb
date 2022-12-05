require 'mysql2'
require 'pry'

DB = Mysql2::Client.new(
   host: 'db09.blockshopper.com',
   username: 'loki',
   password: 'v4WmZip2K67J6Iq7NXC',
   database: 'applicant_tests'
)

result = DB.query('SELECT candidate_office_name, id FROM hle_dev_test_halid_ibragimov').to_a


result.each do |row|
   str_id = row['id'].to_i
   str = row['candidate_office_name'].to_s

   def handle_string(final_string)
          final_string.gsub!('twp', 'Twp')
          final_string.gsub!('hwy', 'Hwy')
          final_string.gsub!('Twp', 'Township')
          final_string.gsub!('Hwy', 'Highway')
          final_string.gsub!('highway', 'Highway')
          final_string.gsub!('township', 'Township')
          final_string.gsub!('Township Township', 'Township')
          final_string.gsub!('Highway Highway', 'Highway')
          final_string.gsub!('.', '')
          final_string
   end

   if str.count('/') > 1
     str.to_s.strip.gsub('//', '/')
     string_for_first_condition = str.split('/')
     string_for_first_condition.insert(0, string_for_first_condition[-1]).pop
     arr_for_string = []
        string_for_first_condition.each_with_index do |elem, idx|
           if idx > 0
             arr_for_string << elem.downcase
           else
             arr_for_string << elem
           end
        end
         first_condition = arr_for_string.insert(-2, 'and').join(' ').strip
         first_condition.gsub!('county ', '')
         first_condition = handle_string(first_condition)
             query = <<~SQL
                     UPDATE hle_dev_test_halid_ibragimov SET clean_name = "#{first_condition}", sentence = "The candidate is running for the #{first_condition} office." WHERE id = #{str_id.to_i}
                     SQL
                     DB.query(query)

   elsif
     str.include?('/') && str.include?(',')
        string = str.split('/')
        string.insert(0, string[-1]).pop  #перенос строки
        string = string.join(' ')
        string.gsub!(', ', ', **')
        string = string + ')'

        string_arr = []
        string = string.split('**')
        string.each_with_index do |elem, index|
          if index > 0
            string_arr << elem.split(' ').map do |elm|
              elm.capitalize.to_s
            end
           else
             string_arr << elem
          end
        end

        string_new = string_arr.flatten(1).join(' ').gsub(',  ',', (').strip
        string_new = handle_string(string_new)
          query_two = <<~SQL
                      UPDATE hle_dev_test_halid_ibragimov SET clean_name = "#{string_new}", sentence = "The candidate is running for the #{string_new} office." WHERE id = #{str_id.to_i}
                      SQL
                      DB.query(query_two)

   elsif
      str.include?(',') && str.include?('/') == false
      string_two = str
        string_two.gsub!(',', '(')
          string_two.gsub!('( ', ' (')
            string_two = string_two + ')'
              string_two.gsub!('(', '*(')
      string_two_arr = []
      string_two = string_two.split('(')
      string_two.each_with_index do |elem, index|
        if index < 1
          string_two_arr << elem.downcase
        else
          string_two_arr << elem.split(' ').map do |words|
            words.capitalize
          end
        end
      end
      string_two_arr.flatten!
      string_two = string_two_arr.join(' ').gsub('* ', '(').strip
      string_two = handle_string(string_two)
          query_three = <<~SQL
                        UPDATE hle_dev_test_halid_ibragimov SET clean_name = "#{string_two}", sentence = "The candidate is running for the #{string_two} office." WHERE id = #{str_id.to_i}
                        SQL
                        DB.query(query_three)

   elsif str.include?('/') && str.include?(',') == false
       string_three = str.split('/').reverse
       string_arr_three = []
      string_three.each_with_index do |elem, index|
       if index > 0
         string_arr_three << elem.downcase
       else
         string_arr_three << elem
       end
      end
        string_three_total = string_arr_three.join(' ').strip
        string_three_total = handle_string(string_three_total)
           query_four = <<~SQL
                        UPDATE hle_dev_test_halid_ibragimov SET clean_name = "#{string_three_total}", sentence = "The candidate is running for the #{string_three_total} office." WHERE id = #{str_id.to_i}
                        SQL
                        DB.query(query_four)
   else
        string_five = str
        string_five_total = string_five.downcase.strip
        string_five_total = handle_string(string_five_total)
           query_five = <<~SQL
                        UPDATE hle_dev_test_halid_ibragimov SET clean_name = "#{string_five_total}", sentence = "The candidate is running for the #{string_five_total} office." WHERE id = #{str_id.to_i}
                        SQL
                        DB.query(query_five)
   end
end
DB.close
















