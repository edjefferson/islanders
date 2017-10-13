$(document).ready(function(){
    var cur_page = 1
    $(".next-button").click(function(){
        $("#page" + cur_page).hide();
        $("#page" + ( cur_page + 1 )).show();
        cur_page += 1
        console.log(cur_page);
    });
});


var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};
var decade = getUrlParameter('decade');
$.getJSON( "index.json?decade="+decade, function( json ) {
  for (var key in json.openstruct) {
    console.log(key);
    data = json.openstruct[key];


    for(var i = 0, l = data.length; i < l; ++i) {

      console.log(data[i].name);
      $('#'+key).append('<tr><td>'+data[i].name+'</td><td>'+data[i].appearances+'</td></tr>');
    }
  }
}
);
