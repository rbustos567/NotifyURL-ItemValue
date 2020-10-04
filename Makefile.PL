# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'NotifyURL-ItemValue';
all_from       'lib/NotifyURL/ItemsValue.pm';

requires       'Config::Tiny';

build_requires 'Config::Tiny';

install_script 'bin/notify_url_items_change';

auto_install;
WriteAll;

