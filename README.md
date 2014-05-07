# Ember CLI Helper

[ember-cli]() integration in Atom.

![ember cli helper](http://cl.ly/VPPy/Screen%20Shot%202014-05-07%20at%206.10.43%20PM.png)

The Ember CLI Helper is super easy to use.  Just press `clt-alt-o` or search
for `ember cli helper` in the command palette.

## Commands

### Server

Runs `ember server` in the root folder of the project.

### Test

Runs `ember test` in the root folder of the project

### Exit

Stops a currently running process

### Minimize

Show and hide the output panel, without hiding everything

### Close

Hide the entire panel

## Todo List

- [x] Open `ember-cli-helper` automatically if the package uses the Ember CLI
- [ ] Differentiate a task's button from the others when it is active
- [ ] Use the editor's theme to get colors for success and error in the command output
- [ ] Give some sort of visual feedback about the running command when the panel is minimized


***

**Special thanks** to [@nickClaw](https://github.com/nickclaw/) and his
[atom-grunt-runner](https://github.com/nickclaw/atom-grunt-runner)
package, which was my inspiration for building this and a big help in putting it
together.
