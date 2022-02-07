{-# LANGUAGE BangPatterns #-}

-- | Example uses of comparing set-like data structures.

module Main where

import           Control.DeepSeq
import qualified Data.BloomFilter.Easy
import qualified Data.DAWG.Packed
import qualified Data.HashSet
import qualified Data.IntSet
import qualified Data.Set
import qualified Data.Trie.Set
import           System.Random
import           Weigh

-- | Weigh sets.
main :: IO ()
main = do
  !dictwords <- fmap (force . lines) (readFile "/usr/share/dict/words")
  mainWith (do inserts
               fromDictWords dictwords
               fromlists
               fromlistsSProb
               fromlistsS
               fromlistsSMonotonic
           )

inserts :: Weigh ()
inserts = do func "Data.Set.insert mempty"
                  (`Data.Set.insert` mempty)
                  (1 :: Int)
             func "Data.HashSet.insert mempty"
                  (`Data.HashSet.insert` mempty)
                  (1 :: Int)
             func "Data.IntSet.insert mempty"
                  (`Data.IntSet.insert` mempty)
                  (1 :: Int)

fromlists :: Weigh ()
fromlists =
  do let !elems =
           force (take 1000000 (randoms (mkStdGen 0) :: [Int]))
     func "Data.Set.fromList     (1 million ints)" Data.Set.fromList elems
     func "Data.HashSet.fromList (1 million ints)" Data.HashSet.fromList elems
     func "Data.IntSet.fromList  (1 million ints)" Data.IntSet.fromList elems

fromlistsSProb :: Weigh ()
fromlistsSProb =
  do let !elems =
           force (map show (take 1000000 (randoms (mkStdGen 0) :: [Int])))
     func "Data.Set.fromList              (1 million strings, no false positives)" Data.Set.fromList elems
     func "Data.HashSet.fromList          (1 million strings, no false positives)" Data.HashSet.fromList elems
     func "Data.Trie.Set.fromList         (1 million strings, no false positives)" Data.Trie.Set.fromList elems
     func "Data.BloomFilter.Easy.easyList (1 million strings, 0.1 false positive rate)" (Data.BloomFilter.Easy.easyList 0.1) elems


fromlistsS :: Weigh ()
fromlistsS =
  do let !elems =
           force (map show (take 100000 (randoms (mkStdGen 0) :: [Int])))
     func "Data.Set.fromList          (100 thousand strings random)" Data.Set.fromList elems
     func "Data.HashSet.fromList      (100 thousand strings random)" Data.HashSet.fromList elems
     func "Data.Trie.Set.fromList     (100 thousand strings random)" Data.Trie.Set.fromList elems
     func "Data.DAWG.Packed.fromList  (100 thousand strings random)" Data.DAWG.Packed.fromList elems

fromlistsSMonotonic :: Weigh ()
fromlistsSMonotonic =
  do let !elems =
           force (map show [1 :: Int .. 1000000])
     func "Data.Set.fromList          (1 million strings monotonic)" Data.Set.fromList elems
     func "Data.HashSet.fromList      (1 million strings monotonic)" Data.HashSet.fromList elems
     func "Data.Trie.Set.fromList     (1 million strings monotonic)" Data.Trie.Set.fromList elems
     func "Data.DAWG.Packed.fromList  (1 million strings monotonic)" Data.DAWG.Packed.fromList elems

fromDictWords :: [String] -> Weigh ()
fromDictWords dictwords =
  do let !elems = force dictwords
     func "Data.Set.fromList         (usr share dict words)" Data.Set.fromList elems
     func "Data.HashSet.fromList     (usr share dict words)" Data.HashSet.fromList elems
     func "Data.Trie.Set.fromList    (usr share dict words)" Data.Trie.Set.fromList elems
     func "Data.DAWG.Packed.fromList (usr share dict words)" Data.DAWG.Packed.fromList elems
