require 'json'

file = 'myo_data.json'
temp = 'myo_data_template.html'
html = 'myo_data.html'

values = {}
if File.exist?(file)
  File.open(file, 'r') do |f|
    f.each_line do |line|
      json = JSON.parse(line)
      type = json.keys.first
      data = json[type]
      labels = []
      series = {}
      data.each do |datum|
        info = JSON.parse(datum)
        key_label = 'timestamp'
        labels.push(info[key_label])
        (info.keys - [key_label]).each do |property|
          if series.has_key?(property)
            series[property].push(info[property])
          else
            series[property] = []
          end
        end
      end
      series.each { |k, v| series[k] = v.to_s }
      values[type.downcase] = {'labels' => labels.to_s, 'series' => series}
    end
  end
end

unless values.empty?
  File.open(temp, 'r') do |t|
    File.open(html, 'w') do |h|
      t.each_line do |line|
        regex = /_@_.*_@_/
        if regex.match(line)
          if /plotChart/.match(line)
            values.keys.each do |type|
              categories_data = values[type]['labels']
              series_data = '['
              values[type]['series'].sort.each do |k, v|
                series_data += "{name: '#{k}', data: #{v}},"
              end
              series_data.chop!.concat(']')
              chart_id = "chart_#{type}"
              h.puts line.gsub(regex, "plotChart(#{categories_data}, #{series_data}, '#{type}', '#{chart_id}');")
            end
          elsif /id='chart_id'/.match(line)
            values.keys.each do |type|
              h.puts line.gsub(/chart_id/, "chart_#{type}").gsub('_@_', '')
            end
          end
        else
          h.puts line
        end
      end
    end
  end
end