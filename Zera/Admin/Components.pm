package Zera::Admin::Components;

use base 'Zera::BaseAdmin::Components';

sub component_admin_menus {
    my $self = shift;
    my $user_id = $self->sess('user_id');
    my $menus;
    if($user_id){
        $menus = $self->selectall_arrayref(
            "SELECT SQL_CACHE ac.url, ac.name, ac.icon " .
            "FROM access_control ac " .
            "WHERE ac.workspace='Admin' AND ac.on_menu=1 AND (ac.is_restricted=0 OR " .
            "(SELECT COUNT(*) FROM users_access_control uac WHERE uac.user_id=? AND uac.access_control_id=ac.access_control_id))".
            "ORDER BY ac.sort_order, ac.name",{Slice=>{}}, $user_id);
    }

    my $vars = {
        menus => $menus,
    };

    return $self->render_template($vars);
}

1;
