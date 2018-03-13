$(document).ready(function(){
    
    $('#title').keyup(function() {
        var title = $('#title').val();
        title = title.replace(/\W/gi, "-");
        title = title.replace(/\-\-+/gi, "-");
        title = title.toLowerCase();
        $('#url').val(title);
    });
    
});