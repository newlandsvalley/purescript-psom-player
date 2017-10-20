module Audio.Euterpea.Player
  (State, Event (SetPerformance, SetInstrumentChannels), initialState, foldp, view, setInstruments) where

import Prelude ((&&), (==))
import Audio.SoundFont (AUDIO, Instrument, InstrumentChannels)
import Audio.BasePlayer as BasePlayer
import Audio.Euterpea.ToMelody (perf2melody)
import Data.Euterpea.Midi.MEvent
import Data.Function (($), (#))
import Data.Array (null)
import Data.Maybe (Maybe(..))
import Pux (EffModel, noEffects, mapEffects, mapState)
import Pux.DOM.HTML (HTML, mapEvent)


data Event =
    SetPerformance Performance       -- we'll set the melody from the Euterpea Performance
  | SetInstrumentChannels InstrumentChannels
  | BasePlayerEvent BasePlayer.Event

type State =
  { melodySource :: Maybe Performance
  , instrumentChans :: InstrumentChannels
  , basePlayer :: BasePlayer.State
  }

initialState :: InstrumentChannels -> State
initialState instrumentChans =
  { melodySource : Nothing
  , instrumentChans : instrumentChans
  , basePlayer : BasePlayer.initialState
  }

foldp :: ∀ fx. Event -> State -> EffModel State Event (au :: AUDIO | fx)
foldp (SetPerformance performance) state =
  noEffects $ setPerformance performance state
foldp (SetInstrumentChannels instrumentChans) state =
    noEffects $ state { instrumentChans = instrumentChans }
foldp (BasePlayerEvent e) state =
  let
    -- establish the melody only when the Play button is first pressed
    newState =
      case e of
        BasePlayer.PlayMelody playbackState ->
          if (playbackState == BasePlayer.PLAYING) && (null state.basePlayer.melody) then
            establishMelody state
          else
            state
        _ -> state
  in
    delegate e newState

-- | set the instrument soudfonts to use
setInstruments :: Array Instrument -> State -> State
setInstruments instruments state =
  let
    bpState = BasePlayer.setInstruments instruments state.basePlayer
  in
    state { basePlayer = bpState }

-- | set a PSoM Performance
setPerformance :: Performance -> State -> State
setPerformance performance state =
  let
    bpState = BasePlayer.setMelody [] state.basePlayer
  in
    state { melodySource = Just performance, basePlayer = bpState }

-- | delegate to the Base Player
delegate :: ∀ fx. BasePlayer.Event -> State -> EffModel State Event (au :: AUDIO | fx)
delegate e state =
  BasePlayer.foldp e state.basePlayer
    # mapEffects BasePlayerEvent
    # mapState \pst -> state { basePlayer = pst }

-- | establish the Base Player melody from the performance (if we have it)
establishMelody :: State -> State
establishMelody state =
  let
    melody =
      case state.melodySource of
        Just performance ->
          perf2melody state.instrumentChans performance
        _ ->
         []
    bpState = BasePlayer.setMelody melody state.basePlayer
  in
    state { basePlayer = bpState }

view :: State -> HTML Event
view state =
  mapEvent BasePlayerEvent $ BasePlayer.view state.basePlayer
