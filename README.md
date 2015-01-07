# Bixsby
Bixsby is a terminal emulator that you can chat with. He's sort of like Siri but for developers and system administrators. This is the repo for the Bixsby server.

## Installation

Bixby requires Ruby 2+
  
  1. Download the source code and expand files into any directory of your choosing.
  2. `cd` into the folder and run `bundle install`
  3. Add Bixsby's required executables to your `$PATH`
  
One minor way to add the bins is by adding this code to your `.bash_profile`

    PATH=`paste -d ":" -s << EOF
    $PATH
    /path/to/bixsby/plugins/bixtodo/bin
    /path/to/bixsby/plugins/bixcalc/bin
    EOF`
 
 
## Interacting With Bixsby
Start Bixsby using `bundle exec ruby bin/bixsby`

To shutdown Bixby, type `\q` into his prompt.

To interact with Bixby, you will need `Bixsh`. Download it here: https://github.com/pacothelovetaco/bixsh

Bixsby runs on port 2001 so be sure the port is open.

## Plugins
Bixsby can be extended by adding plugins. By default, he has a todo and calculator plugin, and can perform basic email functions. 

The plugins folder:

      └── plugins/
          ├── bixcalc/
          ├── bixmail/
          └── bixtodo/

Plugins comprise of two types of files. They can be either a Ruby CLI program or a Ruby Module. Take a look in the `/plugins` folder for examples.

## Customizing Bixsby
Some of Bixsby's likes and dislikes can be changed to your liking. You can do this by editing his properties or by editing his AIML.

To edit his likes and dislikes, just edit the values in `config/properties.yml`

To edit his responses and learn more about AIML, visit: http://www.alicebot.org/aiml.html 

## Disclaimer
Bixsby is a work in progress and has many moving parts. He is meant to be my learning experiment. He also uses an AIML parser that I've developed called ProgramB. It's also still a work in progress. With that said, expect Bixsby to have some quirks. Please be patient with him, he's still learning.
