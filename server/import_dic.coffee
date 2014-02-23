fs = require 'fs'
async = require 'async'
mongoose = require 'mongoose'

process.env.NODE_ENV ?= 'development'
config = require '../lib/config/config'

# mongodb
mongoose.connect config.mongo.uri

# Dic file
dicFile = './server/dic/nicoime_msime.txt'

# Dic Schema
dateNow = Date.now()
DicSchema = mongoose.Schema
  name:
    type: String
    index: true
  yomi:
    type: String
    index: true
  hinshi: String
  tdn:
    type: String
    index: true
  sorce:
    type: String
    index: true
  created:
    type: Date
    default: dateNow
  updated:
    type: Date
    default: dateNow

Dic = mongoose.model 'Dic', DicSchema

tdnize = (yomi) ->
  replaceWords =
    'っょぃ':'つよい'
  result = []

  # 事前変換
  for k, v of replaceWords
    yomi = yomi.replace k, v
  for i, char of yomi
    result.push toTdnRoman(char, yomi[i-1])
  result.join ''

toTdnRoman = (char, charPrev) ->
  tdnRoman =
    'ぁ':'a', 'ぃ':'i', 'ぅ':'u', 'ぇ':'e', 'ぉ':'o',
    'あ':'a', 'い':'i', 'う':'u', 'え':'e', 'お':'o',
    'か':'k', 'き':'k', 'く':'k', 'け':'k', 'こ':'k',
    'が':'g', 'ぎ':'g', 'ぐ':'g', 'げ':'g', 'ご':'g',
    'さ':'s', 'し':'s', 'す':'s', 'せ':'s', 'そ':'s',
    'ざ':'z', 'じ':'j', 'ず':'z', 'ぜ':'z', 'ぞ':'z',
    'っ':'',
    'た':'t', 'ち':'c', 'つ':'t', 'て':'t', 'と':'t',
    'だ':'d', 'ぢ':'j', 'づ':'z', 'で':'d', 'ど':'d',
    'な':'n', 'に':'n', 'ぬ':'n', 'ね':'n', 'の':'n',
    'は':'h', 'ひ':'h', 'ふ':'f', 'へ':'h', 'ほ':'h',
    'ば':'b', 'び':'b', 'ぶ':'b', 'べ':'b', 'ぼ':'b',
    'ぱ':'p', 'ぴ':'p', 'ぷ':'p', 'ぺ':'p', 'ぽ':'p',
    'ま':'m', 'み':'m', 'む':'m', 'め':'m', 'も':'m',
    'や':'y', 'ゆ':'y', 'よ':'y',
    'ゃ':'y', 'ゅ':'y', 'ょ':'y',
    'ら':'r', 'り':'r', 'る':'r', 'れ':'r', 'ろ':'r',
    'ゎ':'w',
    'わ':'w', 'ゐ':'i', 'ゑ':'e', 'を':'o', # 変
    'ん':'n', 'ー':'', 'ヴ':'v'
  kaiyouonList = ['き','ぎ','し','じ','ち','ぢ','に','ひ','び','ぴ','み','り']
  gairaiList = [
    'しぇ','じぇ','ちぇ','つぁ','つぇ',
    'つぉ','てぃ','でぃ','ふぁ','ふぃ',
    'ふぇ','ふぉ','でゅ',
    'いぇ','うぃ','うぇ','うぉ','くぁ',
    'くぃ','くぇ','くぉ','つぃ','とぅ',
    'ぐぁ','どぅ','ヴぁ','ヴぃ','ヴぇ',
    'ヴぉ','てゅ','ふゅ','ヴゅ'
  ]

  # 開拗音
  if char in ['ゃ','ゅ','ょ'] and charPrev in kaiyouonList
    ''
  # 外来語の表記
  else if charPrev + char in gairaiList
    ''
  else if tdnRoman[char]?
    tdnRoman[char]
  else
    console.log 'toTdnRoman error :' + char

applyMongo = (dicObject, callback) ->
  Dic.findOne {name: dicObject.name}, (err, dic) ->
    if dic
      dic.yomi = dicObject.yomi
      dic.name = dicObject.name
      dic.hinshi = dicObject.hinshi
      dic.tdn = dicObject.tdn
      dic.source = dicObject.source
      dic.updated = dateNow
    else
      dic = new Dic(dicObject)

    console.log dicObject.yomi, dicObject.tdn
    dic.save setImmediate(callback)

tasks = []
fs.readFileSync(dicFile, 'utf16le').toString().split('\n').forEach (line) ->
  if m = line.match(/(.+)\t(.+)\t(.*)/)
    tdn = tdnize m[1]
    if !tdn?
      console.log 'tdn error' + m[1]
    dicObject =
      yomi: m[1]
      name: m[2]
      hinshi: m[3]
      tdn: tdn
      source: 'nico'

    tasks.push (next) ->
      applyMongo dicObject, next

# 同期処理
async.series tasks, (err, results) ->
  if err
    console.log err
  process.exit()