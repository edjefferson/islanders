class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :decades

  def decades
    (194..201).to_a.map { |x|  [x * 10, "#{x * 10}s"] }.to_h
  end

  helper_method :default_chart_options

  def default_chart_options
    return {tooltips: {
              enabled:true,
              callbacks: {
                        label: "function(tooltipItems, data) {
                            return 'Chosen once every ' + +(parseFloat(1/tooltipItems.yLabel)).toFixed(2) + ' shows';
                        }"
                    }
                  },
            height: 100, scales: {
                            xAxes: [{
                              gridLines: {
                                display:false
                              }
                            }],
                            yAxes: [{
                              gridLines: {
                                display:false
                              }
                            }]
            }
          }
  end
  helper_method :get_decade_data
  def get_decade_data(relation)
    data = relation.select('(EXTRACT(DECADE FROM episodes.broadcast_date) * 10) as year, count(episodes.id) as count').order('year asc').group('year')
    data.map{ |x| [x.year.to_i, x.count]}.to_h
  end
  helper_method :compute_chart_data

  def choices_decade_chart(choices)
    choices_hash = get_decade_data(choices)
    episodes_hash = get_decade_data(Episode.all)
    puts episodes_hash

    chart_data = decades.keys.map do |decade|
      if episodes_hash[decade].to_i != 0
        data = choices_hash[decade].to_f/episodes_hash[decade].to_f
      else
        data = 0
      end
      [decade, data]
    end
    chart_hash = chart_data.to_h

    return {
      labels: chart_hash.keys,
      datasets: [
        {
          label: "Choices per decade",
          border_color: "black",
          showLine: true,
          pointColor: "black",
          background_color: "transparent",
          data: chart_hash.values
        }

      ]
    }


  end
end
