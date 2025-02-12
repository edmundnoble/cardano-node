module Trace.Forward.Configuration
  ( AcceptorConfiguration (..)
  , ForwarderConfiguration (..)
  , HowToConnect (..)
  ) where

import           Control.Tracer (Tracer)
import           GHC.Conc (TVar)
import           Ouroboros.Network.Driver (TraceSendRecv)

import           Trace.Forward.Protocol.Type

-- | Specifies how to connect to the peer.
--   Currently, only local socket/pipe is used.
newtype HowToConnect = LocalPipe FilePath
  deriving Show

-- | Acceptor configuration, parameterized by trace item's type.
data AcceptorConfiguration lo = AcceptorConfiguration
  { -- | The tracer that will be used by the acceptor in its network layer.
    acceptorTracer    :: !(Tracer IO (TraceSendRecv (TraceForward lo)))
    -- | The endpoint that will be used to listen to the forwarder.
  , forwarderEndpoint :: !HowToConnect
    -- | The request specifies how many 'TraceObject's will be requested.
  , whatToRequest     :: !NumberOfTraceObjects
    -- | 'TVar' that can be used as a brake: if an external thread sets
    --   it to 'True', the acceptor will send 'MsgDone' message to the
    --   forwarder and their session will be closed.
  , shouldWeStop      :: !(TVar Bool)
  }

-- | Forwarder configuration, parameterized by trace item's type.
data ForwarderConfiguration lo = ForwarderConfiguration
  { -- | The tracer that will be used by the forwarder in its network layer.
    forwarderTracer  :: !(Tracer IO (TraceSendRecv (TraceForward lo)))
    -- | The endpoint that will be used to connect to the acceptor.
  , acceptorEndpoint :: !HowToConnect
    -- | An action that returns node's information.
  , getNodeInfo      :: !(IO NodeInfo)
  }
