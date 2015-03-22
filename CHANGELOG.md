## 0.7.0 - Dynamic Blueprint List
* Dynamically generate the list of Blueprints

## 0.6.0 - Get APIs up to speed
* Include the View packages from the correct repository
* Upgrade depreciated keymap selectors
* Move stylesheets to the correct location

**Important Note:** The update removes the ability to generate ArrayControllers and ObjectControllers, since this feature is also being removed from Ember itself

## 0.5.0 - Updated Package APIs
* Update package to use the "new" package APIs
* Fix commands that were broken (which were all of them?)
* Add setting to specify path to the Ember and NPM executables, since Atom no longer automatically sources the path correctly every time
    * If you're having trouble getting the plugin to work correctly, try specifying the path to these executables
    * They default to the location on the Mac
* Update the UI to look... less bad

## 0.4.0 - Active Labels
* Added an 'active' class to the button for the currently running task
* Re-open the active panel if that command is run again while it's already
  running

## 0.3.0 - Coffeescript Generators
* Added setting to generate Coffeescript files instead of Javascript

## 0.2.0 - Added generators
* Ensure that one process is stopped before starting another
* Added a way to run the Ember generators through Atom

## 0.1.0 - First Release
* Basic support for `ember server` and `ember test`
* Check whether the current package is an ember-cli project and show the panel
  if it is
