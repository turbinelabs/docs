$(document).ready(function() {
  $(".tabbed-block").each(function() {
    var me = $(this);
    me.find(".tab-content").children("div").hide(); // Initially hide all content
    me.find(".tabs li:first").addClass("current"); // Activate second tab
    me.find(".tab-content div:nth-child(2)").fadeIn(); // Show second tab content, b/c jekyll hack
    me.find('.tabs li span').click(function(e) {
      e.preventDefault();
      if ($(this).hasClass("current")) { //detection for current tab
        return
      } else {
        me.find(".tab-content").children("div").hide(); //Hide all content
        me.find(".tabs li").removeClass("current"); //Reset classes's
        me.find(this).parent().addClass("current"); // Activate this
        me.find( $(this).attr('data-dest') ).fadeIn(); // Show content for current tab
      }
    });
  });
});
