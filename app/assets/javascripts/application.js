// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .


// function check_box_update(data){
//     var ajax_checked_tags=[];
//         $('input[name="tag_check_box_list[]"]:checked').each(function(){
//             ajax_checked_tags.push($(this).val());
//         });

//     jQuery.ajax({
//             type : 'GET',
//             url : $(this).attr('ajax_path'),
//             data : {
//                 q : $('#search_tag_word').val(),
//                 checked_tags : ajax_checked_tags,
//             },
//             timeout : 5000,
//             dataType: "script",
//         });
// }



$(document).ready(function() {

    beforeInput = "";
    $("form#tag_edit_form").on("keypress keyup keydown paste change blur", function(e) {
        afterInput = $("input#search_tag_word").val();

        if (beforeInput!==afterInput){
                var ajax_checked_tags=[];
                    $('input[name="tag_check_box_list[]"]:checked').each(function(){
                        ajax_checked_tags.push($(this).val());
                    });

                jQuery.ajax({
                        type : 'GET',
                        url : $(this).attr('ajax_path'),
                        data : {
                            q : $("input#search_tag_word").val(),
                            checked_tags : ajax_checked_tags,
                        },
                        timeout : 5000,
                        dataType: "script",
                    });
                    beforeInput = afterInput;
        }
    });


    $("select#search_keyword_tag, select#search_sort").change(function() {
        if ($('#search_word').val()) {
                $('#search_start').trigger('click');
        }
    });


});







