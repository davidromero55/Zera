package Zera::Blog::View;

use JSON;
use Zera::Conf;
use base 'Zera::Base::View';

# Module Functions
sub display_home {
  my $self = shift;
  my $limit = $self->conf('Blog', 'ItemsPerPage');
  $self->set_title($conf->{App}->{Name});

  # Entries
  my $entries = $self->selectall_arrayref(
  "SELECT entry_id, url, title, description, display_options, DATE(e.date) AS date, DATE_FORMAT(e.date, '%m-%e-%Y') AS f_date " .
  "FROM entries e WHERE module='blog' AND active=1 ORDER BY e.date DESC LIMIT ?, ?",{Slice=>{}}, $self->param('offset') || 0, $limit);
  foreach my $entry (@$entries){
    $entry->{display_options} = decode_json($entry->{display_options});
  }

  #Pagination Start
  my $HTML = "";
  #Get total rows
  my $sSQL = "SELECT COUNT(*) AS total FROM entries NATURAL JOIN entries_categories WHERE category_id=1";
  my $total = $self->selectrow_array($sSQL,{})  || 0;

  my $pages = ($total / $limit);
  my $pages_int = int($pages);
  $pages = $pages_int + 1 if($pages > $pages_int);

  my $page = $self->param("zl_page") || 1;
  my $pagination = "";
  if($page > 1){
    foreach(my $ii = -1;$ii > -5;$ii--){
      last if(($page + $ii) < 1 );
      $pagination = $self->_tag('a',{class=>'',href =>"/Blog?zl_page=" . ($page + $ii) . "&offset=" . (($page + $ii -1) * $limit)},
      ($page + $ii)) . $pagination;
    }
    $pagination = $self->_tag('a',{class=>'', href =>"/Blog?zl_page=1&offset=0"},
    'Primera') . $pagination;
  }
  $pagination .= '<a class="no-page">'.$page.'</a>';
  if($page < $pages){
    foreach(my $ii = 1;$ii < 5;$ii++){

      last if(($ii + $page) > $pages);
      $pagination .= $self->_tag('a',{class=>'',href =>"/Blog?zl_page=" . ($page + $ii) . "&offset=" . (($page + $ii - 1) * $limit)},
      ($page + $ii));
    }
    $pagination .= $self->_tag('a',{class=>'', href =>"/Blog?zl_page=" . ($pages) . "&offset=" . (($pages - 1) * $limit)}, 'Última');
  }

  $HTML .= $pagination;
  #Pagination End

  my $vars = {
    entries => $entries,
    pag => $HTML
  };

    return $self->render_template($vars);
}

sub display_item {
    my $self = shift;

    # Entry
    my $entry = $self->selectrow_hashref(
        "SELECT entry_id, url, title, description, keywords, display_options, DATE(e.date) AS date, content " .
        "FROM entries e WHERE url=? AND module='Blog' AND active=1 ORDER BY e.date DESC",{Slice=>{}}, $self->param('SubView'));
    $entry->{display_options} = decode_json($entry->{display_options});

    $self->set_title($entry->{title});
    $self->set_keywords($entry->{keywords});
    $self->set_description($entry->{description});
    $self->set_page_attr('type','article');
    $self->set_page_attr('url','http://'.$conf->{App}->{URL} . '/' . $self->param('SubView'));
    if($entry->{display_options}->{image}){
        $self->set_page_attr('image','http://'.$conf->{App}->{URL} . $entry->{display_options}->{image});
    }

    my $vars = {
        entry => $entry,
    };

    return $self->render_template($vars);
}

1;
