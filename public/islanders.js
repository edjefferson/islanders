

$(document).ready(function(){

  $("table#artists").on('click', '.artist-link', function() {
    var artist = $(this).text()
    console.log(artist);
    popUpArtist(artist);
  });

  var data = $.getJSON( "index2.json", function( json ) {
      data = json.openstruct.data;
      return data;
    });

  var artist_data = $.getJSON( "artistfeed2.json", function( json ) {
      artist_data = json.openstruct.data;
      return artist_data;
    });

  var type = "all"
  var cur_page = 1;
  var decade = "All"

  var getTableData = function getTableData(array) {
    var content = '';
    $.each(array, function( index, value ) {
      if (index < 8) {
        content += '<tr><td>' + (index + 1) + '</td><td class="artist-link">' + value.name + '</td><td>' + value.appearances + '</td></tr>';
      }
    })
    return content;
  };

  var getDecadeTables = function getDecadeTables(decade, type, musiconly) {
    console.log(type+'_'+decade);
    decade_data = (data[type+'_'+decade]);
    console.log(decade_data);
    var x = 4
    if (musiconly){
      x = 2
    }
    $("table.data").slice(0,x).each( function() {

      table_type = $(this).attr('id');
      var content = getTableData(decade_data[table_type]);
      $("table#" + table_type).find('tbody').fadeOut(function( ) {
        $(this).empty().append(content).fadeIn()

      })

    })
  };




  $('.start').click(function() {

    var getStat = function getStat(param) {
      return data.stats[param]
    };

    $(".stat").each(function(){
        var stat = $(this).attr('id');
        $(this).text(getStat(stat));
    });
    getDecadeTables("", type, false);


  });

  var setDecadeName = function setDecadeName(decade) {
    $('#decade-name').fadeOut(function() {$(this).text(decade)} ).fadeIn();
  }
  var popUpArtist = function popUpArtist(artist) {
    $('#artist-info').text(artist);
    console.log(artist_data[artist]);
    var decade_counts = artist_data[artist];
    var decades = ["1940", "1950", "1960", "1970", "1980", "1990","2000","2010"];
    var chartdata = [];
    $.each( decades, function( index, decade ) {
      if (decade_counts[decade]) {

        chartdata.push(decade_counts[decade])
      }
      else {
        chartdata.push(0)
      }

    })

    var myChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ["1940s", "1950s", "1960s", "1970s", "1980s", "1990s","2000s","2010s"],
            datasets: [{
                label: '# of times chosen',
                data: chartdata
              }]
            }
          })
    $('#artist-popup').fadeIn();
  }

  $("#close").click(function(){
      $('#artist-popup').fadeOut();
  });

  $(".next-button").click(function(){
      $('html,body').animate({scrollTop: 0}, 500);
      $("#page" + cur_page).fadeOut(1000);

      $("#page" + ( cur_page + 1 )).fadeIn(1000);
      cur_page += 1
      console.log(cur_page);
  });



  $('.decade-select').click(function() {
    var current_decade = decade;
    decade = $(this).text();
    if (current_decade != decade) {
      setDecadeName(decade);
      getDecadeTables(decade, type, false);
    }
    return false;
  });

  $('.type-select').click(function() {
    var current_type = type;
    type = $(this).attr('id');
    if (current_type != type) {
      getDecadeTables(decade, type, true);
      $('.type-select').css('text-decoration', 'none');
      $(this).css('text-decoration', 'underline');
    }
    return false;
  });



var ctx = document.getElementById("myChart").getContext('2d');


});
