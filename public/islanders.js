$(document).ready(function(){

  var data = $.getJSON( "index.json", function( json ) {
      data = json.openstruct.data;
      return data;
    });
  param = "stats"

  var cur_page = 1;

  var getDecadeTables = function getDecadeTables(sParam) {
    decade_data = (data[sParam]);
    console.log(data.stats);
    $.each(['artists','discs','books','luxuries'], function( index, value ) {
      content = '';

      $.each(decade_data[value], function( index, value ) {
        if (index < 8) {
          content += '<tr><td>' + (index + 1) + '</td><td>' + value.name + '</td><td>' + value.appearances + '</td></tr>';
        }
      });
      $("#"+value).find('tbody').empty().append(content);
    })
  };


  var getStat = function getStat(param) {
    return data['stats'][param];
  };




  $(".next-button").click(function(){
      $("#page" + cur_page).fadeOut(1000);
      $("#page" + ( cur_page + 1 )).fadeIn(1000);
      cur_page += 1
      console.log(cur_page);
  });

  $('.decade-select').click(function() {
    var decade = $(this).text();
    getDecadeTables(decade);
    return false;
  });

  console.log(data['stats']);

});
