# Ember CLI Helper

[![Gitter chat](https://badges.gitter.im/apprentus/atom-ember-cli-helper.png)](https://gitter.im/apprentus/atom-ember-cli-helper)

[ember-cli](https://github.com/stefanpenner/ember-cli) integration in Atom. Currently maintained by [@marius0](https://github.com/marius0), originally created by [@alexlafroscia](https://github.com/alexlafroscia/). Development sponsored by [Apprentus](https://www.apprentus.com).

Feel free to open issues if you find something. Pull requests are more than welcome!

![ember cli helper](http://f.cl.ly/items/0C1A110I3w2G2P0k0Z1T/Screen%20Shot%202015-03-22%20at%205.34.37%20PM.png)

## Keyboard shortcuts

| Keybinding     | Action                                                                 |
| :--            | :--                                                                    |
| ctrl+alt+e     | Toggle between the component/controller and the template               |
| ctrl+alt+r     | Toggle between the controller and the route                            |
| ctrl+alt+enter | Jump into templates. Press when cursor over {{forms/super-select ...}} to open templates/components/forms/super-select.hbs |

## Commands

| Command  | Description                                                    |
| :--      | :--                                                            |
| Server   | Runs `ember server` in the root folder of the project.         |
| Test     | Runs `ember test` in the root folder of the project            |
| Generate | Opens the panel to run a generator                             |
| Exit     | Stops a currently running process                              |
| Minimize | Show and hide the output panel, without hiding everything else |
| Close    | Hide the entire panel                                          |

## Generators

Running the generators through Atom is really easy.  When you first open the panel, it will bring up a list of file types to generate.  This list is based on the output of `ember g --help`, and therefore should include all future blueprints as well as those added by addons automatically. Once you select a type, you'll be prompted to enter a name, and the output will appear in orange in the bottom panel.

## Help! It's broken!

That might be the case! But first, check if specifying the path to the Ember and NPM packages fixes your problems.  It probably, hopefully will.  If it doesn't, please file an issue so I can try fixing it!

## Settings

| Setting | Purpose | Default Value |
| :---    | :---    | :---          |
| Generate Coffeescript     | Have all of the generators make CoffeeScript files instead of Javascript | `false` |
| Path To Ember Executable  | Point the CLI helper to the Ember executable on your computer | `/usr/local/bin/ember` |
| Path To `node` Executable | Point the CLI helper to the `node` executable on your computer | `/usr/local/bin/node` |

## Todo List

- [x] Open `ember-cli-helper` automatically if the package uses the Ember CLI
- [ ] Differentiate a task's button from the others when it is active
- [ ] Use the editor's theme to get colors for success and error in the command output
- [ ] Give some sort of visual feedback about the running command when the panel is minimized
- [x] Include a panel for running the file generators
- [x] Add convenience shortcuts to switch between component and template (and route and ...)
- [x] Add option to enter components when clicking something over {{forms/super-select ... }} --> opens components/forms/super-select.js

## Troubleshooting

Some users have experienced problems running the commands when they openning their project through the `File > Open` menu.  If this happens to you, try opening the project from the command line with the `atom` command see if that fixes the issue.


***

**Very special thanks** to [@alexlafroscia](https://github.com/alexlafroscia/) for creating the original atom plugin!

**Special thanks** to [@nickclaw](https://github.com/nickclaw/) and his
[atom-grunt-runner](https://github.com/nickclaw/atom-grunt-runner)
package, which was [@alexlafroscia](https://github.com/alexlafroscia/)'s inspiration for building this and a big help in putting it together.

**Finally a big thank you** to [Apprentus](https://www.apprentus.com) for paying me to work on this! :)
