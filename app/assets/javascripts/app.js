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
      // console.log(data.venue_objects)
      for(var key in data.restaurant_search_results) {
        $('.results ol').append('<li><a class="clarified_restaurant" data-id="'+key+'" href="/welcome/'+key+'">'+data.restaurant_search_results[key]+'</a></li>')
      }
    })
  });

  $('body').on('click', '.clarified_restaurant', function(event){
    event.preventDefault();
    var request = $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'JSON',
    })

    request.done(function(data) {
      // console.log(data.menu)
      var array = []
      var vals = []
      for (var key in data.review_list_per_item) {
        array.push(key)
        vals.push(data.review_list_per_item[key])
      }

      for (var i=0; i < 5; i++) {
        $('.mid-section').append('<li><a href="">'+array[i]+'</a></li>')
        $('.container').append('<p>'+array[i]+'</p><ul class="list comment_'+i+'"></ul>')
        for(var idx=0; idx<vals[i].length; idx++){
          $('.comment_'+i).append('<li>'+vals[i][idx]+'</li>')

        }
      }
      //append reviews to div and set default as hidden
    })

    request.fail(function(data) {
      alert("Sorry, This Restaurant Does Not Have A Menu Online")
    })
  })
});