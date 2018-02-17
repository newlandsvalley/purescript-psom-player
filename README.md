purescript-psom-player
======================


This is a purescript-pux module that is a player for [Purescript School of Music](https://github.com/newlandsvalley/purescript-school-of-music) performances.

As with the MIDI player, it is a specialisation of the basic [soundfont-player](https://github.com/newlandsvalley/purescript-soundfont-player). To build a Melody for the player, you need two things - the PSoM Performance and the set of MIDI instruments that are in scope.  Again, the building of the Melody is deferred to the point where the Play button is first pressed.

The calling program can use __SetPerformance__ to re-initialise the player with a new performance and __SetInstrumentMap__ to tell the player the instruments that are in scope.  

to build the module
-------------------

   bower install

   pulp build

   
dependencies
------------

| Module                     | Reference                                                              |
| -------------------------- | ---------------------------------------------------------------------- |
| purescript-school-of-Music | https://github.com/newlandsvalley/purescript-school-of-music.git       |
| purescript-soundfonts      | 2.0.0                                                                  |
| purescript-soundont_player | https://github.com/newlandsvalley/purescript-soundfont_player.git      |
| purescript-pux             | 9.1.0                                                                  |
