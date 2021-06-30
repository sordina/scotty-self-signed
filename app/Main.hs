{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import GHC.Generics
import Data.Aeson (ToJSON, FromJSON)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Control.Concurrent.Async

import           Control.Monad               ((<=<))
import           Control.Monad.IO.Class      (MonadIO (liftIO))
import           Network.Wai                 (Response)
import           Network.Wai.Handler.Warp    (Port, defaultSettings, setPort)
import           Network.Wai.Handler.WarpTLS (defaultTlsSettings, runTLS, TLSSettings(..), tlsSettings)
import           Web.Scotty                  (scottyApp, ScottyM)
import           Web.Scotty.Trans            (ScottyT, scottyAppT)


-- Data

data Token   = Token   { accessToken :: String                     } deriving Generic
data Req     = Req     { input       :: Payload                    } deriving Generic
data Payload = Payload { arg1        :: Login                      } deriving Generic
data Login   = Login   { username    :: String, password :: String } deriving Generic

instance ToJSON Token
instance FromJSON Req
instance FromJSON Payload
instance FromJSON Login

mkToken :: String -> String -> Token
mkToken user pass = Token "test-token"


-- Main

main :: IO ()
main = do
    putStrLn "Hello, Haskell!"
    ssl <- async $ scottyTLS 443 "server.key" "server.csr" server
    scotty 8081 server
    wait ssl

server = do

    middleware logStdoutDev

    post "/" do
        Req (Payload (Login user pass)) <- jsonData
        json $ mkToken user pass


-- Redefining helper functions since https://hackage.haskell.org/package/scotty-tls is out of date.

scottyTLS :: Port -> FilePath -> FilePath -> ScottyM () -> IO ()
scottyTLS port key cert = runTLS
  (tlsSettings cert key)
  (setPort port defaultSettings) <=< scottyApp

scottyTLSSettings :: Port -> TLSSettings -> ScottyM () -> IO ()
scottyTLSSettings port settings = runTLS
  settings
  (setPort port defaultSettings) <=< scottyApp

scottyTTLS
    :: (Monad m, MonadIO n)
    => Port
    -> FilePath
    -> FilePath
    -> (m Response -> IO Response)
    -> ScottyT t m ()
    -> n ()
scottyTTLS port key cert runToIO s =
    scottyAppT runToIO s >>= liftIO . runTLS
        (tlsSettings cert key)
        (setPort port defaultSettings)

