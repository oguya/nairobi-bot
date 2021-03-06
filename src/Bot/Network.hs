{-|
Module      : Bot.Network
Description : Handle all the network duties.
Copyright   : (c) 2015, Njagi Mwaniki 
License     : BSD3
Maintainer  : njagi@urbanslug.com
Stability   : experimental
Portability : POSIX
-}

{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

module Bot.Network
( getJSON
, sendWaQuery
, getWebPage
) where

import Network.Wreq
import Control.Lens
import qualified Data.ByteString.Lazy as L

import qualified Data.ByteString.Char8 as Char8
import qualified Data.String as S
import qualified Data.Text as T

import Control.Exception.Base (catch)
import Network.HTTP.Client (HttpException(..))

import Bot.Types



{-
        For Now Playing.
-}

getJSON :: URL -> IO L.ByteString
getJSON url = do
  response <- get url
  return $ response ^. responseBody


{-
        For Wolfram Alpha.
-}

opts :: T.Text -> T.Text -> Options
opts id' query = defaults & header (S.fromString "Accept") .~ [(Char8.pack "text/xml")] & param (T.pack "input") .~ [query] & param (T.pack "appid") .~ [id']


sendWaQuery :: T.Text -- | Query
            -> T.Text -- | API key
            -> IO L.ByteString
sendWaQuery query id' = do
  r <- getWith (opts id' query) "http://api.wolframalpha.com/v2/query?" -- ^:: IO (Response L.ByteString)
  return $ r ^. responseBody

{-
        Bot.Url
-}

getWebPage :: String -- | Url
            -> IO L.ByteString -- | Webpage
getWebPage url = do
  response <- get url `catch` (\(_ :: HttpException) -> get "http://notfound.org/")
  return $ response ^. responseBody
  
