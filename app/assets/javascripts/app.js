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
        $('.results ol').append('<li><a class="clarified_restaurant" data-id="'+key+'" href="/welcome/'+key+'">'+data.x[key]+'</a></li>')
      }
    })
  });

  $('body').on('click', '.clarified_restaurant', function(event){
    event.preventDefault();
    // debugger
    var request = $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'JSON',
      // data: {id: $(this).data("id")}
    })

    request.done(function(data) {
      array = []
      for (var key in data.finalz) {
        array.push(key)
      }

      // console.log(data.tips)
      console.log(data.reviews)
      for (var i=0; i < 5; i++) {
        $('.mid-section').append('<li><a href="">'+array[i]+'</a></li>')
      }
      // // debugger
      // // console.log(data.matches)
      // console.log(data.allreviews)
      // console.log(data.menu)
      // console.log(data.finalz)
      console.log(data.venue_url)
      console.log(data.tagz)
    })

    request.fail(function(data) {
      alert("Sorry, This Restaurant Does Not Have A Menu Online")
    })
  })
});