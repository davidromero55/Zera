package Zera::Banners::Components;

use base 'Zera::Base::Components';

sub component_banner {
    my $self = shift;
    my $group_id = shift;
    my $template = shift || '';
    my $banners = $self->selectall_arrayref(
      "SELECT SQL_CACHE banner_id, name, media, code, url ".
      "FROM banners " .
      "WHERE group_id=? AND active=1 AND (DATE(NOW()) BETWEEN publish_from AND publish_to) ".
      "ORDER BY RAND() LIMIT 1",
      {Slice=>{}}, $group_id);
    my $vars = {
        banners  => $banners,
        group_id => $group_id,
    };

    return $self->render_template($vars, $template);
}

sub component_banners {
    my $self = shift;
    my $group_id = shift;
    my $template = shift || '';
    my $limit = shift || 10;
    my $banners = $self->selectall_arrayref(
      "SELECT SQL_CACHE banner_id, name, media, code, url ".
      "FROM banners " .
      "WHERE group_id=? AND active=1 AND (DATE(NOW()) BETWEEN publish_from AND publish_to) ".
      "ORDER BY sort_order, RAND() LIMIT ?",
      {Slice=>{}}, $group_id,$limit);
    my $vars = {
        banners  => $banners,
        group_id => $group_id,
    };

    return $self->render_template($vars, $template);
}

1;
