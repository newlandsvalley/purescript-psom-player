module Audio.Euterpea.Player
  (State, Event (SetPerformance, SetInstrumentMap), initialState, foldp, view) where

import Prelude ((&&), (==))
import Audio.SoundFont (AUDIO)
import Audio.BasePlayer as BasePlayer
import Audio.Euterpea.ToMelody (perf2melody)
import Data.Midi.Instrument (InstrumentMap)
import Data.Euterpea.Midi.MEvent
import Data.Function (($), (#))
import Data.Array (null)
import Data.Maybe (Maybe(..))
import Pux (EffModel, noEffects, mapEffects, mapState)
import Pux.DOM.HTML (HTML, mapEvent)


data Event =
    SetPerformance Performance       -- we'll set the melody from the Euterpea Performance
  | SetInstrumentMap InstrumentMap
  | BasePlayerEvent BasePlayer.Event

type State =
  { melodySource :: Maybe Performance
  , instrumentMap :: InstrumentMap
  , basePlayer :: BasePlayer.State
  }

initialState :: InstrumentMap -> State
initialState instrumentMap =
  { melodySource : Nothing
  , instrumentMap : instrumentMap
  , basePlayer : BasePlayer.initialState
  }

foldp :: ∀ fx. Event -> State -> EffModel State Event (au :: AUDIO | fx)
foldp (SetPerformance performance) state =
  noEffects $ setPerformance performance state
foldp (SetInstrumentMap instrumentMap) state =
    noEffects $ state { instrumentMap = instrumentMap }
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

-- | establish the Base Player melody from thh performance (if we have it)
establishMelody :: State -> State
establishMelody state =
  let
    melody =
      case state.melodySource of
        Just performance ->
          perf2melody state.instrumentMap performance
        _ ->
         []
    bpState = BasePlayer.setMelody melody state.basePlayer
  in
    state { basePlayer = bpState }

view :: State -> HTML Event
view state =
  mapEvent BasePlayerEvent $ BasePlayer.view state.basePlayer
