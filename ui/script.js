
$(document).ready(function () {

  var cleanliness = 0;

  window.addEventListener("message", function (event) {
    if (event.data.type == "update") {
      cleanliness = event.data.cleanliness;

      // console.log('cleanliness', cleanliness);

      setProgressCleanliness(cleanliness, '.progress-cleanliness');

      if (cleanliness < 100) {
        $('#cleanliness-hud-container').show();
      }else{
        $('#cleanliness-hud-container').hide();
      }
    }else if (event.data.type == "hide") {
      $('#cleanliness-hud-container').hide();
    }
  });


  // Functions

  function setProgressCleanliness(amount, element) {
	  if(amount == undefined || amount <= 0){
		  amount = 0;
	  }
    var circle = document.querySelector(element);
    var radius = circle.r.baseVal.value;
    var circumference = radius * 2 * Math.PI;
    var html = $(element).parent().parent().find('span');
    var x4 = document.getElementById("test4");

    if (amount > 40) {
      x4.style.stroke = "#fff";
    }
    if (amount <= 40) {
      x4.style.stroke = "#ffaf02";
    }
    if (amount <= 25) {
      x4.style.stroke = " #FF0245";
    }

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = `${circumference}`;

    const offset = circumference - ((-amount * 100) / 100) / 100 * circumference;
    circle.style.strokeDashoffset = -offset;

    html.text(Math.round(amount));
  }

});
