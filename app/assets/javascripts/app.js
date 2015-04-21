//make events so that the user is redirected to each appropriate div
//for example, when they click submit they will be automatically pushed down to the restaurant clarification section then an arrow will display that they can click on to redirect them to the next div of dishes then on click they'll be directed down to comments etc. etc. (make the user experience more dumb/coherent)


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
        $('.service-heading').append('<li><a class="clarified_restaurant" data-id="'+key+'" href="/welcome/'+key+'">'+data.x[key]+'</a></li>')
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
      var array = []
      var vals = []
      for (var key in data.review_list_per_item) {
        array.push(key)
        vals.push(data.review_list_per_item[key])
      }

      for (var i=0; i < 5; i++) {
        $('.portfolio-caption').append('<li><a href="">'+array[i]+'</a></li>')
        $('.comments').append('<p>'+array[i]+'</p><ul class="list comment_'+i+'"></ul>')
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