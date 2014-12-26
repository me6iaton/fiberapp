Docpad = require('/var/www/atom/project/node_modules/docpad');

configDefaults = {
  rootPath: '/var/www/atom/project',
  logLevel: 0
};

Docpad.createInstance(configDefaults, function(err, docpadInstance) {
  if (err) {
    console.log(err);
  }
  docpadInstance.on('notify', function(opt, next) {
    console.log(opt.options.title);
    next()
  });
  return docpadInstance.action('generate', function(err) {
    if (err) {
      console.log(err.stack);
    }
  });
});
