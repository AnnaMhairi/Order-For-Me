$(document).on('page:change',function() {

  $('.restaurant_search').on('submit', function(event){
    event.preventDefault();
    var request = $.ajax({
      url: '/welcome',
      type: 'POST',
      dataType: 'JSON',
      data: {restaurant: $('input.restaurant').val(), citystate: $('input.location').val() }
    })
    request.done(function(data) {
      for(var key in data.x) {
        $('.results ol').append('<li><a data-id="'+key+'" href="/">'+data.x[key]+'</a></li>')
      }
    })
  });

});