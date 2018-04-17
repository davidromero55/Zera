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
            plugins : 'advlist link image lists charmap code table codesample',
            codesample_languages: [
              {text: 'HTML/XML', value: 'markup'},
              {text: 'JavaScript', value: 'javascript'},
              {text: 'CSS', value: 'css'},
              {text: 'PHP', value: 'php'},
              {text: 'Ruby', value: 'ruby'},
              {text: 'Python', value: 'python'},
              {text: 'Java', value: 'java'},
              {text: 'C', value: 'c'},
              {text: 'C#', value: 'csharp'},
              {text: 'C++', value: 'cpp'},
              {text: 'Perl', value: 'perl'}
            ],
            images_upload_url: '/Admin/API/ImageUpload',
            images_upload_base_path: '/data/img',
            relative_urls : false,
            image_dimensions: false,
            image_class_list: [
                               {title: 'Responsive', value: 'img-fluid'},
                               {title: 'None', value: ''}
                               ],
            image_prepend_url: "/",
            valid_elements: '+*[*]',
            link_class_list: [
              {title: 'Highlight', value: 'c-link'}
            ],
            style_formats : [
              {title : 'Bold', styles : {'font-weight': '700'}},
              {title : 'Secondary Text', styles : {color: '#6c757d'}},
            ]
        });
    }
    if ( $( ".datepicker" ).length ) {
        $('.datepicker').datepicker({
            format: 'yyyy-mm-dd'
        });
    }

});
