var fs = require('fs');
var path = require('path');
var pg  = require('pg'),
  JSX   = require('node-jsx').install(),
  React = require('react');

var package = require('./package.json');
var defaultAppName = process.env.APP ? process.env.APP : 'app';

var html = fs.readFileSync(path.join(process.cwd(), 'public', 'index.html'), {
  encoding: 'utf8'
});

var createStyleTag = function(file, media) {
  media = media || 'screen';
  return "    <link media='"+media+"' rel='stylesheet' type='text/css' href='"+file+"'>\n";
};

var stylesheets = '';
if(process.env.NODE_ENV === 'development') {
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/main.css', 'screen,print');
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/theme.css');
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/colors.css');
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/font-faces.css');
} else {
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/main.css', 'screen,print');
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/theme.css');
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/colors.css');
  stylesheets += createStyleTag('/css/'+defaultAppName+'/raw/{dir}/font-faces.css');
}


html = html.replace(new RegExp('{app}', 'g'), defaultAppName);
html = html.replace(new RegExp('{stylesheets}', 'g'), stylesheets);
html = html.replace(new RegExp('{version}', 'g'), package.version);
var ltr = html.replace(new RegExp('{dir}', 'g'), 'ltr');


console.log(ltr);
module.exports = {

  index: function(req, res) {
    console.log("in the index router indeed");
    res.send(ltr);
  },

  db: function(req, res) {
    pg.connect(process.env.DATABASE_URL, function(err, client, done) {
      client.query('SELECT * FROM mt_users', function(err, result) {
        done();
        if (err)
         { console.error(err); res.send("Error " + err); }
        else
         { res.send(result.rows); }
      });
    });
  }

}