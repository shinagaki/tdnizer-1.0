'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

/**
 * Dic Schema
 */
var dateNow = Date.now();
var DicSchema = new Schema({
  name: {
    type: String,
    index: true
  },
  yomi: {
    type: String,
    index: true
  },
  hinshi: String,
  tdn: {
    type: String,
    index: true
  },
  created: {
    type: Date,
    default: dateNow
  },
  updated: {
    type: Date,
    default: dateNow
  }
});

mongoose.model('Dic', DicSchema);
