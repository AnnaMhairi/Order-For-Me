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
    var request = $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'JSON',
    })

    request.done(function(data) {
      // console.log(data.most_reviewed_dishes)
      console.log(data.tagz)
      console.log(data.most_reviewed_dishes)
      console.log(data.tag_with_reviews)
      console.log(data.review_list_per_item)
      array = []
      for (var key in data.most_reviewed_dishes) {
        array.push(key)
      }
      for (var i=0; i < 5; i++) {
        $('.mid-section').append('<li><a href="">'+array[i]+'</a></li>')
      }
    })

    request.fail(function(data) {
      alert("Sorry, This Restaurant Does Not Have A Menu Online")
    })
  })
});