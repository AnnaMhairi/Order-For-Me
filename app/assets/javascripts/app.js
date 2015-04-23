//make events so that the user is redirected to each appropriate div
//for example, when they click submit they will be automatically pushed down to the restaurant clarification section then an arrow will display that they can click on to redirect them to the next div of dishes then on click they'll be directed down to comments etc. etc. (make the user experience more dumb/coherent)


$(document).on('page:change',function() {

  $('.restaurant_search').on('submit', function(event){
    event.preventDefault();
    // var data = {restaurant: $('input.restaurant').val(), citystate: $('input.location').val() }
    // $('html, body').animate({
    // scrollTop: $("#portfolio").offset().top
    // }, 1000);
    // console.log(data)
    var request = $.ajax({
      url: '/welcome',
      type: 'POST',
      dataType: 'JSON',
      data: {restaurant: $('input.restaurant').val(), citystate: $('input.location').val() }
    })
    request.done(function(data) {
      for (var i = 0; i < data.trending_businesses.length; i++) {
        $('div .trending_restaurants ul').append('<li class="trend_restaurants" data-name="'+data.trending_businesses[i]+'"><a href="#services">'+data.trending_businesses[i]+'</a></li>')
      }
      for(var key in data.restaurant_search_results) {
        $('.row ol.result_restaurants').append('<p class ="click_restaurant">CLICK YOUR RESTAURANT BELOW.</p>')
        $('.row ol.result_restaurants').append('<li><a class="clarified_restaurant" data-id="'+key+'" href="/welcome/'+key+'">'+data.restaurant_search_results[key]+'</a></li>')

      // for(var key in data.x) {
        // $('.service-heading').append('<li><a class="clarified_restaurant" data-id="'+key+'" href="/welcome/'+key+'">'+data.x[key]+'</a></li>')

      // }
    }
  });

  });

  $('body').on('click', '.clarified_restaurant', function(event){
    event.preventDefault();

    var request = $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'JSON',
    })

    request.done(function(data) {
      if (data.isSuggestion === true) {
        // console.log(data.suggestions)
        $('.result_restaurants').hide()
        $('.service-heading').show()
        for(var key in data.suggestions) {
          $('.row ol.suggested_restaurants').append('<li><a class="clarified_restaurant" data-id"'+key+'" href="/welcome/'+key+'">'+data.suggestions[key]+'</a></li>')
        }
      }
      else if (data.isSuggestion === false) {
        $('html, body').animate({
        scrollTop: $("#portfolio").offset().top
        }, 1000);
        var array = []
        var vals = []
        for (var key in data.review_list_per_item) {
          array.push(key)
          vals.push(data.review_list_per_item[key])
        }


        for (var i=0; i < 5; i++) {
          $('div.portfolio-caption').append('<li><a data-id="'+i+'"class="restaurant_given" href="">'+array[i]+'</a></li>')
          $('.mid-section').append('<p class="list" style="display:none">'+array[i]+'</p><ul class="list comment_'+i+'" style="display:none"></ul>')
          for(var idx=0; idx<vals[i].length; idx++){
            $('.comment_'+i).append('<li>'+vals[i][idx]+'</li>')

      // for (var i=0; i < 5; i++) {
      //   $('.portfolio-caption').append('<li><a href="">'+array[i]+'</a></li>')
      //   $('.comments').append('<p>'+array[i]+'</p><ul class="list comment_'+i+'"></ul>')
      //   for(var idx=0; idx<vals[i].length; idx++){
      //     $('.comment_'+i).append('<li>'+vals[i][idx]+'</li>')


          }
        }
      }

        //append reviews to div and set default as hidden

      //append reviews to div and set default as hidden
      for (var i=0; i < 25; i++){
        $('.autoplay').append('<li><img src="'+data.photo_array[i]+'"></li>')
      }

      $('.autoplay').slick({
        slidesToShow: 3,
        slidesToScroll: 1,
        autoplay: true,
        autoplaySpeed: 2000,
      });


    })

    request.fail(function(data) {
      alert("Bad Connection")
    })
  })


  $('body').on('click', '.restaurant_given', function(event) {
    event.preventDefault();
    $('html, body').animate({
        scrollTop: $("#about").offset().top
      }, 1000);
    $('.list').hide()
    $.modal( $('.comment_'+$(this).data("id")),
              {
                onOpen: function(dialog){
                  dialog.overlay.fadeIn('slow', function(){
                    dialog.data.hide();

                    dialog.container.fadeIn('slow', function(){
                      dialog.data.slideDown('slow');
                    });
                  });
                }
              }
    );
  });

  $('body').on('click', '.trend_restaurants', function(event) {
    event.preventDefault();
    // debugger
    $('.clarified_restaurant').hide()
    var x = $(this).data("name")
    $('html, body').animate({
        scrollTop: $("#services").offset().top
      }, 1000);
    $('.restaurant_search input[name=restaurant]').val(x)

  });
});

