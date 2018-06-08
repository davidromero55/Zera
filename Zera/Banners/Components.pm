package Zera::Banners::Components;

use base 'Zera::Base::Components';

sub component_banner {
    my $self = shift;
    my $group_id = shift;
    my $banners = $self->selectall_arrayref("SELECT SQL_CACHE banner_id, name, media, code, url FROM banners WHERE group_id=? AND active=1 AND (DATE(NOW()) BETWEEN publish_from AND publish_to) ",
        {Slice=>{}}, $group_id);
    my $vars = {
        banners  => $banners,
        group_id => $group_id,
    };

    return $self->render_template($vars);
    return '';
}
1;
