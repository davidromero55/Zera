$(document).ready(function(){
    // Bootstrap form validation
    var forms = document.getElementsByClassName('needs-validation');
    var validation = Array.prototype.filter.call(forms, function(form) {
      form.addEventListener('submit', function(event) {
        if (form.checkValidity() === false) {
          event.preventDefault();
          event.stopPropagation();
        }
        form.classList.add('was-validated');
      }, false);
    });

    if ( $( ".wysiwyg" ).length ) {
        tinymce.init({
            selector:'.wysiwyg',
            plugins : 'advlist link image lists charmap',
            images_upload_url: '/Admin/API/ImageUpload',
            images_upload_base_path: '/data/img',
            relative_urls : false,
            image_dimensions: false,
            image_class_list: [
                               {title: 'Responsive', value: 'img-fluid'},
                               {title: 'None', value: ''}
                               ],
            image_prepend_url: "/"
            });
    }
    if ( $( ".datepicker" ).length ) {
        $('.datepicker').datepicker({
            format: 'yyyy-mm-dd'
        });
    }

});
