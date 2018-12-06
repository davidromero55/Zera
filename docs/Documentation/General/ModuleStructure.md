# Module structure

All the Zera implementations may contain this 5 files.
- Actions.pm
- API.pm
- Components.pm
- Controller.pm
- Cron.pm
- View.pm
- tmpl

###### /Zera/ModuleName/Actions.pm
This is the module to store the functions that do the work, update a database, exploit an API, work whit files, and other tasks.

###### /Zera/ModuleName/API.pm
This is the module to store the API rest functions.

###### /Zera/ModuleName/Components.pm
This is the module to store the functions to display small sections of a webpage.

###### /Zera/ModuleName/Controller.pm
This is the controller file where the special functions will be stored. This functions will be executed before the View and Actions modules.

###### /Zera/ModuleName/API.pm
This is the module to store any cronjob tasks.

###### /Zera/ModuleName/View.pm
This is the module to store the functions to display a webpage.

###### /Zera/ModuleName/tmpl/
On this directory you may store all the html templates and email templates of your modules. This templates may be overriden with a similar file on the /templates/TemplateName/ModuleName/ folders.
