

$(document).ready(function(){

  var data = $.getJSON( "index.json", function( json ) {
      data = json.openstruct.data;
      return data;
    });

  var type = "all"
  var cur_page = 1;
  var decade = "all"
  var getTableData = function getTableData(array) {
    var content = '';
    $.each(array, function( index, value ) {
      if (index < 8) {
        content += '<tr><td>' + (index + 1) + '</td><td>' + value.name + '</td><td>' + value.appearances + '</td></tr>';
      }
    })
    return content;
  };

  var getDecadeTables = function getDecadeTables(decade, type, musiconly) {
    decade_data = (data[type+'_'+decade]);
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



  });

  var setDecadeName = function setDecadeName(decade) {
    $('#decade-name').fadeOut(function() {$(this).text(decade)} ).fadeIn();
  }

  $(".next-button").click(function(){
      $('html,body').animate({scrollTop: 0}, 500);
      $("#page" + cur_page).fadeOut(1000);

      $("#page" + ( cur_page + 1 )).fadeIn(1000);
      cur_page += 1
      console.log(cur_page);
  });

  $('.all-select').click(function() {
    $('.decade-name').text("All")
    getDecadeTables("");

    return false;
  });

  $('.decade-select').click(function() {
    decade = $(this).text();
    setDecadeName(decade);
    getDecadeTables(decade, type, false);
    return false;
  });

  $('.type-select').click(function() {
    type = $(this).attr('id');
    getDecadeTables(decade, type, true);
    $('.type-select').css('text-decoration', 'none');
    $(this).css('text-decoration', 'underline');
    return false;
  });





});
