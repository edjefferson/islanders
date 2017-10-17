

$(document).ready(function(){

  var data = $.getJSON( "index.json", function( json ) {
      data = json.openstruct.data;
      return data;
    });


  var cur_page = 1;

  var getTableData = function getTableData(array) {
    var content = '';
    $.each(array, function( index, value ) {
      if (index < 8) {
        content += '<tr><td>' + (index + 1) + '</td><td>' + value.name + '</td><td>' + value.appearances + '</td></tr>';
      }
    })
    return content;
  };

  var getDecadeTables = function getDecadeTables(sParam) {

    decade_data = (data[sParam]);

    $("table.data").each( function() {

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



  });




  $(".next-button").click(function(){
      $('html,body').animate({scrollTop: 0}, 500);
      $("#page" + cur_page).fadeOut(1000);

      $("#page" + ( cur_page + 1 )).fadeIn(1000);
      cur_page += 1
      console.log(cur_page);
  });

  $('.all-select').click(function() {
    getDecadeTables("");
    return false;
  });

  $('.decade-select').click(function() {
    var decade = $(this).text();
    getDecadeTables(decade);
    return false;
  });





});
