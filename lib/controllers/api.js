'use strict';

var mongoose = require('mongoose'),
    Dic = mongoose.model('Dic');

exports.tdnizer = function(req, res) {
  var params = {};
  if(req.query.tdn){
    params = {tdn: new RegExp(req.query.tdn, 'i') };
  }else{
    params = {name: new RegExp(req.query.name, 'i') };
  }

  return Dic.find(params, 'name yomi tdn', {limit: 10, sort:{tdn:1}}, function (err, dics) {
    if (!err) {
      return res.json(dics);
    } else {
      return res.send(err);
    }
  });
};